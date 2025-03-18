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

# Consent form load status
enum ConsentFormLoadStatus {
	UNKNOWN,
	LOADING,
	LOADED,
	FAILED_TO_LOAD,
	NOT_AVAILABLE
}

# Signals
signal consent_form_dismissed
signal consent_status_changed(status)
signal consent_form_load_success
signal consent_form_load_failure(error_message)
signal consent_info_update_success
signal consent_info_update_failure(error_message)
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
	"is_real_ads": false
}

# Configuration resource path
var config_resource_path: String = "res://addons/GodotAdMobAndroidPlugin/admob_config.tres"
var config_resource: AdmobConfigResource = null

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
		
		# Try to load from config resource file
		config_resource = _load_config_resource()
		
		if config_resource != null:
			# If we have a valid config resource with real ads, use it
			if config_resource.is_real_ads and config_resource.app_id.length() > 0:
				initialize_with_config_resource(config_resource)
				print("AdMob initialized with config resource")
				return
		
		
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
		if _plugin.is_connected("consent_form_load_success", _on_consent_form_load_success):
			_plugin.disconnect("consent_form_load_success", _on_consent_form_load_success)
		if _plugin.is_connected("consent_form_load_failure", _on_consent_form_load_failure):
			_plugin.disconnect("consent_form_load_failure", _on_consent_form_load_failure)
		if _plugin.is_connected("consent_info_update_success", _on_consent_info_update_success):
			_plugin.disconnect("consent_info_update_success", _on_consent_info_update_success)
		if _plugin.is_connected("consent_info_update_failure", _on_consent_info_update_failure):
			_plugin.disconnect("consent_info_update_failure", _on_consent_info_update_failure)
		
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
		_plugin.connect("consent_form_load_success", _on_consent_form_load_success)
		_plugin.connect("consent_form_load_failure", _on_consent_form_load_failure)
		_plugin.connect("consent_info_update_success", _on_consent_info_update_success)
		_plugin.connect("consent_info_update_failure", _on_consent_info_update_failure)
		
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
## @param is_real_ads Whether to use real ads
func initialize(p_app_id = "", p_banner_ad_unit_id = "", p_interstitial_ad_unit_id = "", 
				p_rewarded_ad_unit_id = "", p_is_real_ads = false):
	# Update configuration
	config.app_id = p_app_id
	config.banner_ad_unit_id = p_banner_ad_unit_id
	config.interstitial_ad_unit_id = p_interstitial_ad_unit_id
	config.rewarded_ad_unit_id = p_rewarded_ad_unit_id
	config.is_real_ads = p_is_real_ads
	
	# Initialize plugin
	if _plugin:
		_plugin.initialize(
			config.app_id,
			config.banner_ad_unit_id,
			config.interstitial_ad_unit_id,
			config.rewarded_ad_unit_id,
			config.is_real_ads
		)
		return true
	return false

## Initialize AdMob with an AdmobConfig object (legacy support)
## This is a convenience method for initializing with a configuration object
## @param config_obj The AdmobConfig object
func initialize_with_config(config_obj: AdmobConfig):
	return initialize(
		config_obj.app_id,
		config_obj.banner_ad_unit_id,
		config_obj.interstitial_ad_unit_id,
		config_obj.rewarded_ad_unit_id,
		config_obj.is_real_ads
	)

## Initialize AdMob with an AdmobConfigResource object
## This is the recommended way to initialize with a configuration resource
## @param resource The AdmobConfigResource object
func initialize_with_config_resource(resource: AdmobConfigResource):
	return initialize(
		resource.app_id,
		resource.banner_ad_unit_id,
		resource.interstitial_ad_unit_id,
		resource.rewarded_ad_unit_id,
		resource.is_real_ads
	)

## Set the path to the configuration resource file
## @param path The path to the configuration resource file
func set_config_resource_path(path: String):
	config_resource_path = path
	
## Load the configuration resource from the specified path
## @return The loaded AdmobConfigResource or null if not found
func _load_config_resource() -> AdmobConfigResource:
	if FileAccess.file_exists(config_resource_path):
		var resource = load(config_resource_path)
		if resource is AdmobConfigResource:
			return resource
	return null
	
## Save the current configuration to a resource file
## @param path Optional path to save to (uses config_resource_path if not specified)
## @return True if saved successfully
func save_config_to_resource(path: String = "") -> bool:
	if path.is_empty():
		path = config_resource_path
		
	# Create a new resource with current config
	var resource = AdmobConfigResource.new(
		config.app_id,
		config.banner_ad_unit_id,
		config.interstitial_ad_unit_id,
		config.rewarded_ad_unit_id,
		config.is_real_ads
	)
	
	# Save the resource
	return resource.save_to_file(path)

## Initialize AdMob with test ads
## This is the simplest way to get started with test ads
func initialize_with_test_ads():
	return initialize(TEST_APP_ID, TEST_BANNER_AD_UNIT_ID, TEST_INTERSTITIAL_AD_UNIT_ID, TEST_REWARDED_AD_UNIT_ID, false)

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

## Get the device ID for testing purposes
## @return The hashed device ID for testing
func get_device_id_for_testing() -> String:
	if _plugin:
		return _plugin.getDeviceIdForTesting()
	return ""

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

func _on_consent_form_load_success():
	emit_signal("consent_form_load_success")

func _on_consent_form_load_failure(error_message):
	emit_signal("consent_form_load_failure", error_message)

func _on_consent_info_update_success():
	emit_signal("consent_info_update_success")

func _on_consent_info_update_failure(error_message):
	emit_signal("consent_info_update_failure", error_message)

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
