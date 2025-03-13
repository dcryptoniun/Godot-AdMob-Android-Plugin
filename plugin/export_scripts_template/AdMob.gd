@tool
extends Node

## AdMob plugin wrapper for Godot
## This class provides a clean API for using Google AdMob in Godot projects

# Plugin reference
const _PLUGIN_NAME = "GodotAdMobAndroidPlugin"
var _plugin = null

# Banner ad sizes
enum BannerSize {
	BANNER,
	LARGE_BANNER,
	MEDIUM_RECTANGLE,
	FULL_BANNER,
	LEADERBOARD
}

# Banner positions
enum BannerPosition {
	BOTTOM,
	TOP
}

# Consent status
enum ConsentStatus {
	UNKNOWN,
	REQUIRED,
	NOT_REQUIRED,
	OBTAINED
}

# Signals
signal consent_form_dismissed
signal consent_status_changed(status)
signal banner_loaded
signal banner_failed_to_load(error_message)
signal interstitial_loaded
signal interstitial_failed_to_load(error_message)
signal interstitial_opened
signal interstitial_closed
signal rewarded_ad_loaded
signal rewarded_ad_failed_to_load(error_message)
signal rewarded_ad_opened
signal rewarded_ad_closed
signal user_earned_reward(amount, type)

# Configuration
var config = {
	"app_id": "",
	"banner_ad_unit_id": "",
	"interstitial_ad_unit_id": "",
	"rewarded_ad_unit_id": "",
	"is_test_device": true,
	"is_real_ads": false
}

# Test Ad IDs
const TEST_APP_ID = "ca-app-pub-3940256099942544~3347511713"
const TEST_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
const TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"
const TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

func _enter_tree():
	# Initialize plugin when running in editor
	if Engine.is_editor_hint():
		return
	
	# Initialize plugin when running on device
	_initialize_plugin()

func _ready():
	# Initialize plugin when running on device
	if not Engine.is_editor_hint():
		_initialize_plugin()

## Initialize the plugin and connect signals
func _initialize_plugin():
	if Engine.has_singleton(_PLUGIN_NAME):
		_plugin = Engine.get_singleton(_PLUGIN_NAME)
		_connect_signals()
		print("AdMob plugin initialized successfully")
	else:
		push_error("Couldn't find plugin " + _PLUGIN_NAME)

## Connect all signals from the plugin
func _connect_signals():
	if _plugin:
		# Consent signals
		_plugin.connect("consent_form_dismissed", _on_consent_form_dismissed)
		_plugin.connect("consent_status_changed", _on_consent_status_changed)
		
		# Banner ad signals
		_plugin.connect("banner_loaded", _on_banner_loaded)
		_plugin.connect("banner_failed_to_load", _on_banner_failed_to_load)
		
		# Interstitial ad signals
		_plugin.connect("interstitial_loaded", _on_interstitial_loaded)
		_plugin.connect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		_plugin.connect("interstitial_opened", _on_interstitial_opened)
		_plugin.connect("interstitial_closed", _on_interstitial_closed)
		
		# Rewarded ad signals
		_plugin.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		_plugin.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		_plugin.connect("rewarded_ad_opened", _on_rewarded_ad_opened)
		_plugin.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
		_plugin.connect("user_earned_reward", _on_user_earned_reward)

## Initialize AdMob with configuration
## @param app_id The AdMob app ID
## @param banner_ad_unit_id The banner ad unit ID
## @param interstitial_ad_unit_id The interstitial ad unit ID
## @param rewarded_ad_unit_id The rewarded ad unit ID
## @param is_test_device Whether to use test device
## @param is_real_ads Whether to use real ads
func initialize(p_app_id = "", p_banner_ad_unit_id = "", p_interstitial_ad_unit_id = "", 
				p_rewarded_ad_unit_id = "", p_is_test_device = true, p_is_real_ads = false):
	# Update configuration
	config.app_id = p_app_id
	config.banner_ad_unit_id = p_banner_ad_unit_id
	config.interstitial_ad_unit_id = p_interstitial_ad_unit_id
	config.rewarded_ad_unit_id = p_rewarded_ad_unit_id
	config.is_test_device = p_is_test_device
	config.is_real_ads = p_is_real_ads
	
	# Initialize plugin
	if _plugin:
		_plugin.initialize(
			config.app_id,
			config.banner_ad_unit_id,
			config.interstitial_ad_unit_id,
			config.rewarded_ad_unit_id,
			config.is_test_device,
			config.is_real_ads
		)
		return true
	return false

