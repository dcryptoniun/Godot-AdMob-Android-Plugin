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

## Support the Project

If you find this plugin useful, please consider supporting its development:

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ff69b4?style=flat&logo=github)](https://github.com/sponsors/dcryptoniun)      <a href="https://www.buymeacoffee.com/MayankMeena" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 109px !important;" ></a>

## License

This plugin is distributed under the MIT license. See the LICENSE file for more details.