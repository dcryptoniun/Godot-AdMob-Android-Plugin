# Godot Android Plugin For Google AdMob
## Under development

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
function in [`plugin/export_scripts_template/export_plugin.gd`](plugin/export_scripts_template/export_plugin.gd). Note that debug geography values should use `OTHER` instead of the deprecated `NOT_EEA`.

##### Simplify access to the exposed Java / Kotlin APIs

To make it easier to access the exposed Java / Kotlin APIs in the Godot Editor, it's recommended to 
provide one (or multiple) gdscript wrapper class(es) for your plugin users to interface with.
