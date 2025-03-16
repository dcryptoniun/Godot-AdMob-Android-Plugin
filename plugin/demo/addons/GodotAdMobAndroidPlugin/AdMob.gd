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

# Debug geography for consent testing
enum DebugGeography {
	DISABLED,
	EEA,
	OTHER
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
	"is_real_ads": false,
	"debug_geography": DebugGeography.DISABLED
}

# Auto-initialization flag
var auto_init_with_test_ads = true

# Test Ad IDs
const TEST_APP_ID = "ca-app-pub-3940256099942544~3347511713"
const TEST_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
const TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"
const TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

# Default banner settings
var default_banner_position = BannerPosition.BOTTOM
var default_banner_size = BannerSize.BANNER

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
		
		# Check if we should load from project settings
		if ProjectSettings.has_setting("admob/app_id"):
			# Load settings from project settings
			var app_id = ProjectSettings.get_setting("admob/app_id", "")
			var banner_ad_unit_id = ProjectSettings.get_setting("admob/banner_ad_unit_id", "")
			var interstitial_ad_unit_id = ProjectSettings.get_setting("admob/interstitial_ad_unit_id", "")
			var rewarded_ad_unit_id = ProjectSettings.get_setting("admob/rewarded_ad_unit_id", "")
			var is_test_device = ProjectSettings.get_setting("admob/is_test_device", true)
			var is_real_ads = ProjectSettings.get_setting("admob/is_real_ads", false)
			var debug_geography = ProjectSettings.get_setting("admob/debug_geography", 0)
			
			# If we have valid settings, use them
			if is_real_ads and app_id.length() > 0:
				initialize(app_id, banner_ad_unit_id, interstitial_ad_unit_id, rewarded_ad_unit_id, is_test_device, is_real_ads, debug_geography)
				print("AdMob initialized with project settings")
				return
		
		# Fall back to test ads if no valid project settings or not using real ads
		if auto_init_with_test_ads:
			initialize_with_test_ads()
			print("AdMob auto-initialized with test ads")
	else:
		push_error("Couldn't find plugin " + _PLUGIN_NAME)

