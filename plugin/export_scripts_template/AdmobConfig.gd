@tool
class_name AdmobConfig
extends RefCounted

## Configuration class for AdMob settings
## This class helps manage AdMob configuration in a clean way

# Ad IDs
var app_id: String = ""
var banner_ad_unit_id: String = ""
var interstitial_ad_unit_id: String = ""
var rewarded_ad_unit_id: String = ""

# Configuration options
var is_test_device: bool = true
var is_real_ads: bool = false

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
		p_is_real_ads: bool = false):
	
	app_id = p_app_id
	banner_ad_unit_id = p_banner_ad_unit_id
	interstitial_ad_unit_id = p_interstitial_ad_unit_id
	rewarded_ad_unit_id = p_rewarded_ad_unit_id
	is_test_device = p_is_test_device
	is_real_ads = p_is_real_ads

## Create a configuration with test ad IDs
static func create_test_config() -> AdmobConfig:
	return AdmobConfig.new(
		TEST_APP_ID,
		TEST_BANNER_AD_UNIT_ID,
		TEST_INTERSTITIAL_AD_UNIT_ID,
		TEST_REWARDED_AD_UNIT_ID,
		true,
		false
	)

## Create a configuration with real ad IDs
static func create_real_config(p_app_id: String, 
		p_banner_ad_unit_id: String, 
		p_interstitial_ad_unit_id: String, 
		p_rewarded_ad_unit_id: String) -> AdmobConfig:
	
	return AdmobConfig.new(
		p_app_id,
		p_banner_ad_unit_id,
		p_interstitial_ad_unit_id,
		p_rewarded_ad_unit_id,
		false,
		true
	)

## Convert configuration to a dictionary
func to_dictionary() -> Dictionary:
	return {
		"app_id": app_id,
		"banner_ad_unit_id": banner_ad_unit_id,
		"interstitial_ad_unit_id": interstitial_ad_unit_id,
		"rewarded_ad_unit_id": rewarded_ad_unit_id,
		"is_test_device": is_test_device,
		"is_real_ads": is_real_ads
	}