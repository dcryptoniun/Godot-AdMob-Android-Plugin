@tool
class_name AdmobConfig
extends Resource

## Configuration class for AdMob settings
## This class helps manage AdMob configuration in a clean way

# Ad IDs
@export var app_id: String = ""
@export var banner_ad_unit_id: String = ""
@export var interstitial_ad_unit_id: String = ""
@export var rewarded_ad_unit_id: String = ""

## Create a new configuration with default values
func _init(p_app_id: String = "", 
		p_banner_ad_unit_id: String = "", 
		p_interstitial_ad_unit_id: String = "", 
		p_rewarded_ad_unit_id: String = ""):
	
	app_id = p_app_id
	banner_ad_unit_id = p_banner_ad_unit_id
	interstitial_ad_unit_id = p_interstitial_ad_unit_id
	rewarded_ad_unit_id = p_rewarded_ad_unit_id

## Convert configuration to a dictionary
func to_dictionary() -> Dictionary:
	return {
		"app_id": app_id,
		"banner_ad_unit_id": banner_ad_unit_id,
		"interstitial_ad_unit_id": interstitial_ad_unit_id,
		"rewarded_ad_unit_id": rewarded_ad_unit_id
	}


## Load configuration from a resource file
static func load_from_file(path: String) -> AdmobConfig:
	var config = load(path)
	if not config:
		config = AdmobConfig.new()
		config.save_to_file(path)
	return config

## Save configuration to a resource file
func save_to_file(path: String) -> void:
	ResourceSaver.save(self, path)