## Connect all signals from the plugin
func _connect_signals():
	if _plugin:
		# Disconnect existing signals first to prevent duplicates
		if _plugin.is_connected("consent_form_dismissed", _on_consent_form_dismissed):
			_plugin.disconnect("consent_form_dismissed", _on_consent_form_dismissed)
		if _plugin.is_connected("consent_status_changed", _on_consent_status_changed):
			_plugin.disconnect("consent_status_changed", _on_consent_status_changed)
		
		if _plugin.is_connected("banner_loaded", _on_banner_loaded):
			_plugin.disconnect("banner_loaded", _on_banner_loaded)
		if _plugin.is_connected("banner_failed_to_load", _on_banner_failed_to_load):
			_plugin.disconnect("banner_failed_to_load", _on_banner_failed_to_load)
		
		if _plugin.is_connected("interstitial_loaded", _on_interstitial_loaded):
			_plugin.disconnect("interstitial_loaded", _on_interstitial_loaded)
		if _plugin.is_connected("interstitial_failed_to_load", _on_interstitial_failed_to_load):
			_plugin.disconnect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		if _plugin.is_connected("interstitial_opened", _on_interstitial_opened):
			_plugin.disconnect("interstitial_opened", _on_interstitial_opened)
		if _plugin.is_connected("interstitial_closed", _on_interstitial_closed):
			_plugin.disconnect("interstitial_closed", _on_interstitial_closed)
		
		if _plugin.is_connected("rewarded_ad_loaded", _on_rewarded_ad_loaded):
			_plugin.disconnect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		if _plugin.is_connected("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load):
			_plugin.disconnect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		if _plugin.is_connected("rewarded_ad_opened", _on_rewarded_ad_opened):
			_plugin.disconnect("rewarded_ad_opened", _on_rewarded_ad_opened)
		if _plugin.is_connected("rewarded_ad_closed", _on_rewarded_ad_closed):
			_plugin.disconnect("rewarded_ad_closed", _on_rewarded_ad_closed)
		if _plugin.is_connected("user_earned_reward", _on_user_earned_reward):
			_plugin.disconnect("user_earned_reward", _on_user_earned_reward)
		
		# Now connect all signals
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
## @param debug_geography The debug geography setting for consent testing (0: Disabled, 1: EEA, 2: Not EEA)
func initialize(p_app_id = "", p_banner_ad_unit_id = "", p_interstitial_ad_unit_id = "", 
				p_rewarded_ad_unit_id = "", p_is_test_device = true, p_is_real_ads = false,
				p_debug_geography = DebugGeography.DISABLED):
	# Update configuration
	config.app_id = p_app_id
	config.banner_ad_unit_id = p_banner_ad_unit_id
	config.interstitial_ad_unit_id = p_interstitial_ad_unit_id
	config.rewarded_ad_unit_id = p_rewarded_ad_unit_id
	config.is_test_device = p_is_test_device
	config.is_real_ads = p_is_real_ads
	config.debug_geography = p_debug_geography
	
	# Initialize plugin
	if _plugin:
		_plugin.initialize(
			config.app_id,
			config.banner_ad_unit_id,
			config.interstitial_ad_unit_id,
			config.rewarded_ad_unit_id,
			config.is_test_device,
			config.is_real_ads,
			config.debug_geography
		)
		return true
	return false

## Initialize AdMob with an AdmobConfig object
## This is a convenience method for initializing with a configuration object
## @param config_obj The AdmobConfig object
func initialize_with_config(config_obj: AdmobConfig):
	return initialize(
		config_obj.app_id,
		config_obj.banner_ad_unit_id,
		config_obj.interstitial_ad_unit_id,
		config_obj.rewarded_ad_unit_id,
		config_obj.is_test_device,
		config_obj.is_real_ads
	)

## Initialize AdMob with test ads
## This is the simplest way to get started with test ads
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
## @param bannerPos The position of the banner (0: Bottom, 1: Top)
## @param size The size of the banner ("BANNER", "LARGE_BANNER", etc.)
func load_banner_ad(bannerPos = BannerPosition.BOTTOM, size = BannerSize.BANNER):
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
		
		_plugin.loadBannerAd(bannerPos, size_str)
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

## Load and show a banner ad in a single call
## This is a convenience method that loads and shows a banner ad
## @param bannerPos The position of the banner (0: Bottom, 1: Top)
## @param size The size of the banner ("BANNER", "LARGE_BANNER", etc.)
func load_and_show_banner_ad(bannerPos = BannerPosition.BOTTOM, size = BannerSize.BANNER):
	if load_banner_ad(bannerPos, size):
		# Connect one-time signal to show the banner when loaded
		if not is_connected("banner_loaded", _on_banner_loaded_show):
			connect("banner_loaded", _on_banner_loaded_show, CONNECT_ONE_SHOT)
		return true
	return false

# Internal callback for load_and_show_banner_ad
func _on_banner_loaded_show():
	show_banner_ad()

# Interstitial Ads

## Load an interstitial ad
func load_interstitial_ad():
	if _plugin:
		_plugin.loadInterstitialAd()
		return true
	return false

## Show the loaded interstitial ad
## If auto_reload is true, it will automatically load a new ad after showing
func show_interstitial_ad(auto_reload: bool = true):
	if _plugin and _plugin.isInterstitialAdLoaded():
		_plugin.showInterstitialAd()
		if auto_reload:
			# We'll reload in the closed callback to ensure proper timing
			await_interstitial_closed = auto_reload
		return true
	return false

## Check if an interstitial ad is loaded
func is_interstitial_ad_loaded():
	if _plugin:
		return _plugin.isInterstitialAdLoaded()
	return false

## Load and show an interstitial ad when ready
## This is a convenience method that loads an ad and shows it when it's ready
func load_and_show_interstitial_ad(auto_reload: bool = true):
	if not is_interstitial_ad_loaded():
		load_interstitial_ad()
		# Connect one-time signal to show the ad when loaded
		if not is_connected("interstitial_loaded", _on_interstitial_loaded_show):
			connect("interstitial_loaded", _on_interstitial_loaded_show, CONNECT_ONE_SHOT)
		return true
	else:
		return show_interstitial_ad(auto_reload)

# Internal variable to track if we should auto-reload after closing
var await_interstitial_closed: bool = false

# Internal callback for load_and_show_interstitial_ad
func _on_interstitial_loaded_show():
	show_interstitial_ad()

# Rewarded Ads

## Load a rewarded ad
func load_rewarded_ad():
	if _plugin:
		_plugin.loadRewardedAd()
		return true
	return false

## Show the loaded rewarded ad
## If auto_reload is true, it will automatically load a new ad after showing
func show_rewarded_ad(auto_reload: bool = true):
	if _plugin and _plugin.isRewardedAdLoaded():
		_plugin.showRewardedAd()
		if auto_reload:
			# We'll reload in the closed callback to ensure proper timing
			await_rewarded_closed = auto_reload
		return true
	return false

## Check if a rewarded ad is loaded
func is_rewarded_ad_loaded():
	if _plugin:
		return _plugin.isRewardedAdLoaded()
	return false

## Load and show a rewarded ad when ready
## This is a convenience method that loads an ad and shows it when it's ready
func load_and_show_rewarded_ad(auto_reload: bool = true):
	if not is_rewarded_ad_loaded():
		load_rewarded_ad()
		# Connect one-time signal to show the ad when loaded
		if not is_connected("rewarded_ad_loaded", _on_rewarded_ad_loaded_show):
			connect("rewarded_ad_loaded", _on_rewarded_ad_loaded_show, CONNECT_ONE_SHOT)
		return true
	else:
		return show_rewarded_ad(auto_reload)

# Internal variable to track if we should auto-reload after closing
var await_rewarded_closed: bool = false

# Internal callback for load_and_show_rewarded_ad
func _on_rewarded_ad_loaded_show():
	show_rewarded_ad()

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
	# Auto-reload if requested
	if await_interstitial_closed:
		await_interstitial_closed = false
		load_interstitial_ad()

# Rewarded ad signals
func _on_rewarded_ad_loaded():
	emit_signal("rewarded_ad_loaded")

func _on_rewarded_ad_failed_to_load(error_message):
	emit_signal("rewarded_ad_failed_to_load", error_message)

func _on_rewarded_ad_opened():
	emit_signal("rewarded_ad_opened")

func _on_rewarded_ad_closed():
	emit_signal("rewarded_ad_closed")
	# Auto-reload if requested
	if await_rewarded_closed:
		await_rewarded_closed = false
		load_rewarded_ad()

func _on_user_earned_reward(amount, type):
	emit_signal("user_earned_reward", amount, type)
