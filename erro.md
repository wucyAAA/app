══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following StateError was thrown building MidPageScreen(dirty, dependencies:
[InheritedCupertinoTheme, _InheritedTheme, _LocalizationsScope-[GlobalKey#aa3f4]], state:
_MidPageScreenState#d2baf):
Bad state: Cannot use origin without a scheme:

The relevant error-causing widget was:
  MidPageScreen
  MidPageScreen:file:///C:/Users/user/Desktop/huanyun_app/lib/router/app_router.dart:130:18

When the exception was thrown, this was the stack:
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 296:3     throw_
dart-sdk/lib/core/uri.dart 4553:7                                               get origin
packages/huanyun_app/screens/mid_page_screen.dart 409:84                        <fn>
packages/huanyun_app/screens/mid_page_screen.dart 429:33                        [_buildContent]
packages/huanyun_app/screens/mid_page_screen.dart 270:15                        build
packages/flutter/src/widgets/framework.dart 5729:27                             build
packages/flutter/src/widgets/framework.dart 5617:15                             performRebuild
packages/flutter/src/widgets/framework.dart 5780:11                             performRebuild
packages/flutter/src/widgets/framework.dart 5333:7                              rebuild
packages/flutter/src/widgets/framework.dart 2693:14                             [_tryRebuild]
packages/flutter/src/widgets/framework.dart 2752:11                             [_flushDirtyElements]
packages/flutter/src/widgets/framework.dart 3048:17                             buildScope
packages/flutter/src/widgets/binding.dart 1162:9                                drawFrame
packages/flutter/src/rendering/binding.dart 468:5                               [_handlePersistentFrameCallback]
packages/flutter/src/scheduler/binding.dart 1397:7                              [_invokeFrameCallback]
packages/flutter/src/scheduler/binding.dart 1318:9                              handleDrawFrame
packages/flutter/src/scheduler/binding.dart 1176:5                              [_handleDrawFrame]
lib/_engine/engine/platform_dispatcher.dart 1408:5                              invoke
lib/_engine/engine/platform_dispatcher.dart 310:5                               invokeOnDrawFrame
lib/_engine/engine/initialization.dart 187:36                                   <fn>
dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 188:27  _callDartFunctionFast1

════════════════════════════════════════════════════════════════════════════════════════════════════