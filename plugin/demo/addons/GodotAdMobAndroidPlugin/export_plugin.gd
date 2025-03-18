@tool
extends EditorPlugin

# A class member to hold the editor export plugin during its lifecycle.
var export_plugin : AndroidExportPlugin

# AdMob Configuration UI elements
const SETTINGS_SECTION = "admob"

# Settings keys
const SETTINGS_APP_ID = "admob/app_id"
const SETTINGS_BANNER_AD_UNIT_ID = "admob/banner_ad_unit_id"
const SETTINGS_INTERSTITIAL_AD_UNIT_ID = "admob/interstitial_ad_unit_id"
const SETTINGS_REWARDED_AD_UNIT_ID = "admob/rewarded_ad_unit_id"
const SETTINGS_IS_REAL_ADS = "admob/is_real_ads"

# Configuration resource path
const CONFIG_RESOURCE_PATH = "res://addons/GodotAdMobAndroidPlugin/admob_config.tres"

# Configuration resource
var config_resource = null

# UI elements
var dock_scene: Control
var app_id_input: LineEdit
var banner_ad_unit_id_input: LineEdit
var interstitial_ad_unit_id_input: LineEdit
var rewarded_ad_unit_id_input: LineEdit
var real_ads_checkbox: CheckBox
var save_button: Button
var reset_button: Button

func _enter_tree():
	# Initialization of the export plugin
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)
	
	# Create the dock
	dock_scene = _create_dock()
	# Add the dock to the editor
	add_control_to_bottom_panel(dock_scene, "AdMob Config")
	
	# Register project settings if they don't exist (for backward compatibility)
	_register_project_settings()
	
	# Initialize configuration resource
	_initialize_config_resource()
	
	# Load settings into UI
	_load_settings()


func _exit_tree():
	# Clean-up of the export plugin
	remove_export_plugin(export_plugin)
	export_plugin = null
	
	# Remove the dock from the editor
	if dock_scene:
		remove_control_from_bottom_panel(dock_scene)
		dock_scene.queue_free()


