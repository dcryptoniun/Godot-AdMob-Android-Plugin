extends Node

# Example script showing minimal usage of the AdMob plugin
# This demonstrates how to use the plugin with minimal code

# AdMob reference
var admob

func _ready():
	# Get the AdMob node
	admob = $AdMob
	if not admob:
		push_error("AdMob node not found")
		return
	
	# Method 1: Initialize with test ads (simplest approach for testing)
	admob.initialize_with_test_ads()
	
	# Method 2: Initialize with a config object (recommended for production)
	# var config = AdmobConfig.create_real_config(
	# 	"your-app-id",
	# 	"your-banner-ad-unit-id",
	# 	"your-interstitial-ad-unit-id",
	# 	"your-rewarded-ad-unit-id"
	# )
	# admob.initialize_with_config(config)
	
	# Connect to signals (optional, only connect to what you need)
	_connect_signals()
	
	# Load ads (can be done later based on game flow)
	_preload_ads()

func _connect_signals():
	# Connect only to the signals you need
	admob.connect("interstitial_closed", _on_interstitial_closed)
	admob.connect("rewarded_ad_closed", _on_rewarded_ad_closed)
	admob.connect("user_earned_reward", _on_user_earned_reward)

# Preload ads at the start (optional)
func _preload_ads():
	# Load banner and show it
	admob.load_and_show_banner_ad()
	
	# Preload interstitial and rewarded ads
	admob.load_interstitial_ad()
	admob.load_rewarded_ad()

# Example: Show interstitial between game levels
func show_interstitial_between_levels():
	# This will automatically reload the ad after it's closed
	admob.load_and_show_interstitial_ad()

# Example: Show rewarded ad when player wants a bonus
func show_rewarded_for_bonus():
	# This will automatically reload the ad after it's closed
	admob.load_and_show_rewarded_ad()

# Signal handlers
func _on_interstitial_closed():
	print("Interstitial ad closed")
	# Game can continue here


func _on_rewarded_ad_closed():
	print("Rewarded ad closed")
	# Note: The reward is handled in _on_user_earned_reward

func _on_user_earned_reward(amount, type):
	print("User earned reward: ", amount, " ", type)
	# Give the player their reward here
