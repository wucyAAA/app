PS C:\Users\user\Desktop\huanyun_app>  flutter run -d chrome --web-browser-flag "--disable-web-security"
Flutter assets will be downloaded from https://mirrors.tuna.tsinghua.edu.cn/flutter. Make sure you trust this source!
Launching lib\main.dart on Chrome in debug mode...
lib/theme/app_theme.dart:113:18: Error: Method not found: 'CardThemeData'.
      cardTheme: CardThemeData(
                 ^^^^^^^^^^^^^
lib/theme/app_theme.dart:228:18: Error: Method not found: 'CardThemeData'.
      cardTheme: CardThemeData(
                 ^^^^^^^^^^^^^
../../AppData/Local/Pub/Cache/hosted/mirrors.tuna.tsinghua.edu.cn%2547dart-pub%2547/record_web-1.3.0/lib/recorder/delegate/mic_recorder_delegate.dart:168:44: Error:
The getter 'streamBufferSize' isn't defined for the class 'RecordConfig'.
 - 'RecordConfig' is from 'package:record_platform_interface/src/types/record_config.dart'
 ('../../AppData/Local/Pub/Cache/hosted/mirrors.tuna.tsinghua.edu.cn%2547dart-pub%2547/record_platform_interface-1.1.0/lib/src/types/record_config.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'streamBufferSize'.
          'streamBufferSize'.toJS: (config.streamBufferSize ?? 2048).toJS,
                                           ^^^^^^^^^^^^^^^^
Waiting for connection from debug service on Chrome...             30.3s