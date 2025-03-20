@tool
extends EditorPlugin

# A class member to hold the editor export plugin during its lifecycle.
var export_plugin : AndroidExportPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)
	
	# Register AdMob as an autoload singleton
	add_autoload_singleton("AdMob", "res://addons/GodotAdMobAndroidPlugin/AdMob.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(export_plugin)
	export_plugin = null
	
	# Remove the autoload singleton
	remove_autoload_singleton("AdMob")



class AndroidExportPlugin extends EditorExportPlugin:
	
	var _plugin_name = "GodotAdMobAndroidPlugin"
	const CONFIG_RESOURCE_PATH = "res://addons/GodotAdMobAndroidPlugin/admob_config.tres"

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if debug:
			return PackedStringArray([_plugin_name + "/bin/debug/" + _plugin_name + "-debug.aar"])
		else:
			return PackedStringArray([_plugin_name + "/bin/release/" + _plugin_name + "-release.aar"])

	func _get_android_dependencies(platform, debug):
		# TODO: Add remote dependices here.
		if debug:
			return PackedStringArray(["com.google.android.ump:user-messaging-platform:3.1.0",
			"com.google.android.gms:play-services-ads:24.1.0"])
		else:
			return PackedStringArray(["com.google.android.ump:user-messaging-platform:3.1.0",
			"com.google.android.gms:play-services-ads:24.1.0"])

	func _get_name():
		return _plugin_name
		
	func _get_android_manifest_xml_features(platform, debug):
		var app_id = ""
		
		# Try to load from config resource file
		if FileAccess.file_exists(CONFIG_RESOURCE_PATH):
			var config = load(CONFIG_RESOURCE_PATH) as AdmobConfig
			if config and config.app_id:
				app_id = config.app_id
		
		# Return the manifest XML feature
		return '<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="' + app_id + '" />'
