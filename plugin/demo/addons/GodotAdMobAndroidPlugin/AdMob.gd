@tool
extends Node

## AdMob plugin wrapper for Godot
## This class provides a clean API for using Google AdMob in Godot projects

# Singleton instance
static var instance: AdMob = null

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
var config: Resource
var config_resource_path: String = "res://addons/GodotAdMobAndroidPlugin/admob_config.tres"

# Configuration properties
var app_id: String = ""
var banner_ad_unit_id: String = ""
var interstitial_ad_unit_id: String = ""
var rewarded_ad_unit_id: String = ""

func _init():
	# Set singleton instance
	if instance == null:
		instance = self

func _enter_tree():
	# Initialize plugin when not in editor
	if not Engine.is_editor_hint():
		_initialize_plugin()

func _ready():
	# Load configuration
	config = load(config_resource_path)
	if config:
		app_id = config.app_id
		banner_ad_unit_id = config.banner_ad_unit_id
		interstitial_ad_unit_id = config.interstitial_ad_unit_id
		rewarded_ad_unit_id = config.rewarded_ad_unit_id
	
	# Initialize plugin when running on device
	if not Engine.is_editor_hint():
		_initialize_plugin()

## Get singleton instance
static func get_instance() -> AdMob:
	return instance

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
func initialize(p_app_id: String, p_banner_ad_unit_id: String, p_interstitial_ad_unit_id: String, 
				p_rewarded_ad_unit_id: String) -> bool:
	# Update configuration
	app_id = p_app_id
	banner_ad_unit_id = p_banner_ad_unit_id
	interstitial_ad_unit_id = p_interstitial_ad_unit_id
	rewarded_ad_unit_id = p_rewarded_ad_unit_id
	
	# Initialize plugin
	if _plugin:
		_plugin.initialize(
			app_id,
			banner_ad_unit_id,
			interstitial_ad_unit_id,
			rewarded_ad_unit_id
		)
		return true
	return false

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

## Show the banner ad
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

## Show the interstitial ad
func show_interstitial_ad():
	if _plugin:
		_plugin.showInterstitialAd()
		return true
	return false

# Rewarded Ads

## Load a rewarded ad
func load_rewarded_ad():
	if _plugin:
		_plugin.loadRewardedAd()
		return true
	return false

## Show the rewarded ad
func show_rewarded_ad():
	if _plugin:
		_plugin.showRewardedAd()
		return true
	return false

# Signal handlers

func _on_consent_form_dismissed():
	emit_signal("consent_form_dismissed")

func _on_consent_status_changed(status):
	emit_signal("consent_status_changed", status)

func _on_banner_loaded():
	emit_signal("banner_loaded")

func _on_banner_failed_to_load(error_message):
	emit_signal("banner_failed_to_load", error_message)

func _on_interstitial_loaded():
	emit_signal("interstitial_loaded")

func _on_interstitial_failed_to_load(error_message):
	emit_signal("interstitial_failed_to_load", error_message)

func _on_interstitial_opened():
	emit_signal("interstitial_opened")

func _on_interstitial_closed():
	emit_signal("interstitial_closed")

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