## Initialize AdMob with test ads
func initialize_with_test_ads():
	return initialize(TEST_APP_ID, TEST_BANNER_AD_UNIT_ID, TEST_INTERSTITIAL_AD_UNIT_ID, TEST_REWARDED_AD_UNIT_ID, true, false)

# Consent Management

## Show consent form if available
func show_consent_form():
	if _plugin:
		_plugin.showConsentFormIfAvailable()
		return true
	return false

## Get current consent status
func get_consent_status():
	if _plugin:
		return _plugin.getConsentStatus()
	return "unknown"

## Reset consent status
func reset_consent_status():
	if _plugin:
		_plugin.resetConsentStatus()
		return true
	return false

# Banner Ads

## Load a banner ad
## @param position The position of the banner (0: Bottom, 1: Top)
## @param size The size of the banner ("BANNER", "LARGE_BANNER", etc.)
func load_banner_ad(position = BannerPosition.BOTTOM, size = BannerSize.BANNER):
	if _plugin:
		var size_str = "BANNER"
		match size:
			BannerSize.LARGE_BANNER:
				size_str = "LARGE_BANNER"
			BannerSize.MEDIUM_RECTANGLE:
				size_str = "MEDIUM_RECTANGLE"
			BannerSize.FULL_BANNER:
				size_str = "FULL_BANNER"
			BannerSize.LEADERBOARD:
				size_str = "LEADERBOARD"
		
		_plugin.loadBannerAd(position, size_str)
		return true
	return false

## Show the loaded banner ad
func show_banner_ad():
	if _plugin:
		_plugin.showBannerAd()
		return true
	return false

## Hide the banner ad
func hide_banner_ad():
	if _plugin:
		_plugin.hideBannerAd()
		return true
	return false

## Remove the banner ad
func remove_banner_ad():
	if _plugin:
		_plugin.removeBannerAd()
		return true
	return false

# Interstitial Ads

## Load an interstitial ad
func load_interstitial_ad():
	if _plugin:
		_plugin.loadInterstitialAd()
		return true
	return false

## Show the loaded interstitial ad
func show_interstitial_ad():
	if _plugin and _plugin.isInterstitialAdLoaded():
		_plugin.showInterstitialAd()
		return true
	return false

## Check if an interstitial ad is loaded
func is_interstitial_ad_loaded():
	if _plugin:
		return _plugin.isInterstitialAdLoaded()
	return false

# Rewarded Ads

## Load a rewarded ad
func load_rewarded_ad():
	if _plugin:
		_plugin.loadRewardedAd()
		return true
	return false

## Show the loaded rewarded ad
func show_rewarded_ad():
	if _plugin and _plugin.isRewardedAdLoaded():
		_plugin.showRewardedAd()
		return true
	return false

## Check if a rewarded ad is loaded
func is_rewarded_ad_loaded():
	if _plugin:
		return _plugin.isRewardedAdLoaded()
	return false

# Signal handlers

# Consent signals
func _on_consent_form_dismissed():
	emit_signal("consent_form_dismissed")

func _on_consent_status_changed(status):
	emit_signal("consent_status_changed", status)

# Banner ad signals
func _on_banner_loaded():
	emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_message):
	emit_signal("banner_failed_to_load", error_message)

# Interstitial ad signals
func _on_interstitial_loaded():
	emit_signal("interstitial_loaded")

func _on_interstitial_failed_to_load(error_message):
	emit_signal("interstitial_failed_to_load", error_message)

func _on_interstitial_opened():
	emit_signal("interstitial_opened")

func _on_interstitial_closed():
	emit_signal("interstitial_closed")

# Rewarded ad signals
func _on_rewarded_ad_loaded():
	emit_signal("rewarded_ad_loaded")

func _on_rewarded_ad_failed_to_load(error_message):
	emit_signal("rewarded_ad_failed_to_load", error_message)

func _on_rewarded_ad_opened():
	emit_signal("rewarded_ad_opened")

func _on_rewarded_ad_closed():
	emit_signal("rewarded_ad_closed")

func _on_user_earned_reward(amount, type):
	emit_signal("user_earned_reward", amount, type)