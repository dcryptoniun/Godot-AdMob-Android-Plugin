# Godot Android Plugin For Google AdMob

A powerful and easy-to-use AdMob integration for Godot 4.4+ Android projects. This plugin provides a clean GDScript API for implementing banner ads, interstitial ads, and rewarded ads in your Godot Android games.

## Features

- Simple singleton-based API for easy integration
- Support for banner, interstitial, and rewarded ads
- GDPR consent management for EU users
- Configuration through resource files or code
- Automatic test ads during development
- Editor integration with configuration panel

## Installation

### From Releases

1. Download the latest release from the [Releases page](https://github.com/yourusername/Godot-AdMob-Android-Plugin/releases)
2. Extract the ZIP file
3. Copy the `GodotAdMobAndroidPlugin` folder to your project's `addons/` directory
4. Enable the plugin in Project Settings → Plugins
5. Install the Android Build Template in your project (Project → Install Android Build Template)

### From Source

1. Clone this repository
2. Build the plugin (see [Building the Plugin](#building-the-plugin))
3. Copy the generated files from `plugin/demo/addons/GodotAdMobAndroidPlugin` to your project's `addons/` directory
4. Enable the plugin in Project Settings → Plugins
5. Install the Android Build Template in your project (Project → Install Android Build Template)

## Usage

### Basic Setup

The plugin provides a singleton called `AdMob` that is automatically loaded when your game starts. You don't need to add any nodes to your scene.

```gdscript
# Your game script
extends Node

func _ready():
    # The AdMob singleton will auto-initialize with test ads
    # You don't need to write any code for basic testing
    pass
    
    # When ready for production, set your real ad IDs:
    # AdMob.initialize("your-app-id", "your-banner-id", "your-interstitial-id", "your-rewarded-id", true)
```

### Showing Ads

```gdscript
# Show a banner ad (loads and displays automatically)
AdMob.load_and_show_banner_ad()

# Show an interstitial ad (loads and displays when ready)
AdMob.load_and_show_interstitial_ad()

# Show a rewarded ad (loads and displays when ready)
AdMob.load_and_show_rewarded_ad()
```

### Getting Rewards

```gdscript
func _ready():
    AdMob.connect("user_earned_reward", _on_user_earned_reward)

func _on_user_earned_reward(amount, type):
    # Give the player their reward
    player.add_coins(amount)
```

### Configuration Options

#### Using the AdMob Config Panel

The plugin provides a convenient configuration panel in the Godot editor:

1. Open your project in the Godot editor
2. Look for the "AdMob Config" tab at the bottom of the editor
3. Enter your AdMob credentials and settings
4. Click "Save Settings" to save them to your project settings

#### Programmatically

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
    is_real_ads
)
```

## GDPR Compliance

The plugin includes support for GDPR consent collection for EU users:

```gdscript
# Show the consent form if available
AdMob.show_consent_form()

# Get the current consent status
var status = AdMob.get_consent_status()

# Connect to consent signals
AdMob.connect("consent_form_dismissed", _on_consent_form_dismissed)
AdMob.connect("consent_status_changed", _on_consent_status_changed)
```

## Building the Plugin

### Prerequisites

- [Android Studio](https://developer.android.com/studio) (recommended IDE)
- JDK 17 or higher
- Godot 4.4 or higher

### Build Steps

1. Clone this repository
2. Open a terminal in the project's root directory
3. Run the build command:

```bash
# On Linux/macOS
./gradlew assemble

# On Windows
gradlew.bat assemble
```

4. The built plugin will be available in `plugin/demo/addons/GodotAdMobAndroidPlugin`

## Testing the Plugin

You can use the included demo project to test the plugin:

1. Open the demo project in Godot (located at `plugin/demo/project.godot`)
2. Ensure the plugin is enabled in Project Settings → Plugins
3. Install the Android Build Template
4. Connect an Android device and run the project

## Contributing

Contributions are welcome! Here's how you can contribute:

1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes
4. Test your changes with the demo project
5. Submit a pull request

### Development Tips

- When adding new dependencies to `plugin/build.gradle.kts`, also update the `_get_android_dependencies` function in `plugin/export_scripts_template/export_plugin.gd`
- Follow the existing code style and patterns
- Test on multiple Android devices if possible
- Update documentation when adding new features

## Troubleshooting

### Common Issues

- **No ads showing**: Make sure you have the correct Ad Unit IDs and that your device is connected to the internet
- **Plugin not loading**: Ensure the plugin is enabled in Project Settings → Plugins
- **Build errors**: Make sure you have installed the Android Build Template and have the correct JDK version
- **Test ads not showing**: Add your device as a test device using Admob Website dashboard

## Support the Project

If you find this plugin useful, please consider supporting its development:

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ff69b4?style=flat&logo=github)](https://github.com/sponsors/dcryptoniun)      <a href="https://www.buymeacoffee.com/MayankMeena" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 109px !important;" ></a>



## License

See the [LICENSE](LICENSE) file for details.
