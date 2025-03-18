# Godot AdMob Plugin Demo

This demo project demonstrates how to use the Godot AdMob Android Plugin in your Godot projects.

## AdMob Configuration

There are two ways to configure AdMob in your project:

### 1. Using the AdMob Config Panel

The plugin provides a convenient configuration panel in the Godot editor:

1. Open your project in the Godot editor
2. Look for the "AdMob Config" tab at the bottom of the editor
3. Enter your AdMob credentials and settings
4. Click "Save Settings" to save them to your project settings

These settings will be automatically loaded when your game starts.

### 2. Programmatically

You can also configure AdMob programmatically in your code, as demonstrated in this demo:

```gdscript
# Load settings from configuration resource
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

# Initialize AdMob with these settings
AdMob.initialize(
	app_id,
	banner_ad_unit_id,
	interstitial_ad_unit_id,
	rewarded_ad_unit_id,
	is_test_device,
	is_real_ads
)
```

## Features Demonstrated

This demo shows how to:

1. Initialize AdMob with configuration from project settings
2. Show and manage consent forms
3. Load and display banner ads with different sizes and positions
4. Load and show interstitial ads
5. Load and show rewarded ads
6. Handle all ad-related events through signals

## Usage

1. Run the demo
2. The app will automatically load settings from project settings
3. You can modify settings in the UI and click "Initialize AdMob" to apply them
4. Use the various buttons to test different ad types and features

## Important Notes

- When running in debug mode or with "Test Device" enabled, test ads will be shown
- For real ads, you need to provide valid AdMob IDs and enable "Use Real Ads"
- Make sure to implement proper consent management for your target regions
- The AdMob Config panel makes it easy to manage settings across your entire project

## Support the Project

If you find this plugin useful, please consider supporting its development:

### GitHub Sponsors
<iframe src="https://github.com/sponsors/dcryptoniun/button" title="Sponsor dcryptoniun" height="32" width="114" style="border: 0; border-radius: 6px;"></iframe>

### Buy Me A Coffee
<a href="https://www.buymeacoffee.com/MayankMeena" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
