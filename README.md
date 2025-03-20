# Godot AdMob Android Plugin

This plugin provides Android AdMob integration for Godot Engine projects. It enables developers to easily implement mobile advertisements in their Godot games.

## Features

- Banner Ads
- Interstitial Ads
- Rewarded Ads
- Rewarded Interstitial Ads
- GDPR Compliance Support
- Test Ads Support

## Setup Instructions

1. Copy the plugin files to your Godot project's `android/plugins` directory
2. Enable the plugin in your project's export settings
3. Configure your AdMob app ID and ad unit IDs in the plugin settings
4. Initialize the plugin in your game code

## Usage Example

```gdscript
# Initialize AdMob
var admob = AdMob.new()
admob.initialize()

# Load and show a banner ad
admob.load_banner()
admob.show_banner()

# Load and show an interstitial ad
admob.load_interstitial()
admob.show_interstitial()
```

## Configuration

Refer to the demo project for complete implementation examples and best practices.

## Want to Contribute

**Note:** [Android Studio](https://developer.android.com/studio) is the recommended IDE for
developing Godot Android plugins. 
You can install the latest version from https://developer.android.com/studio.

### Building the configured Android plugin
- In a terminal window, navigate to the project's root directory and run the following command:
```
./gradlew assemble
```
- On successful completion of the build, the output files can be found in
  [`plugin/demo/addons`](plugin/demo/addons)

### Testing the Android plugin
You can use the included [Godot demo project](plugin/demo/project.godot) to test the built Android 
plugin

- Open the demo in Godot (4.4 or higher)
- Navigate to `Project` -> `Project Settings...` -> `Plugins`, and ensure the plugin is enabled
- Install the Godot Android build template by clicking on `Project` -> `Install Android Build Template...`
- Open [`plugin/demo/main.gd`](plugin/demo/main.gd) and update the logic as needed to reference 
  your plugin and its methods
- Connect an Android device to your machine and run the demo on it

#### Tips
Additional dependencies added to [`plugin/build.gradle.kts`](plugin/build.gradle.kts) should be added to the `_get_android_dependencies`
function in [`plugin/export_scripts_template/export_plugin.gd`](plugin/export_scripts_template/export_plugin.gd).

##### Simplify access to the exposed Java / Kotlin APIs

To make it easier to access the exposed Java / Kotlin APIs in the Godot Editor, it's recommended to 
provide one (or multiple) gdscript wrapper class(es) for your plugin users to interface with.

## Support the Project

If you find this plugin useful, please consider supporting its development:

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ff69b4?style=flat&logo=github)](https://github.com/sponsors/dcryptoniun)      <a href="https://www.buymeacoffee.com/MayankMeena" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 109px !important;" ></a>

## License

This plugin is distributed under the MIT license. See the LICENSE file for more details.