# Create the dock UI
func _create_dock() -> Control:
	# Main container
	var dock = VBoxContainer.new()
	dock.name = "AdMobConfigDock"
	dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add some padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	dock.add_child(margin)
	
	# Main content container
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(content)
	
	# Title
	var title = Label.new()
	title.text = "AdMob Configuration"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	content.add_child(title)
	
	# Description
	var description = Label.new()
	description.text = "Configure your AdMob settings once and use them across all scenes."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(description)
	
	# Separator
	var separator = HSeparator.new()
	content.add_child(separator)
	
	# Create a horizontal split container for the two columns
	var split_container = HBoxContainer.new()
	split_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(split_container)
	
	# Left column for IDs
	var left_column = VBoxContainer.new()
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.name = "IDsColumn"
	split_container.add_child(left_column)
	
	# Add a title for the left column
	var ids_title = Label.new()
	ids_title.text = "Ad Unit IDs"
	ids_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_column.add_child(ids_title)
	
	# App ID
	var app_id_label = Label.new()
	app_id_label.text = "App ID:"
	left_column.add_child(app_id_label)
	
	app_id_input = LineEdit.new()
	app_id_input.placeholder_text = "Enter App ID"
	app_id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_child(app_id_input)
	
	# Banner Ad Unit ID
	var banner_ad_unit_id_label = Label.new()
	banner_ad_unit_id_label.text = "Banner Ad Unit ID:"
	left_column.add_child(banner_ad_unit_id_label)
	
	banner_ad_unit_id_input = LineEdit.new()
	banner_ad_unit_id_input.placeholder_text = "Enter Banner Ad Unit ID"
	banner_ad_unit_id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_child(banner_ad_unit_id_input)
	
	# Interstitial Ad Unit ID
	var interstitial_ad_unit_id_label = Label.new()
	interstitial_ad_unit_id_label.text = "Interstitial Ad Unit ID:"
	left_column.add_child(interstitial_ad_unit_id_label)
	
	interstitial_ad_unit_id_input = LineEdit.new()
	interstitial_ad_unit_id_input.placeholder_text = "Enter Interstitial Ad Unit ID"
	interstitial_ad_unit_id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_child(interstitial_ad_unit_id_input)
	
	# Rewarded Ad Unit ID
	var rewarded_ad_unit_id_label = Label.new()
	rewarded_ad_unit_id_label.text = "Rewarded Ad Unit ID:"
	left_column.add_child(rewarded_ad_unit_id_label)
	
	rewarded_ad_unit_id_input = LineEdit.new()
	rewarded_ad_unit_id_input.placeholder_text = "Enter Rewarded Ad Unit ID"
	rewarded_ad_unit_id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_column.add_child(rewarded_ad_unit_id_input)
	
	# Add a small separator between columns
	var column_separator = VSeparator.new()
	split_container.add_child(column_separator)
	
	# Right column for options
	var right_column = VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_column.name = "OptionsColumn"
	split_container.add_child(right_column)
	
	# Add a title for the right column
	var options_title = Label.new()
	options_title.text = "Options"
	options_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_column.add_child(options_title)
	
	# Add some spacing to align with the left column
	var spacing = Control.new()
	spacing.custom_minimum_size = Vector2(0, 10)
	right_column.add_child(spacing)
	
	# Real Ads Checkbox
	real_ads_checkbox = CheckBox.new()
	real_ads_checkbox.text = "Use Real Ads"
	real_ads_checkbox.button_pressed = false
	right_column.add_child(real_ads_checkbox)
	
	# Buttons container
	var buttons_container = HBoxContainer.new()
	buttons_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(buttons_container)
	
	# Save Button
	save_button = Button.new()
	save_button.text = "Save Settings"
	save_button.pressed.connect(_on_save_button_pressed)
	buttons_container.add_child(save_button)
	
	# Reset Button
	reset_button = Button.new()
	reset_button.text = "Reset to Defaults"
	reset_button.pressed.connect(_on_reset_button_pressed)
	buttons_container.add_child(reset_button)
	
	# Test Ads Info
	var test_ads_info = Label.new()
	test_ads_info.text = "Note: Test ads will be used if 'Use Real Ads' is unchecked."
	test_ads_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	test_ads_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(test_ads_info)
	
	return dock

