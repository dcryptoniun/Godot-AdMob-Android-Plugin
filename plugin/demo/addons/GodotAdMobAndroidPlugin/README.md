# Godot AdMob Plugin

This plugin provides a simple way to integrate Google AdMob ads into your Godot game.

## Minimal Setup

1. Enable the plugin in Project Settings → Plugins
2. That's it! The plugin will auto-initialize with test ads

```gdscript
# Your game script
extends Node

func _ready():
	# The AdMob singleton will auto-initialize with test ads
	# You don't need to write any code for basic testing
	pass
	
	# When ready for production, just set your real ad IDs:
	# AdMob.initialize("your-app-id", "your-banner-id", "your-interstitial-id", "your-rewarded-id", false, true)
```

## Showing Ads

The plugin provides simple one-line methods for showing ads:

```gdscript
# Show a banner ad (loads and displays automatically)
AdMob.load_and_show_banner_ad()

# Show an interstitial ad (loads and displays when ready, auto-reloads after closing)
AdMob.load_and_show_interstitial_ad()

# Show a rewarded ad (loads and displays when ready, auto-reloads after closing)
AdMob.load_and_show_rewarded_ad()
```

## Getting Rewards

Connect to the reward signal to give players their rewards:

```gdscript
func _ready():
	AdMob.connect("user_earned_reward", _on_user_earned_reward)

func _on_user_earned_reward(amount, type):
	# Give the player their reward
	player.add_coins(amount)
```

See the `example_usage.gd` file for a complete example.
