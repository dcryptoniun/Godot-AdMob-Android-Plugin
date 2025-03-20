package com.teqanta.mayankmeena.godot.admob

import android.R.id
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

    private val tag = "GodotAdMob"
    private var adView: AdView? = null
    private var interstitialAd: InterstitialAd? = null
    private var rewardedAd: RewardedAd? = null
    private var consentInformation: ConsentInformation? = null
    private var consentForm: ConsentForm? = null
    private var bannerAdSize = AdSize.BANNER
    private var bannerPosition = 0 // 0: Bottom, 1: Top
    private var bannerVisible = false
    
    // Ad IDs
    private var appId = ""
    private var bannerAdUnitId = ""
    private var interstitialAdUnitId = ""
    private var rewardedAdUnitId = ""

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
        appId: String,
        bannerAdUnitId: String,
        interstitialAdUnitId: String,
        rewardedAdUnitId: String
    ) {
        runOnUiThread {
            try {
                // Set configuration values
                this.appId = appId
                this.bannerAdUnitId = bannerAdUnitId
                this.interstitialAdUnitId = interstitialAdUnitId
                this.rewardedAdUnitId = rewardedAdUnitId
                
                // Initialize consent form first and wait for consent before initializing ads
                initializeConsentForm { consentObtained ->
                    if (consentObtained) {
                        // Set up Mobile Ads SDK only after consent is obtained
                        MobileAds.initialize(activity!!) {}
                        Log.d(tag, "AdMob plugin initialized with app ID: $appId")
                    } else {
                        Log.d(tag, "Waiting for user consent before initializing AdMob")
                    }
                }
            } catch (e: Exception) {
                Log.e(tag, "Error initializing AdMob: ${e.message}")
            }
        }
    }
    
    // For backward compatibility with Godot < 4.4
    @UsedByGodot
    fun initializeWithDictionary(config: Dictionary) {
        val appId = config["app_id"] as? String ?: ""
        val bannerAdUnitId = config["banner_ad_unit_id"] as? String ?: ""
        val interstitialAdUnitId = config["interstitial_ad_unit_id"] as? String ?: ""
        val rewardedAdUnitId = config["rewarded_ad_unit_id"] as? String ?: ""
        
        initialize(appId, bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId)
    }
    
    // Consent Management for EU users
    private fun initializeConsentForm(callback: (Boolean) -> Unit = {}) {
        val params = ConsentRequestParameters.Builder()
            .setTagForUnderAgeOfConsent(false)
            .build()
        
        consentInformation = activity?.let { UserMessagingPlatform.getConsentInformation(it) }
        
        // Emit initial consent status
        emitConsentStatus()
        
        activity?.let {
            consentInformation?.requestConsentInfoUpdate(
                it,
                params,
                {
                    // Consent info updated successfully
                    Log.d(tag, "Consent info updated successfully")
                    emitConsentStatus()
                    
                    if (consentInformation?.isConsentFormAvailable == true) {
                        loadConsentForm(callback)
                    } else {
                        val hasConsent = when (consentInformation?.consentStatus) {
                            ConsentStatus.OBTAINED -> true
                            ConsentStatus.NOT_REQUIRED -> true
                            else -> false
                        }
                        callback(hasConsent)
                    }
                },
                { error ->
                    // Consent info update failed
                    Log.e(tag, "Error updating consent info: ${error.message}")
                    emitConsentStatus()
                    callback(false)
                }
            )
        }
    }
    
    private fun loadConsentForm(callback: (Boolean) -> Unit = {}) {
        activity?.let {
            UserMessagingPlatform.loadConsentForm(
                it,
                { form ->
                    consentForm = form
                    if (consentInformation?.consentStatus == ConsentStatus.REQUIRED) {
                        showConsentForm(callback)
                    } else {
                        val hasConsent = consentInformation?.consentStatus == ConsentStatus.OBTAINED
                        callback(hasConsent)
                    }
                },
                { error ->
                    Log.e(tag, "Error loading consent form: ${error.message}")
                    callback(false)
                }
            )
        }
    }
    
    private fun showConsentForm(callback: (Boolean) -> Unit = {}) {
        activity?.let {
            consentForm?.show(
                it
            ) { error ->
                if (error != null) {
                    Log.e(tag, "Error showing consent form: ${error.message}")
                    callback(false)
                } else {
                    val hasConsent = consentInformation?.consentStatus == ConsentStatus.OBTAINED
                    callback(hasConsent)
                }
                emitSignal("consent_form_dismissed")
                emitConsentStatus()
            }
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
                        Log.d(tag, "Banner ad loaded")
                        emitSignal("banner_loaded")
                        if (bannerVisible) {
                            showBannerAd()
                        }
                    }
                    
                    override fun onAdFailedToLoad(error: LoadAdError) {
                        Log.e(tag, "Banner ad failed to load: ${error.message}")
                        emitSignal("banner_failed_to_load", error.message)
                    }
                }
                
                // Load the ad
                val adRequest = AdRequest.Builder().build()
                adView?.loadAd(adRequest)
                
            } catch (e: Exception) {
                Log.e(tag, "Error loading banner ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showBannerAd() {
        runOnUiThread {
            try {
                if (adView == null) {
                    Log.w(tag, "Banner ad not loaded yet")
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

                activity?.findViewById<FrameLayout>(id.content)?.addView(adView, layoutParams)
                adView?.visibility = View.VISIBLE

            } catch (e: Exception) {
                Log.e(tag, "Error showing banner ad: ${e.message}")
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
                            Log.d(tag, "Interstitial ad loaded")
                            emitSignal("interstitial_loaded")

                            interstitialAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
                                override fun onAdDismissedFullScreenContent() {
                                    Log.d(tag, "Interstitial ad dismissed")
                                    interstitialAd = null
                                    emitSignal("interstitial_closed")
                                }

                                override fun onAdShowedFullScreenContent() {
                                    Log.d(tag, "Interstitial ad showed fullscreen content")
                                    emitSignal("interstitial_opened")
                                }

                                override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                    Log.e(tag, "Interstitial ad failed to show: ${error.message}")
                                    interstitialAd = null
                                }
                            }
                        }

                        override fun onAdFailedToLoad(error: LoadAdError) {
                            Log.e(tag, "Interstitial ad failed to load: ${error.message}")
                            interstitialAd = null
                            emitSignal("interstitial_failed_to_load", error.message)
                        }
                    })
                }
            } catch (e: Exception) {
                Log.e(tag, "Error loading interstitial ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showInterstitialAd() {
        runOnUiThread {
            try {
                if (interstitialAd == null) {
                    Log.w(tag, "Interstitial ad not loaded yet")
                    return@runOnUiThread
                }
                
                interstitialAd?.show(activity!!)
            } catch (e: Exception) {
                Log.e(tag, "Error showing interstitial ad: ${e.message}")
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
                            Log.d(tag, "Rewarded ad loaded")
                            emitSignal("rewarded_ad_loaded")

                            rewardedAd?.fullScreenContentCallback = object : FullScreenContentCallback() {
                                override fun onAdDismissedFullScreenContent() {
                                    Log.d(tag, "Rewarded ad dismissed")
                                    rewardedAd = null
                                    emitSignal("rewarded_ad_closed")
                                }

                                override fun onAdShowedFullScreenContent() {
                                    Log.d(tag, "Rewarded ad showed fullscreen content")
                                    emitSignal("rewarded_ad_opened")
                                }

                                override fun onAdFailedToShowFullScreenContent(error: AdError) {
                                    Log.e(tag, "Rewarded ad failed to show: ${error.message}")
                                    rewardedAd = null
                                }
                            }
                        }

                        override fun onAdFailedToLoad(error: LoadAdError) {
                            Log.e(tag, "Rewarded ad failed to load: ${error.message}")
                            rewardedAd = null
                            emitSignal("rewarded_ad_failed_to_load", error.message)
                        }
                    })
                }
            } catch (e: Exception) {
                Log.e(tag, "Error loading rewarded ad: ${e.message}")
            }
        }
    }
    
    @UsedByGodot
    fun showRewardedAd() {
        runOnUiThread {
            try {
                if (rewardedAd == null) {
                    Log.w(tag, "Rewarded ad not loaded yet")
                    return@runOnUiThread
                }
                
                rewardedAd?.show(activity!!) { rewardItem ->
                    // Handle the reward
                    val rewardAmount = rewardItem.amount
                    val rewardType = rewardItem.type
                    Log.d(tag, "User earned reward: $rewardAmount $rewardType")
                    emitSignal("user_earned_reward", rewardAmount, rewardType)
                }
            } catch (e: Exception) {
                Log.e(tag, "Error showing rewarded ad: ${e.message}")
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