# Register project settings if they don't exist
func _register_project_settings():
	# App ID
	if not ProjectSettings.has_setting(SETTINGS_APP_ID):
		ProjectSettings.set_setting(SETTINGS_APP_ID, "")
		ProjectSettings.set_initial_value(SETTINGS_APP_ID, "")
		ProjectSettings.add_property_info({
			"name": SETTINGS_APP_ID,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	
	# Banner Ad Unit ID
	if not ProjectSettings.has_setting(SETTINGS_BANNER_AD_UNIT_ID):
		ProjectSettings.set_setting(SETTINGS_BANNER_AD_UNIT_ID, "")
		ProjectSettings.set_initial_value(SETTINGS_BANNER_AD_UNIT_ID, "")
		ProjectSettings.add_property_info({
			"name": SETTINGS_BANNER_AD_UNIT_ID,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	
	# Interstitial Ad Unit ID
	if not ProjectSettings.has_setting(SETTINGS_INTERSTITIAL_AD_UNIT_ID):
		ProjectSettings.set_setting(SETTINGS_INTERSTITIAL_AD_UNIT_ID, "")
		ProjectSettings.set_initial_value(SETTINGS_INTERSTITIAL_AD_UNIT_ID, "")
		ProjectSettings.add_property_info({
			"name": SETTINGS_INTERSTITIAL_AD_UNIT_ID,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	
	# Rewarded Ad Unit ID
	if not ProjectSettings.has_setting(SETTINGS_REWARDED_AD_UNIT_ID):
		ProjectSettings.set_setting(SETTINGS_REWARDED_AD_UNIT_ID, "")
		ProjectSettings.set_initial_value(SETTINGS_REWARDED_AD_UNIT_ID, "")
		ProjectSettings.add_property_info({
			"name": SETTINGS_REWARDED_AD_UNIT_ID,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	
	# Is Real Ads
	if not ProjectSettings.has_setting(SETTINGS_IS_REAL_ADS):
		ProjectSettings.set_setting(SETTINGS_IS_REAL_ADS, false)
		ProjectSettings.set_initial_value(SETTINGS_IS_REAL_ADS, false)
		ProjectSettings.add_property_info({
			"name": SETTINGS_IS_REAL_ADS,
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": ""
		})
	
	# Save the project settings
	ProjectSettings.save()

# Load settings from configuration resource into UI
func _load_settings():
	if config_resource != null:
		# Load from resource
		app_id_input.text = config_resource.app_id
		banner_ad_unit_id_input.text = config_resource.banner_ad_unit_id
		interstitial_ad_unit_id_input.text = config_resource.interstitial_ad_unit_id
		rewarded_ad_unit_id_input.text = config_resource.rewarded_ad_unit_id
		real_ads_checkbox.button_pressed = config_resource.is_real_ads
	else:
		# Fallback to project settings for backward compatibility
		app_id_input.text = ProjectSettings.get_setting(SETTINGS_APP_ID, "")
		banner_ad_unit_id_input.text = ProjectSettings.get_setting(SETTINGS_BANNER_AD_UNIT_ID, "")
		interstitial_ad_unit_id_input.text = ProjectSettings.get_setting(SETTINGS_INTERSTITIAL_AD_UNIT_ID, "")
		rewarded_ad_unit_id_input.text = ProjectSettings.get_setting(SETTINGS_REWARDED_AD_UNIT_ID, "")
		real_ads_checkbox.button_pressed = ProjectSettings.get_setting(SETTINGS_IS_REAL_ADS, false)

# Save settings from UI to configuration resource
func _save_settings():
	# Create or update configuration resource
	if config_resource == null:
		config_resource = AdmobConfigResource.new()
	
	# Update resource with UI values
	config_resource.app_id = app_id_input.text
	config_resource.banner_ad_unit_id = banner_ad_unit_id_input.text
	config_resource.interstitial_ad_unit_id = interstitial_ad_unit_id_input.text
	config_resource.rewarded_ad_unit_id = rewarded_ad_unit_id_input.text
	config_resource.is_real_ads = real_ads_checkbox.button_pressed
	
	# Save to resource file
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("res://addons/GodotAdMobAndroidPlugin"):
		dir.make_dir_recursive("res://addons/GodotAdMobAndroidPlugin")
	
	var save_result = config_resource.save_to_file(CONFIG_RESOURCE_PATH)
	
	# Also save to project settings for backward compatibility
	ProjectSettings.set_setting(SETTINGS_APP_ID, app_id_input.text)
	ProjectSettings.set_setting(SETTINGS_BANNER_AD_UNIT_ID, banner_ad_unit_id_input.text)
	ProjectSettings.set_setting(SETTINGS_INTERSTITIAL_AD_UNIT_ID, interstitial_ad_unit_id_input.text)
	ProjectSettings.set_setting(SETTINGS_REWARDED_AD_UNIT_ID, rewarded_ad_unit_id_input.text)
	ProjectSettings.set_setting(SETTINGS_IS_REAL_ADS, real_ads_checkbox.button_pressed)
	ProjectSettings.save()
	
	# Show a confirmation message
	var accept_dialog = AcceptDialog.new()
	accept_dialog.title = "AdMob Settings"
	accept_dialog.dialog_text = "AdMob settings saved successfully!" + ("" if save_result else "\n(Warning: Could not save resource file)")
	accept_dialog.size = Vector2(300, 100)
	add_child(accept_dialog)
	accept_dialog.popup_centered()
	accept_dialog.confirmed.connect(func(): accept_dialog.queue_free())
	
	# Refresh the filesystem
	var editor_interface = Engine.get_singleton("EditorInterface")
	if editor_interface:
		editor_interface.get_resource_filesystem().scan()

# Button handlers
func _on_save_button_pressed():
	_save_settings()

# Reset settings to defaults
func _on_reset_button_pressed():
	# Reset to test ad IDs instead of empty values
	app_id_input.text = AdmobConfigResource.TEST_APP_ID
	banner_ad_unit_id_input.text = AdmobConfigResource.TEST_BANNER_AD_UNIT_ID
	interstitial_ad_unit_id_input.text = AdmobConfigResource.TEST_INTERSTITIAL_AD_UNIT_ID
	rewarded_ad_unit_id_input.text = AdmobConfigResource.TEST_REWARDED_AD_UNIT_ID
	real_ads_checkbox.button_pressed = false
	
	# Save the reset settings
	_save_settings()
	
	# Show a confirmation message
	var accept_dialog = AcceptDialog.new()
	accept_dialog.title = "AdMob Settings"
	accept_dialog.dialog_text = "AdMob settings reset to test IDs successfully!"
	accept_dialog.size = Vector2(300, 100)
	add_child(accept_dialog)
	accept_dialog.popup_centered()
	accept_dialog.confirmed.connect(func(): accept_dialog.queue_free())

# Initialize the configuration resource
func _initialize_config_resource():
	# Try to load existing resource
	if FileAccess.file_exists(CONFIG_RESOURCE_PATH):
		var resource = load(CONFIG_RESOURCE_PATH)
		if resource is AdmobConfigResource:
			config_resource = resource
			return
	
	# If no resource exists, create a new one
	config_resource = AdmobConfigResource.new()
	
	# Try to import values from project settings if they exist
	if ProjectSettings.has_setting(SETTINGS_APP_ID):
		config_resource.app_id = ProjectSettings.get_setting(SETTINGS_APP_ID, "")
		config_resource.banner_ad_unit_id = ProjectSettings.get_setting(SETTINGS_BANNER_AD_UNIT_ID, "")
		config_resource.interstitial_ad_unit_id = ProjectSettings.get_setting(SETTINGS_INTERSTITIAL_AD_UNIT_ID, "")
		config_resource.rewarded_ad_unit_id = ProjectSettings.get_setting(SETTINGS_REWARDED_AD_UNIT_ID, "")
		config_resource.is_real_ads = ProjectSettings.get_setting(SETTINGS_IS_REAL_ADS, false)

# Android Export Plugin class
class AndroidExportPlugin extends EditorExportPlugin:
	
	var _plugin_name = "GodotAdMobAndroidPlugin"

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
		
	# Override this method to inject the AdMob app ID into the project's AndroidManifest.xml
	func _get_android_manifest_xml_features(platform, debug):
		# Get the app ID from the configuration resource or project settings
		var app_id = ""
		
		# Try to load from config resource file first
		if FileAccess.file_exists(CONFIG_RESOURCE_PATH):
			var resource = load(CONFIG_RESOURCE_PATH)
			if resource and resource.get("app_id"):
				app_id = resource.get("app_id")
		
		# Fallback to project settings if no valid resource or empty app ID
		if app_id.is_empty() and ProjectSettings.has_setting("admob/app_id"):
			app_id = ProjectSettings.get_setting("admob/app_id", "")
		
		# Use test app ID if no valid app ID is found or if not using real ads
		var is_real_ads = false
		if FileAccess.file_exists(CONFIG_RESOURCE_PATH):
			var resource = load(CONFIG_RESOURCE_PATH)
			if resource and resource.get("is_real_ads") != null:
				is_real_ads = resource.get("is_real_ads")
		elif ProjectSettings.has_setting("admob/is_real_ads"):
			is_real_ads = ProjectSettings.get_setting("admob/is_real_ads", false)
		
		if not is_real_ads or app_id.is_empty():
			app_id = "ca-app-pub-3940256099942544~3347511713" # Test app ID
		
		# Add the AdMob app ID to the manifest
		return "<meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"" + app_id + "\" />"
