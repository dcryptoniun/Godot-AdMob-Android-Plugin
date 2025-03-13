package com.teqanta.mayankmeena.godot.admob

import android.R
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.google.android.gms.ads.*
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.ump.*
import com.google.android.ump.ConsentInformation.ConsentStatus
import org.godotengine.godot.Dictionary
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotAndroidPlugin(godot: Godot) : GodotPlugin(godot) {

    private val TAG = "GodotAdMob"
    private var adView: AdView? = null
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var consentInformation: ConsentInformation? = null
    private var consentForm: ConsentForm? = null
    private var isTestDevice = false
    private var isUsingRealAds = false
    private var bannerAdSize = AdSize.BANNER
    private var bannerPosition = 0 // 0: Bottom, 1: Top
    private var bannerVisible = false
    
    // Ad IDs
    private var appId = ""
    private var bannerAdUnitId = ""
    private var interstitialAdUnitId = ""
    private var rewardedAdUnitId = ""
    
    // Test Ad IDs
    private val TEST_APP_ID = "ca-app-pub-3940256099942544~3347511713"
    private val TEST_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
    private val TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"
    private val TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

    override fun getPluginName() = "GodotAdMobAndroidPlugin"

    override fun getPluginSignals(): Set<SignalInfo> {
        return setOf(
            SignalInfo("consent_form_dismissed"),
            SignalInfo("consent_status_changed", String::class.java),
            SignalInfo("banner_loaded"),
            SignalInfo("banner_failed_to_load", String::class.java),
            SignalInfo("interstitial_loaded"),
            SignalInfo("interstitial_failed_to_load", String::class.java),
            SignalInfo("interstitial_opened"),
            SignalInfo("interstitial_closed"),
            SignalInfo("rewarded_ad_loaded"),
            SignalInfo("rewarded_ad_failed_to_load", String::class.java),
            SignalInfo("rewarded_ad_opened"),
            SignalInfo("rewarded_ad_closed"),
            SignalInfo("user_earned_reward", Int::class.java, String::class.java)
        )
    }

    // Initialize the plugin with configuration
    @UsedByGodot
    fun initialize(
        appId: String = "",
        bannerAdUnitId: String = "",
        interstitialAdUnitId: String = "",
        rewardedAdUnitId: String = "",
        isTestDevice: Boolean = false,
        isReal: Boolean = false
    ) {
        runOnUiThread {
            try {
                // Set configuration values
                this.appId = appId
                this.bannerAdUnitId = bannerAdUnitId
                this.interstitialAdUnitId = interstitialAdUnitId
                this.rewardedAdUnitId = rewardedAdUnitId
                this.isTestDevice = isTestDevice
                this.isUsingRealAds = isReal
                
                // Set up Mobile Ads SDK
                MobileAds.initialize(activity!!) {}
                
                // Use test ad IDs if not using real ads
                if (!isUsingRealAds) {
                    this.appId = TEST_APP_ID
                    this.bannerAdUnitId = TEST_BANNER_AD_UNIT_ID
                    this.interstitialAdUnitId = TEST_INTERSTITIAL_AD_UNIT_ID
                    this.rewardedAdUnitId = TEST_REWARDED_AD_UNIT_ID
                }
                
                // Request consent information if needed
                initializeConsentForm()
                
                Log.d(TAG, "AdMob plugin initialized with app ID: $appId")
            } catch (e: Exception) {
                Log.e(TAG, "Error initializing AdMob: ${e.message}")
            }
        }
    }
    
    // For backward compatibility with Godot < 4.4
    @UsedByGodot
    fun initializeWithDictionary(config: Dictionary) {
        val appId = config.get("app_id") as? String ?: ""
        val bannerAdUnitId = config.get("banner_ad_unit_id") as? String ?: ""
        val interstitialAdUnitId = config.get("interstitial_ad_unit_id") as? String ?: ""
        val rewardedAdUnitId = config.get("rewarded_ad_unit_id") as? String ?: ""
        val isTestDevice = config.get("is_test_device") as? Boolean ?: false
        val isReal = config.get("is_real") as? Boolean ?: false
        
        initialize(appId, bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId, isTestDevice, isReal)
    }
    
    // Consent Management for EU users
    private fun initializeConsentForm() {
        val params = ConsentRequestParameters.Builder()
            .setTagForUnderAgeOfConsent(false)
        
        if (isTestDevice) {
            params.setConsentDebugSettings(
                ConsentDebugSettings.Builder(activity)
                    .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                    .addTestDeviceHashedId(AdRequest.DEVICE_ID_EMULATOR)
                    .build()
            )
        }
        
        consentInformation = UserMessagingPlatform.getConsentInformation(activity)
        consentInformation?.requestConsentInfoUpdate(
            activity,
            params.build(),
            {
                // Consent info updated successfully
                if (consentInformation?.isConsentFormAvailable == true) {
                    loadConsentForm()
                }
                emitConsentStatus()
            },
            { error ->
                // Consent info update failed
                Log.e(TAG, "Error updating consent info: ${error.message}")
            }
        )
    }
    
    private fun loadConsentForm() {
        UserMessagingPlatform.loadConsentForm(
            activity,
            { form ->
                consentForm = form
                if (consentInformation?.consentStatus == ConsentStatus.REQUIRED) {
                    showConsentForm()
                }
            },
            { error ->
                Log.e(TAG, "Error loading consent form: ${error.message}")
            }
        )
    }
    
    private fun showConsentForm() {
        consentForm?.show(
            activity
        ) { error ->
            if (error != null) {
                Log.e(TAG, "Error showing consent form: ${error.message}")
            }
            emitSignal("consent_form_dismissed")
            emitConsentStatus()
        }
    }
    
    private fun emitConsentStatus() {
        val status = when (consentInformation?.consentStatus) {
            ConsentStatus.REQUIRED -> "required"
            ConsentStatus.NOT_REQUIRED -> "not_required"
            ConsentStatus.OBTAINED -> "obtained"
            else -> "unknown"
        }
        emitSignal("consent_status_changed", status)
    }
    
    @UsedByGodot
    fun showConsentFormIfAvailable() {
        runOnUiThread {
            if (consentForm != null) {
                showConsentForm()
            } else {
                loadConsentForm()
            }
        }
    }
    
    @UsedByGodot
    fun getConsentStatus(): String {
        return when (consentInformation?.consentStatus) {
            ConsentStatus.REQUIRED -> "required"
            ConsentStatus.NOT_REQUIRED -> "not_required"
            ConsentStatus.OBTAINED -> "obtained"
            else -> "unknown"
        }
    }
    
    @UsedByGodot
    fun resetConsentStatus() {
        runOnUiThread {
            consentInformation?.reset()
            initializeConsentForm()
        }
    }
    
    // Banner Ads
    @UsedByGodot
    fun loadBannerAd(bannerPos: Int = 0, size: String = "BANNER") {
        runOnUiThread {
            try {
                // Remove existing banner if any
                removeBannerAd()
                
                // Set banner position and size
                bannerPosition = bannerPos
                bannerAdSize = when (size.uppercase()) {
                    "BANNER" -> AdSize.BANNER
                    "LARGE_BANNER" -> AdSize.LARGE_BANNER
                    "MEDIUM_RECTANGLE" -> AdSize.MEDIUM_RECTANGLE
                    "FULL_BANNER" -> AdSize.FULL_BANNER
                    "LEADERBOARD" -> AdSize.LEADERBOARD
                    else -> AdSize.BANNER
                }
                
                // Create and configure AdView
                adView = AdView(activity!!)
                adView?.adUnitId = bannerAdUnitId
                adView?.setAdSize(bannerAdSize)
                
                // Set up ad listeners
                adView?.adListener = object : AdListener() {
                    override fun onAdLoaded() {
                        Log.d(TAG, "Banner ad loaded")
                        emitSignal("banner_loaded")
                        if (bannerVisible) {
                            showBannerAd()
                        }
                    }
                    
                    override fun onAdFailedToLoad(error: LoadAdError) {
                        Log.e(TAG, "Banner ad failed to load: ${error.message}")
                        emitSignal("banner_failed_to_load", error.message)
                    }
                }
                
                // Load the ad
                val adRequest = AdRequest.Builder().build()
                adView?.loadAd(adRequest)
                
            } catch (e: Exception) {
                Log.e(TAG, "Error loading banner ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showBannerAd() {
        runOnUiThread {
            try {
                if (adView == null) {
                    Log.w(TAG, "Banner ad not loaded yet")
                    return@runOnUiThread
                }

                bannerVisible = true

                // Remove from parent if already added
                val parent = adView?.parent as? ViewGroup
                parent?.removeView(adView)

                // Add to layout
                val layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )

                // Set position (0: Bottom, 1: Top)
                if (bannerPosition == 0) {
                    layoutParams.gravity =
                        android.view.Gravity.BOTTOM or android.view.Gravity.CENTER_HORIZONTAL
                } else {
                    layoutParams.gravity =
                        android.view.Gravity.TOP or android.view.Gravity.CENTER_HORIZONTAL
                }

                activity?.findViewById<FrameLayout>(R.id.content)?.addView(adView, layoutParams)
                adView?.visibility = View.VISIBLE

            } catch (e: Exception) {
                Log.e(TAG, "Error showing banner ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun hideBannerAd() {
        runOnUiThread {
            bannerVisible = false
            adView?.visibility = View.GONE
        }
    }
    
    @UsedByGodot
    fun removeBannerAd() {
        runOnUiThread {
            bannerVisible = false
            val parent = adView?.parent as? ViewGroup
            parent?.removeView(adView)
            adView?.destroy()
            adView = null
        }
    }
    
    // Interstitial Ads
    @UsedByGodot
    fun loadInterstitialAd() {
        runOnUiThread {
            try {
                val adRequest = AdRequest.Builder().build()

                activity?.let {
                    InterstitialAd.load(it, interstitialAdUnitId, adRequest, object : InterstitialAdLoadCallback() {
                        override fun onAdLoaded(ad: InterstitialAd) {
                            interstitialAd = ad
                            Log.d(TAG, "Interstitial ad loaded")
                            emitSignal("interstitial_loaded")

                            interstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
                                override fun onAdDismissedFullScreenContent() {
                                    Log.d(TAG, "Interstitial ad dismissed")
                                    interstitialAd = null
                                    emitSignal("interstitial_closed")
                                }

                                override fun onAdShowedFullScreenContent() {
                                    Log.d(TAG, "Interstitial ad showed fullscreen content")
                                    emitSignal("interstitial_opened")
                                }

                                override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                    Log.e(TAG, "Interstitial ad failed to show: ${error.message}")
                                    interstitialAd = null
                                }
                            }
                        }

                        override fun onAdFailedToLoad(error: LoadAdError) {
                            Log.e(TAG, "Interstitial ad failed to load: ${error.message}")
                            interstitialAd = null
                            emitSignal("interstitial_failed_to_load", error.message)
                        }
                    })
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading interstitial ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showInterstitialAd() {
        runOnUiThread {
            try {
                if (interstitialAd == null) {
                    Log.w(TAG, "Interstitial ad not loaded yet")
                    return@runOnUiThread
                }
                
                interstitialAd?.show(activity!!)
            } catch (e: Exception) {
                Log.e(TAG, "Error showing interstitial ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun isInterstitialAdLoaded(): Boolean {
        return interstitialAd != null
    }
    
    // Rewarded Ads
    @UsedByGodot
    fun loadRewardedAd() {
        runOnUiThread {
            try {
                val adRequest = AdRequest.Builder().build()

                activity?.let {
                    RewardedAd.load(it, rewardedAdUnitId, adRequest, object : RewardedAdLoadCallback() {
                        override fun onAdLoaded(ad: RewardedAd) {
                            rewardedAd = ad
                            Log.d(TAG, "Rewarded ad loaded")
                            emitSignal("rewarded_ad_loaded")

                            rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
                                override fun onAdDismissedFullScreenContent() {
                                    Log.d(TAG, "Rewarded ad dismissed")
                                    rewardedAd = null
                                    emitSignal("rewarded_ad_closed")
                                }

                                override fun onAdShowedFullScreenContent() {
                                    Log.d(TAG, "Rewarded ad showed fullscreen content")
                                    emitSignal("rewarded_ad_opened")
                                }

                                override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                    Log.e(TAG, "Rewarded ad failed to show: ${error.message}")
                                    rewardedAd = null
                                }
                            }
                        }

                        override fun onAdFailedToLoad(error: LoadAdError) {
                            Log.e(TAG, "Rewarded ad failed to load: ${error.message}")
                            rewardedAd = null
                            emitSignal("rewarded_ad_failed_to_load", error.message)
                        }
                    })
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading rewarded ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showRewardedAd() {
        runOnUiThread {
            try {
                if (rewardedAd == null) {
                    Log.w(TAG, "Rewarded ad not loaded yet")
                    return@runOnUiThread
                }
                
                rewardedAd?.show(activity!!) { rewardItem ->
                    // Handle the reward
                    val rewardAmount = rewardItem.amount
                    val rewardType = rewardItem.type
                    Log.d(TAG, "User earned reward: $rewardAmount $rewardType")
                    emitSignal("user_earned_reward", rewardAmount, rewardType)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error showing rewarded ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun isRewardedAdLoaded(): Boolean {
        return rewardedAd != null
    }
    
    // Helper methods
    private fun runOnUiThread(action: () -> Unit) {
        activity?.runOnUiThread(action)
    }
}
