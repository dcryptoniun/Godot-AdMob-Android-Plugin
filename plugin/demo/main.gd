extends Node2D

# AdMob reference
var admob

# Ad configuration
var app_id = "ca-app-pub-3940256099942544~3347511713" # Test app ID
var banner_ad_unit_id = "ca-app-pub-3940256099942544/6300978111" # Test banner ad unit ID
var interstitial_ad_unit_id = "ca-app-pub-3940256099942544/1033173712" # Test interstitial ad unit ID
var rewarded_ad_unit_id = "ca-app-pub-3940256099942544/5224354917" # Test rewarded ad unit ID
var is_test_device = true
var is_real_ads = false

func _ready():
	# Initialize UI elements
	%ConsentStatus.text = "Consent Status: Unknown"
	%AdStatus.text = "Ad Status: Not initialized"
	
	# Initialize AdMob
	admob = $AdMob
	if admob:
		# Connect signals
		_connect_signals()
		
		# Initialize AdMob
		_initialize_admob()
	else:
		printerr("Couldn't find AdMob node")
		%AdStatus.text = "Ad Status: AdMob node not found"

# Connect all signals from the AdMob wrapper
func _connect_signals():
	if admob:
		# Consent signals
		admob.connect("consent_form_dismissed", _on_consent_form_dismissed)
		admob.connect("consent_status_changed", _on_consent_status_changed)
		
		# Banner ad signals
		admob.connect("banner_loaded", _on_banner_loaded)
		admob.connect("banner_failed_to_load", _on_banner_failed_to_load)
		
		# Interstitial ad signals
		admob.connect("interstitial_loaded", _on_interstitial_loaded)
		admob.connect("interstitial_failed_to_load", _on_interstitial_failed_to_load)
		admob.connect("interstitial_opened", _on_interstitial_opened)
		admob.connect("interstitial_closed", _on_interstitial_closed)
		
		# Rewarded ad signals
		admob.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
		admob.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
		admob.connect("rewarded_ad_opened", _on_rewarded_ad_opened)
		admob.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
		admob.connect("user_earned_reward", _on_user_earned_reward)

# Initialize AdMob with configuration
func _initialize_admob():
	if admob:
		admob.initialize(
			app_id,
			banner_ad_unit_id,
			interstitial_ad_unit_id,
			rewarded_ad_unit_id,
			is_test_device,
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
	is_test_device = %TestDeviceCheckbox.button_pressed
	is_real_ads = %RealAdsCheckbox.button_pressed
	
	# Re-initialize AdMob
	_initialize_admob()

# Consent management
func _on_show_consent_form_button_pressed():
	if admob:
		admob.show_consent_form()

# Banner ads
func _on_load_banner_button_pressed():
	if admob:
		# Get banner position (0: Bottom, 1: Top)
		var position = admob.BannerPosition.BOTTOM
		if %BannerPositionOption.selected == 1:
			position = admob.BannerPosition.TOP
		
		# Get banner size
		var size = admob.BannerSize.BANNER
		var size_option = %BannerSizeOption.selected
		if size_option == 1:
			size = admob.BannerSize.LARGE_BANNER
		elif size_option == 2:
			size = admob.BannerSize.MEDIUM_RECTANGLE
		elif size_option == 3:
			size = admob.BannerSize.FULL_BANNER
		elif size_option == 4:
			size = admob.BannerSize.LEADERBOARD
		
		admob.load_banner_ad(position, size)
		%AdStatus.text = "Ad Status: Loading banner..."

func _on_show_banner_button_pressed():
	if admob:
		admob.show_banner_ad()

func _on_hide_banner_button_pressed():
	if admob:
		admob.hide_banner_ad()

func _on_remove_banner_button_pressed():
	if admob:
		admob.remove_banner_ad()

# Interstitial ads
func _on_load_interstitial_button_pressed():
	if admob:
		admob.load_interstitial_ad()
		%AdStatus.text = "Ad Status: Loading interstitial..."

func _on_show_interstitial_button_pressed():
	if admob:
		if admob.is_interstitial_ad_loaded():
			admob.show_interstitial_ad()
		else:
			%AdStatus.text = "Ad Status: Interstitial not loaded yet"

# Rewarded ads
func _on_load_rewarded_button_pressed():
	if admob:
		admob.load_rewarded_ad()
		%AdStatus.text = "Ad Status: Loading rewarded ad..."

func _on_show_rewarded_button_pressed():
	if admob:
		if admob.is_rewarded_ad_loaded():
			admob.show_rewarded_ad()
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
