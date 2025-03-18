extends Node2D

# Ad configuration - will be loaded from configuration resource
var app_id = ""
var banner_ad_unit_id = ""
var interstitial_ad_unit_id = ""
var rewarded_ad_unit_id = ""

var is_real_ads = false

func _ready():
	# Initialize UI elements
	%ConsentStatus.text = "Consent Status: Unknown"
	%AdStatus.text = "Ad Status: Not initialized"
	
	# Try to load settings from configuration resource
	var config_path = "res://addons/GodotAdMobAndroidPlugin/admob_config.tres"
	var config_resource = null
	
	if FileAccess.file_exists(config_path):
		config_resource = load(config_path) as AdmobConfigResource
	
	if config_resource != null:
		# Load from resource
		app_id = config_resource.app_id
		banner_ad_unit_id = config_resource.banner_ad_unit_id
		interstitial_ad_unit_id = config_resource.interstitial_ad_unit_id
		rewarded_ad_unit_id = config_resource.rewarded_ad_unit_id
		is_real_ads = config_resource.is_real_ads
	
	# Update UI with loaded settings
	%AppIdInput.text = app_id
	%BannerAdUnitIdInput.text = banner_ad_unit_id
	%InterstitialAdUnitIdInput.text = interstitial_ad_unit_id
	%RewardedAdUnitIdInput.text = rewarded_ad_unit_id
	%RealAdsCheckbox.button_pressed = is_real_ads
	
	# Connect signals to the AdMob singleton
	_connect_signals()
	
	# Check if AdMob singleton is available
	if AdMob:
		%AdStatus.text = "Ad Status: AdMob singleton available"
	else:
		printerr("AdMob singleton not available")
		%AdStatus.text = "Ad Status: AdMob singleton not available"

# Connect all signals from the AdMob singleton
func _connect_signals():
	if AdMob:
		# Consent signals
		AdMob.connect("consent_form_dismissed", _on_consent_form_dismissed)
		AdMob.connect("consent_status_changed", _on_consent_status_changed)
		
		# Banner ad signals
		AdMob.connect("banner_loaded", _on_banner_loaded)
		AdMob.connect("banner_failed_to_load", _on_banner_failed_to_load)
		
		# Interstitial ad signals
		AdMob.connect("interstitial_loaded", _on_interstitial_loaded)
		AdMob.connect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		AdMob.connect("interstitial_opened", _on_interstitial_opened)
		AdMob.connect("interstitial_closed", _on_interstitial_closed)
		
		# Rewarded ad signals
		AdMob.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		AdMob.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		AdMob.connect("rewarded_ad_opened", _on_rewarded_ad_opened)
		AdMob.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
		AdMob.connect("user_earned_reward", _on_user_earned_reward)

# Initialize AdMob with configuration
func _initialize_admob():
	if AdMob:
		AdMob.initialize(
			app_id,
			banner_ad_unit_id,
			interstitial_ad_unit_id,
			rewarded_ad_unit_id,
			is_real_ads
		)
		%AdStatus.text = "Ad Status: Initialized"

# UI Button handlers
func _on_initialize_button_pressed():
	# Get values from UI
	app_id = %AppIdInput.text
	banner_ad_unit_id = %BannerAdUnitIdInput.text
	interstitial_ad_unit_id = %InterstitialAdUnitIdInput.text
	rewarded_ad_unit_id = %RewardedAdUnitIdInput.text
	is_real_ads = %RealAdsCheckbox.button_pressed
	
	# Re-initialize AdMob
	_initialize_admob()

# Consent management
func _on_show_consent_form_button_pressed():
	if AdMob:
		AdMob.show_consent_form()

# Banner ads
func _on_load_banner_button_pressed():
	if AdMob:
		# Get banner position (0: Bottom, 1: Top)
		var bannerPos = AdMob.BannerPosition.BOTTOM
		if %BannerPositionOption.selected == 1:
			bannerPos = AdMob.BannerPosition.TOP
		
		# Get banner size
		var size = AdMob.BannerSize.BANNER
		var size_option = %BannerSizeOption.selected
		if size_option == 1:
			size = AdMob.BannerSize.LARGE_BANNER
		elif size_option == 2:
			size = AdMob.BannerSize.MEDIUM_RECTANGLE
		elif size_option == 3:
			size = AdMob.BannerSize.FULL_BANNER
		elif size_option == 4:
			size = AdMob.BannerSize.LEADERBOARD
		
		AdMob.load_banner_ad(bannerPos, size)
		%AdStatus.text = "Ad Status: Loading banner..."

func _on_show_banner_button_pressed():
	if AdMob:
		AdMob.show_banner_ad()

func _on_hide_banner_button_pressed():
	if AdMob:
		AdMob.hide_banner_ad()

func _on_remove_banner_button_pressed():
	if AdMob:
		AdMob.remove_banner_ad()

# Interstitial ads
func _on_load_interstitial_button_pressed():
	if AdMob:
		AdMob.load_interstitial_ad()
		%AdStatus.text = "Ad Status: Loading interstitial..."

func _on_show_interstitial_button_pressed():
	if AdMob:
		if AdMob.is_interstitial_ad_loaded():
			AdMob.show_interstitial_ad()
		else:
			%AdStatus.text = "Ad Status: Interstitial not loaded yet"

# Rewarded ads
func _on_load_rewarded_button_pressed():
	if AdMob:
		AdMob.load_rewarded_ad()
		%AdStatus.text = "Ad Status: Loading rewarded ad..."

func _on_show_rewarded_button_pressed():
	if AdMob:
		if AdMob.is_rewarded_ad_loaded():
			AdMob.show_rewarded_ad()
		else:
			%AdStatus.text = "Ad Status: Rewarded ad not loaded yet"

# Signal handlers for consent
func _on_consent_form_dismissed():
	%AdStatus.text = "Ad Status: Consent form dismissed"


func _on_consent_status_changed(status):
	%ConsentStatus.text = "Consent Status: " + status

# Signal handlers for banner ads
func _on_banner_loaded():
	%AdStatus.text = "Ad Status: Banner loaded"

func _on_banner_failed_to_load(error_message):
	%AdStatus.text = "Ad Status: Banner failed to load - " + error_message

# Signal handlers for interstitial ads
func _on_interstitial_loaded():
	%AdStatus.text = "Ad Status: Interstitial loaded"

func _on_interstitial_failed_to_load(error_message):
	%AdStatus.text = "Ad Status: Interstitial failed to load - " + error_message

func _on_interstitial_opened():
	%AdStatus.text = "Ad Status: Interstitial opened"

func _on_interstitial_closed():
	%AdStatus.text = "Ad Status: Interstitial closed"

# Signal handlers for rewarded ads
func _on_rewarded_ad_loaded():
	%AdStatus.text = "Ad Status: Rewarded ad loaded"

func _on_rewarded_ad_failed_to_load(error_message):
	%AdStatus.text = "Ad Status: Rewarded ad failed to load - " + error_message

func _on_rewarded_ad_opened():
	%AdStatus.text = "Ad Status: Rewarded ad opened"

func _on_rewarded_ad_closed():
	%AdStatus.text = "Ad Status: Rewarded ad closed"

func _on_user_earned_reward(amount, type):
	%AdStatus.text = "Ad Status: User earned reward - " + str(amount) + " " + type
