extends Node2D

# Plugin reference
var _plugin_name = "GodotAdMobAndroidPlugin"
var _android_plugin

# Ad configuration
var app_id = "ca-app-pub-3940256099942544~3347511713" # Test app ID
var banner_ad_unit_id = "ca-app-pub-3940256099942544/6300978111" # Test banner ad unit ID
var interstitial_ad_unit_id = "ca-app-pub-3940256099942544/1033173712" # Test interstitial ad unit ID
var rewarded_ad_unit_id = "ca-app-pub-3940256099942544/5224354917" # Test rewarded ad unit ID
var is_test_device = true
var is_real_ads = false

func _ready():
	# Initialize UI elements
	$UI/ConsentStatus.text = "Consent Status: Unknown"
	$UI/AdStatus.text = "Ad Status: Not initialized"
	
	# Initialize plugin
	if Engine.has_singleton(_plugin_name):
		_android_plugin = Engine.get_singleton(_plugin_name)
		
		# Connect signals
		_connect_signals()
		
		# Initialize AdMob
		_initialize_admob()
	else:
		printerr("Couldn't find plugin " + _plugin_name)
		$UI/AdStatus.text = "Ad Status: Plugin not found"

# Connect all signals from the plugin
func _connect_signals():
	if _android_plugin:
		# Consent signals
		_android_plugin.connect("consent_form_dismissed", _on_consent_form_dismissed)
		_android_plugin.connect("consent_status_changed", _on_consent_status_changed)
		
		# Banner ad signals
		_android_plugin.connect("banner_loaded", _on_banner_loaded)
		_android_plugin.connect("banner_failed_to_load", _on_banner_failed_to_load)
		
		# Interstitial ad signals
		_android_plugin.connect("interstitial_loaded", _on_interstitial_loaded)
		_android_plugin.connect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		_android_plugin.connect("interstitial_opened", _on_interstitial_opened)
		_android_plugin.connect("interstitial_closed", _on_interstitial_closed)
		
		# Rewarded ad signals
		_android_plugin.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		_android_plugin.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		_android_plugin.connect("rewarded_ad_opened", _on_rewarded_ad_opened)
		_android_plugin.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
		_android_plugin.connect("user_earned_reward", _on_user_earned_reward)

# Initialize AdMob with configuration
func _initialize_admob():
	if _android_plugin:
		var config = {
			"app_id": app_id,
			"banner_ad_unit_id": banner_ad_unit_id,
			"interstitial_ad_unit_id": interstitial_ad_unit_id,
			"rewarded_ad_unit_id": rewarded_ad_unit_id,
			"is_test_device": is_test_device,
			"is_real": is_real_ads
		}
		
		_android_plugin.initialize(config)
		$UI/AdStatus.text = "Ad Status: Initialized"

# UI Button handlers
func _on_initialize_button_pressed():
	# Get values from UI
	app_id = $UI/AppIdInput.text
	banner_ad_unit_id = $UI/BannerAdUnitIdInput.text
	interstitial_ad_unit_id = $UI/InterstitialAdUnitIdInput.text
	rewarded_ad_unit_id = $UI/RewardedAdUnitIdInput.text
	is_test_device = $UI/TestDeviceCheckbox.button_pressed
	is_real_ads = $UI/RealAdsCheckbox.button_pressed
	
	# Re-initialize AdMob
	_initialize_admob()

# Consent management
func _on_show_consent_form_button_pressed():
	if _android_plugin:
		_android_plugin.showConsentFormIfAvailable()

# Banner ads
func _on_load_banner_button_pressed():
	if _android_plugin:
		# Get banner position (0: Bottom, 1: Top)
		var position = 0
		if $UI/BannerPositionOption.selected == 1:
			position = 1
		
		# Get banner size
		var size = "BANNER"
		var size_option = $UI/BannerSizeOption.selected
		if size_option == 1:
			size = "LARGE_BANNER"
		elif size_option == 2:
			size = "MEDIUM_RECTANGLE"
		elif size_option == 3:
			size = "FULL_BANNER"
		elif size_option == 4:
			size = "LEADERBOARD"
		
		_android_plugin.loadBannerAd(position, size)
		$UI/AdStatus.text = "Ad Status: Loading banner..."

func _on_show_banner_button_pressed():
	if _android_plugin:
		_android_plugin.showBannerAd()

func _on_hide_banner_button_pressed():
	if _android_plugin:
		_android_plugin.hideBannerAd()

func _on_remove_banner_button_pressed():
	if _android_plugin:
		_android_plugin.removeBannerAd()

# Interstitial ads
func _on_load_interstitial_button_pressed():
	if _android_plugin:
		_android_plugin.loadInterstitialAd()
		$UI/AdStatus.text = "Ad Status: Loading interstitial..."

func _on_show_interstitial_button_pressed():
	if _android_plugin:
		if _android_plugin.isInterstitialAdLoaded():
			_android_plugin.showInterstitialAd()
		else:
			$UI/AdStatus.text = "Ad Status: Interstitial not loaded yet"

# Rewarded ads
func _on_load_rewarded_button_pressed():
	if _android_plugin:
		_android_plugin.loadRewardedAd()
		$UI/AdStatus.text = "Ad Status: Loading rewarded ad..."

func _on_show_rewarded_button_pressed():
	if _android_plugin:
		if _android_plugin.isRewardedAdLoaded():
			_android_plugin.showRewardedAd()
		else:
			$UI/AdStatus.text = "Ad Status: Rewarded ad not loaded yet"

# Signal handlers for consent
func _on_consent_form_dismissed():
	$UI/AdStatus.text = "Ad Status: Consent form dismissed"


func _on_consent_status_changed(status):
	$UI/ConsentStatus.text = "Consent Status: " + status

# Signal handlers for banner ads
func _on_banner_loaded():
	$UI/AdStatus.text = "Ad Status: Banner loaded"

func _on_banner_failed_to_load(error_message):
	$UI/AdStatus.text = "Ad Status: Banner failed to load - " + error_message

# Signal handlers for interstitial ads
func _on_interstitial_loaded():
	$UI/AdStatus.text = "Ad Status: Interstitial loaded"

func _on_interstitial_failed_to_load(error_message):
	$UI/AdStatus.text = "Ad Status: Interstitial failed to load - " + error_message

func _on_interstitial_opened():
	$UI/AdStatus.text = "Ad Status: Interstitial opened"

func _on_interstitial_closed():
	$UI/AdStatus.text = "Ad Status: Interstitial closed"

# Signal handlers for rewarded ads
func _on_rewarded_ad_loaded():
	$UI/AdStatus.text = "Ad Status: Rewarded ad loaded"

func _on_rewarded_ad_failed_to_load(error_message):
	$UI/AdStatus.text = "Ad Status: Rewarded ad failed to load - " + error_message

func _on_rewarded_ad_opened():
	$UI/AdStatus.text = "Ad Status: Rewarded ad opened"

func _on_rewarded_ad_closed():
	$UI/AdStatus.text = "Ad Status: Rewarded ad closed"

func _on_user_earned_reward(amount, type):
	$UI/AdStatus.text = "Ad Status: User earned reward - " + str(amount) + " " + type
