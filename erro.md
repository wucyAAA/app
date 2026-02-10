  /Applications/Xcode-26.2.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/CoreTelephony.framework/Headers/CTTelephonyNetworkInfo.h:114:50: note: 'subscriberCellularProvider' has been explicitly marked deprecated here
    1 warning generated.
    /Users/builder/.pub-cache/hosted/pub.dev/record_darwin-1.2.2/ios/Classes/RecorderIOS.swift:15:70: warning: 'allowBluetooth' was deprecated in iOS 8.0: renamed to 'AVAudioSession.CategoryOptions.allowBluetoothHFP'
      let options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetooth]
                                                                         ^
    /Users/builder/.pub-cache/hosted/pub.dev/record_darwin-1.2.2/ios/Classes/RecorderIOS.swift:15:70: note: use 'AVAudioSession.CategoryOptions.allowBluetoothHFP' instead
      let options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetooth]
                                                                         ^~~~~~~~~~~~~~
                                                                         AVAudioSession.CategoryOptions.allowBluetoothHFP
    /Users/builder/.pub-cache/hosted/pub.dev/record_darwin-1.2.2/ios/Classes/RecordConfig.swift:84:12: warning: 'allowBluetooth' was deprecated in iOS 8.0: renamed to 'AVAudioSession.CategoryOptions.allowBluetoothHFP'
              .allowBluetooth
               ^
    /Users/builder/.pub-cache/hosted/pub.dev/record_darwin-1.2.2/ios/Classes/RecordConfig.swift:84:12: note: use 'AVAudioSession.CategoryOptions.allowBluetoothHFP' instead
              .allowBluetooth
               ^~~~~~~~~~~~~~
               AVAudioSession.CategoryOptions.allowBluetoothHFP
    warning: Flutter archive not built in Release mode. Ensure FLUTTER_BUILD_MODE is set to release or run "flutter build ios --release", then re-run Archive from Xcode.
    Failed to parse TARGET_DEVICE_OS_VERSION: 
    ../.pub-cache/hosted/pub.dev/record_linux-0.7.2/lib/record_linux.dart:12:7: Error: The non-abstract class 'RecordLinux' is missing implementations for these members:
     - RecordMethodChannelPlatformInterface.startStream
    Try to either
     - provide an implementation,
     - inherit an implementation from a superclass or mixin,
     - mark the class as abstract, or
     - provide a 'noSuchMethod' implementation.
    class RecordLinux extends RecordPlatform {
          ^^^^^^^^^^^
    ../.pub-cache/hosted/pub.dev/record_platform_interface-1.5.0/lib/src/record_platform_interface.dart:46:29: Context: 'RecordMethodChannelPlatformInterface.startStream' is defined here.
      Future<Stream<Uint8List>> startStream(String recorderId, RecordConfig config);
                                ^^^^^^^^^^^
    ../.pub-cache/hosted/pub.dev/record_linux-0.7.2/lib/record_linux.dart:36:16: Error: The method 'RecordLinux.hasPermission' has fewer named arguments than those of overridden method 'RecordMethodChannelPlatformInterface.hasPermission'.
      Future<bool> hasPermission(String recorderId) {
                   ^
    ../.pub-cache/hosted/pub.dev/record_platform_interface-1.5.0/lib/src/record_platform_interface.dart:74:16: Context: This is the overridden method ('hasPermission').
      Future<bool> hasPermission(String recorderId, {bool request = true});
                   ^
    Target kernel_snapshot_program failed: Exception
    Failed to package /Users/builder/clone.
    Command PhaseScriptExecution failed with a nonzero exit code
    note: Run script build phase 'Run Script' will be run during every build because the option to run the script phase "Based on dependency analysis" is unchecked. (in target 'Runner' from project 'Runner')
    note: Run script build phase 'Thin Binary' will be run during every build because the option to run the script phase "Based on dependency analysis" is unchecked. (in target 'Runner' from project 'Runner')
    /Users/builder/clone/ios/Pods/Pods.xcodeproj: warning: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported deployment target versions is 12.0 to 26.2.99. (in target 'record_darwin-record_darwin_privacy' from project 'Pods')
    /Users/builder/clone/ios/Pods/Pods.xcodeproj: warning: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 9.0, but the range of supported deployment target versions is 12.0 to 26.2.99. (in target 'permission_handler_apple-permission_handler_apple_privacy' from project 'Pods')

Encountered error while archiving for device.


Build failed :|
Failed to build for iOS