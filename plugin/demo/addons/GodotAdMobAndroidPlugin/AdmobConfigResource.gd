@tool
class_name AdmobConfigResource
extends Resource

## AdMob Configuration Resource
## This resource stores all AdMob settings in a dedicated .tres file
## instead of using ProjectSettings

# Ad IDs
@export var app_id: String = ""
@export var banner_ad_unit_id: String = ""
@export var interstitial_ad_unit_id: String = ""
@export var rewarded_ad_unit_id: String = ""

# Configuration options
@export var is_test_device: bool = true
@export var is_real_ads: bool = false
@export var debug_geography: int = 0 # 0: Disabled, 1: EEA, 2: Not EEA

# Test Ad IDs
const TEST_APP_ID = "ca-app-pub-3940256099942544~3347511713"
const TEST_BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"
const TEST_INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712"
const TEST_REWARDED_AD_UNIT_ID = "ca-app-pub-3940256099942544/5224354917"

## Create a new configuration with default values
func _init(p_app_id: String = "", 
		p_banner_ad_unit_id: String = "", 
		p_interstitial_ad_unit_id: String = "", 
		p_rewarded_ad_unit_id: String = "", 
		p_is_test_device: bool = true, 
		p_is_real_ads: bool = false,
		p_debug_geography: int = 0):
	
	app_id = p_app_id
	banner_ad_unit_id = p_banner_ad_unit_id
	interstitial_ad_unit_id = p_interstitial_ad_unit_id
	rewarded_ad_unit_id = p_rewarded_ad_unit_id
	is_test_device = p_is_test_device
	is_real_ads = p_is_real_ads
	debug_geography = p_debug_geography

## Create a configuration with test ad IDs
static func create_test_config() -> AdmobConfigResource:
	return AdmobConfigResource.new(
		TEST_APP_ID,
		TEST_BANNER_AD_UNIT_ID,
		TEST_INTERSTITIAL_AD_UNIT_ID,
		TEST_REWARDED_AD_UNIT_ID,
		true,
		false,
		0
	)

## Create a configuration with real ad IDs
static func create_real_config(p_app_id: String, 
		p_banner_ad_unit_id: String, 
		p_interstitial_ad_unit_id: String, 
		p_rewarded_ad_unit_id: String,
		p_debug_geography: int = 0) -> AdmobConfigResource:
	
	return AdmobConfigResource.new(
		p_app_id,
		p_banner_ad_unit_id,
		p_interstitial_ad_unit_id,
		p_rewarded_ad_unit_id,
		false,
		true,
		p_debug_geography
	)

## Convert configuration to a dictionary
func to_dictionary() -> Dictionary:
	return {
		"app_id": app_id,
		"banner_ad_unit_id": banner_ad_unit_id,
		"interstitial_ad_unit_id": interstitial_ad_unit_id,
		"rewarded_ad_unit_id": rewarded_ad_unit_id,
		"is_test_device": is_test_device,
		"is_real_ads": is_real_ads,
		"debug_geography": debug_geography
	}

## Load configuration from a file path
static func load_from_file(file_path: String) -> AdmobConfigResource:
	if FileAccess.file_exists(file_path):
		return load(file_path) as AdmobConfigResource
	
	# Return default config if file doesn't exist
	return AdmobConfigResource.new()

## Save configuration to a file path
func save_to_file(file_path: String) -> bool:
	var result = ResourceSaver.save(self, file_path)
	return result == OK
