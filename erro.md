Incident Identifier: D53715AB-4CBC-44F3-A279-E96CB28D6162
Distributor ID:      com.apple.TestFlight
Hardware Model:      iPhone13,1
Process:             Runner [722]
Path:                /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Runner
Identifier:          com.huanyun.news
Version:             1.0.0 (1)
AppStoreTools:       17C503a
AppVariant:          1:iPhone13,1:18
Beta:                YES
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           com.huanyun.news [793]

Date/Time:           2026-02-10 17:04:11.5858 +0800
Launch Time:         2026-02-10 17:04:11.5155 +0800
OS Version:          iPhone OS 18.6.2 (22G100)
Release Type:        User
Baseband Version:    5.70.01
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
Exception Codes: 0x0000000000000001, 0x0000000000000000
VM Region Info: 0 is not in any region.  Bytes before following region: 4300144640
      REGION TYPE                 START - END      [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                   1004f0000-1004f4000 [   16K] r-x/r-x SM=COW  /var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Runner
Termination Reason: SIGNAL 11 Segmentation fault: 11
Terminating Process: exc handler [722]

Triggered by Thread:  0


Thread 0 name:
Thread 0 Crashed:
0   libswiftCore.dylib            	0x0000000186b3ee54 swift_getObjectType + 40 (SwiftObject.mm:137)
1   record_darwin                 	0x00000001005c8920 0x1005b0000 + 100640
2   record_darwin                 	0x00000001005c8ba8 0x1005b0000 + 101288
3   record_darwin                 	0x00000001005b4048 0x1005b0000 + 16456
4   Runner                        	0x00000001004f41a0 0x1004f0000 + 16800
5   Runner                        	0x00000001004f43f8 0x1004f0000 + 17400
6   Runner                        	0x00000001004f46fc 0x1004f0000 + 18172
7   UIKitCore                     	0x000000018aac7e0c -[UIApplication _handleDelegateCallbacksWithOptions:isSuspended:restoreState:] + 320 (UIApplication.m:2582)
8   UIKitCore                     	0x000000018aac9990 -[UIApplication _callInitializationDelegatesWithActions:forCanvas:payload:fromOriginatingProcess:] + 2988 (UIApplication.m:3018)
9   UIKitCore                     	0x000000018aac5908 -[UIApplication _runWithMainScene:transitionContext:completion:] + 972 (UIApplication.m:4933)
10  UIKitCore                     	0x000000018aac5474 -[_UISceneLifecycleMultiplexer completeApplicationLaunchWithFBSScene:transitionContext:] + 132 (_UISceneLifecycleMultiplexer.m:452)
11  UIKitCore                     	0x000000018aafc46c _UIScenePerformActionsWithLifecycleActionMask + 112 (_UISceneLifecycleState.m:109)
12  UIKitCore                     	0x000000018ab00870 __101-[_UISceneLifecycleMultiplexer _evalTransitionToSettings:fromSettings:forceExit:withTransitionStore:]_block_invoke + 252 (_UISceneLifecycleMultiplexer.m:568)
13  UIKitCore                     	0x000000018ab005e0 -[_UISceneLifecycleMultiplexer _performBlock:withApplicationOfDeactivationReasons:fromReasons:] + 212 (_UISceneLifecycleMultiplexer.m:517)
14  UIKitCore                     	0x000000018ab002c8 -[_UISceneLifecycleMultiplexer _evalTransitionToSettings:fromSettings:forceExit:withTransitionStore:] + 608 (_UISceneLifecycleMultiplexer.m:567)
15  UIKitCore                     	0x000000018aafff30 -[_UISceneLifecycleMultiplexer uiScene:transitionedFromState:withTransitionContext:] + 244 (_UISceneLifecycleMultiplexer.m:470)
16  UIKitCore                     	0x000000018aafca5c __186-[_UIWindowSceneFBSSceneTransitionContextDrivenLifecycleSettingsDiffAction _performActionsForUIScene:withUpdatedFBSScene:settingsDiff:fromSettings:transitionContext:lifecycleActionType:]_block... + 148 (_UIWindowSceneFBSSceneTransitionContextDrivenLifecycleSettingsDiffAction.m:73)
17  UIKitCore                     	0x000000018aafd078 +[BSAnimationSettings(UIKit) tryAnimatingWithSettings:fromCurrentState:actions:completion:] + 736 (BSAnimationSettings+UIKit.m:54)
18  UIKitCore                     	0x000000018aafc99c _UISceneSettingsDiffActionPerformChangesWithTransitionContextAndCompletion + 224 (_UISceneSettingsDiffAction.m:27)
19  UIKitCore                     	0x000000018aafc64c -[_UIWindowSceneFBSSceneTransitionContextDrivenLifecycleSettingsDiffAction _performActionsForUIScene:withUpdatedFBSScene:settingsDiff:fromSettings:transitionContext:lifecycleActionType:] + 316 (_UIWindowSceneFBSSceneTransitionContextDrivenLifecycleSettingsDiffAction.m:58)
20  UIKitCore                     	0x000000018aafc224 __64-[UIScene scene:didUpdateWithDiff:transitionContext:completion:]_block_invoke.229 + 616 (UIScene.m:2112)
21  UIKitCore                     	0x000000018aafbb7c -[UIScene _emitSceneSettingsUpdateResponseForCompletion:afterSceneUpdateWork:] + 208 (UIScene.m:1771)
22  UIKitCore                     	0x000000018aafb9f4 -[UIScene scene:didUpdateWithDiff:transitionContext:completion:] + 244 (UIScene.m:2071)
23  UIKitCore                     	0x000000018aacb770 -[UIApplication workspace:didCreateScene:withTransitionContext:completion:] + 764 (UIApplication.m:4370)
24  UIKitCore                     	0x000000018aacb408 -[UIApplicationSceneClientAgent scene:didInitializeWithEvent:completion:] + 288 (UIApplicationSceneClientAgent.m:47)
25  FrontBoardServices            	0x00000001a2613528 __95-[FBSScene _callOutQueue_didCreateWithTransitionContext:alternativeCreationCallout:completion:]_block_invoke + 288 (FBSScene.m:700)
26  FrontBoardServices            	0x00000001a26136fc -[FBSScene _callOutQueue_coalesceClientSettingsUpdates:] + 68 (FBSScene.m:763)
27  FrontBoardServices            	0x00000001a261334c -[FBSScene _callOutQueue_didCreateWithTransitionContext:alternativeCreationCallout:completion:] + 436 (FBSScene.m:687)
28  FrontBoardServices            	0x00000001a2612ecc __93-[FBSWorkspaceScenesClient _callOutQueue_sendDidCreateForScene:transitionContext:completion:]_block_invoke.197 + 288 (FBSWorkspaceScenesClient.m:703)
29  FrontBoardServices            	0x00000001a2612d38 -[FBSWorkspace _calloutQueue_executeCalloutFromSource:withBlock:] + 168 (FBSWorkspace.m:445)
30  FrontBoardServices            	0x00000001a2612ac0 -[FBSWorkspaceScenesClient _callOutQueue_sendDidCreateForScene:transitionContext:completion:] + 472 (FBSWorkspaceScenesClient.m:700)
31  libdispatch.dylib             	0x0000000190048584 _dispatch_client_callout + 16 (client_callout.mm:85)
32  libdispatch.dylib             	0x0000000190033ab0 _dispatch_block_invoke_direct + 284 (queue.c:515)
33  FrontBoardServices            	0x00000001a26128ac __FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 52 (FBSSerialQueue.m:285)
34  FrontBoardServices            	0x00000001a2612748 -[FBSMainRunLoopSerialQueue _targetQueue_performNextIfPossible] + 240 (FBSSerialQueue.m:309)
35  FrontBoardServices            	0x00000001a26127b0 -[FBSMainRunLoopSerialQueue _performNextFromRunLoopSource] + 28 (FBSSerialQueue.m:322)
36  CoreFoundation                	0x00000001880a192c __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 28 (CFRunLoop.c:1970)
37  CoreFoundation                	0x00000001880a1744 __CFRunLoopDoSource0 + 172 (CFRunLoop.c:2014)
38  CoreFoundation                	0x00000001880a15a0 __CFRunLoopDoSources0 + 232 (CFRunLoop.c:2051)
39  CoreFoundation                	0x00000001880a1f20 __CFRunLoopRun + 840 (CFRunLoop.c:2969)
40  CoreFoundation                	0x00000001880a3adc CFRunLoopRunSpecific + 572 (CFRunLoop.c:3434)
41  GraphicsServices              	0x00000001d4ec9454 GSEventRunModal + 168 (GSEvent.c:2196)
42  UIKitCore                     	0x000000018aac5274 -[UIApplication _run] + 816 (UIApplication.m:3845)
43  UIKitCore                     	0x000000018aa90a28 UIApplicationMain + 336 (UIApplication.m:5540)
44  UIKitCore                     	0x000000018ab72168 UIApplicationMain(_:_:_:_:) + 104 (UIKit.swift:565)
45  Runner                        	0x00000001004f48c8 0x1004f0000 + 18632
46  Runner                        	0x00000001004f4838 0x1004f0000 + 18488
47  Runner                        	0x00000001004f4944 0x1004f0000 + 18756
48  dyld                          	0x00000001aeb35f08 start + 6040 (dyldMain.cpp:1450)

Thread 1:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 2:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 3 name:
Thread 3:
0   libsystem_kernel.dylib        	0x00000001d8f03f70 __ulock_wait + 8
1   libdispatch.dylib             	0x0000000190030c3c _dlock_wait + 56 (lock.c:326)
2   libdispatch.dylib             	0x0000000190030a5c _dispatch_thread_event_wait_slow + 56 (lock.c:558)
3   libdispatch.dylib             	0x000000019003ea08 __DISPATCH_WAIT_FOR_QUEUE__ + 368 (queue.c:1702)
4   libdispatch.dylib             	0x000000019003e5c0 _dispatch_sync_f_slow + 148 (queue.c:1799)
5   UIKitCore                     	0x000000018ab604c4 __37-[_UIRemoteKeyboards startConnection]_block_invoke.430 + 144 (_UIRemoteKeyboards.m:1273)
6   CoreFoundation                	0x00000001880c1934 __invoking___ + 148
7   CoreFoundation                	0x00000001880c0fac -[NSInvocation invoke] + 424 (NSForwarding.m:3411)
8   Foundation                    	0x0000000186d32508 <deduplicated_symbol> + 16
9   Foundation                    	0x0000000186d5edd8 -[NSXPCConnection _decodeAndInvokeReplyBlockWithEvent:sequence:replyInfo:] + 532 (NSXPCConnection.m:313)
10  Foundation                    	0x0000000186d5e730 __88-[NSXPCConnection _sendInvocation:orArguments:count:methodSignature:selector:withProxy:]_block_invoke_5 + 188 (NSXPCConnection.m:1657)
11  libxpc.dylib                  	0x000000021259ab0c _xpc_connection_reply_callout + 124 (serializer.c:119)
12  libxpc.dylib                  	0x000000021258d200 _xpc_connection_call_reply_async + 96 (connection.c:899)
13  libdispatch.dylib             	0x00000001900485b4 <deduplicated_symbol> + 16
14  libdispatch.dylib             	0x000000019004c594 _dispatch_mach_msg_async_reply_invoke + 340 (mach.c:3119)
15  libdispatch.dylib             	0x0000000190037138 _dispatch_lane_serial_drain + 332 (queue.c:3939)
16  libdispatch.dylib             	0x0000000190037de0 _dispatch_lane_invoke + 440 (queue.c:4030)
17  libdispatch.dylib             	0x00000001900421dc _dispatch_root_queue_drain_deferred_wlh + 292 (queue.c:7198)
18  libdispatch.dylib             	0x0000000190041a60 _dispatch_workloop_worker_thread + 540 (queue.c:6792)
19  libsystem_pthread.dylib       	0x0000000212530a0c _pthread_wqthread + 292 (pthread.c:2696)
20  libsystem_pthread.dylib       	0x0000000212530aac start_wqthread + 8

Thread 4:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 5:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 6:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 7:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 8:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 9 name:
Thread 9:
0   libsystem_kernel.dylib        	0x00000001d8efdce4 mach_msg2_trap + 8
1   libsystem_kernel.dylib        	0x00000001d8f0139c mach_msg2_internal + 76 (mach_msg.c:201)
2   libsystem_kernel.dylib        	0x00000001d8f012b8 mach_msg_overwrite + 428 (mach_msg.c:0)
3   libsystem_kernel.dylib        	0x00000001d8f01100 mach_msg + 24 (mach_msg.c:323)
4   CoreFoundation                	0x00000001880a37a0 __CFRunLoopServiceMachPort + 160 (CFRunLoop.c:2637)
5   CoreFoundation                	0x00000001880a2090 __CFRunLoopRun + 1208 (CFRunLoop.c:3021)
6   CoreFoundation                	0x00000001880a3adc CFRunLoopRunSpecific + 572 (CFRunLoop.c:3434)
7   Foundation                    	0x0000000186d1a79c -[NSRunLoop(NSRunLoop) runMode:beforeDate:] + 212 (NSRunLoop.m:375)
8   Foundation                    	0x0000000186d20020 -[NSRunLoop(NSRunLoop) runUntilDate:] + 64 (NSRunLoop.m:422)
9   UIKitCore                     	0x000000018aaaf56c -[UIEventFetcher threadMain] + 424 (UIEventFetcher.m:1351)
10  Foundation                    	0x0000000186d80804 __NSThread__start__ + 732 (NSThread.m:991)
11  libsystem_pthread.dylib       	0x0000000212533344 _pthread_start + 136 (pthread.c:931)
12  libsystem_pthread.dylib       	0x0000000212530ab8 thread_start + 8

Thread 10:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0

Thread 11:
0   libsystem_pthread.dylib       	0x0000000212530aa4 start_wqthread + 0


Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x00000001004fddee   x2: 0x0000000000000000   x3: 0xfffff0007fc00000
    x4: 0x0000000138036340   x5: 0x0000000000000000   x6: 0x000000000011e014   x7: 0xdec3287717be65c8
    x8: 0x0000000000000000   x9: 0x0000000000000103  x10: 0x00000001005de5b0  x11: 0x0000000000000000
   x12: 0x00000001004fddee  x13: 0xfffffffdfe000000  x14: 0x00000001f2904008  x15: 0x0000000200000000
   x16: 0x0000000186b3ee2c  x17: 0x00000001005c8b70  x18: 0x0000000000000000  x19: 0x0000000000000000
   x20: 0x00000001005de690  x21: 0x0000000000000001  x22: 0x0000000000000001  x23: 0x0000000000000000
   x24: 0x0000000000000001  x25: 0x00000001f2c77000  x26: 0x00000001f0840000  x27: 0x000000002b870064
   x28: 0x0000000000000010   fp: 0x000000016f90ca30   lr: 0x00000001005c8920
    sp: 0x000000016f90ca20   pc: 0x0000000186b3ee54 cpsr: 0x80001000
   esr: 0x92000006 (Data Abort) byte read Translation fault


Binary Images:
        0x1004f0000 -         0x1004fffff Runner arm64  <29cd34d48cbf370ebb7e151bc7c1b6f6> /var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Runner
        0x10054c000 -         0x100557fff Toast arm64  <82f18e99329f3bcf90178418533a664f> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/Toast.framework/Toast
        0x100568000 -         0x10056ffff device_info_plus arm64  <edf9c23358e835c2b47522b5934a5f80> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/device_info_plus.framework/device_info_plus
        0x100580000 -         0x100587fff fluttertoast arm64  <6110ae098b6a35bcbc6903d540caaf1b> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/fluttertoast.framework/fluttertoast
        0x100598000 -         0x10059ffff package_info_plus arm64  <2b05e3343f363b4792d9e12c66c13be2> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/package_info_plus.framework/package_info_plus
        0x1005b0000 -         0x1005d7fff record_darwin arm64  <e426a4f011a8336a8b64d5e74a668853> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/record_darwin.framework/record_darwin
        0x10061c000 -         0x100633fff shared_preferences_foundation arm64  <5bc5805c4f6a3b9898c06f4da6661c1d> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/shared_preferences_foundation.framework/shared_preferences_foundation
        0x100660000 -         0x100683fff sqflite_darwin arm64  <f40e456fa6fc303489eda49e0caa4dbc> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/sqflite_darwin.framework/sqflite_darwin
        0x1006b0000 -         0x1006c7fff url_launcher_ios arm64  <82c4e03943163886961bb09c399f5209> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/url_launcher_ios.framework/url_launcher_ios
        0x1006f4000 -         0x100713fff video_player_avfoundation arm64  <c0edf46a055136fb8290e4281468f22f> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/video_player_avfoundation.framework/video_player_avfoundation
        0x100740000 -         0x100747fff wakelock_plus arm64  <82d4b8558fcd3e9cac31af53dd3cb44b> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/wakelock_plus.framework/wakelock_plus
        0x1009e0000 -         0x100a93fff webview_flutter_wkwebview arm64  <261f20afa7cf336ea5bd45ef61f07ac3> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/webview_flutter_wkwebview.framework/webview_flutter_wkwebview
        0x100ba8000 -         0x102ac7fff Flutter arm64  <4c4c44e055553144a15ef4f13d8a01cb> /private/var/containers/Bundle/Application/90E7A247-B110-4C2A-A3EA-22625338C0A4/Runner.app/Frameworks/Flutter.framework/Flutter
        0x1039b8000 -         0x1039c3fff libobjc-trampolines.dylib arm64e  <def9fca06da1332796903b879ffc755c> /private/preboot/Cryptexes/OS/usr/lib/libobjc-trampolines.dylib
        0x186745000 -         0x186cae29f libswiftCore.dylib arm64e  <4a7bace5ee57375ab860cd7f1ca9e6af> /usr/lib/swift/libswiftCore.dylib
        0x186d0b000 -         0x18797f05f Foundation arm64e  <c031896b2ef13d89966a0b52d54bceee> /System/Library/Frameworks/Foundation.framework/Foundation
        0x188092000 -         0x18860efff CoreFoundation arm64e  <ae3c93380166397a9643356b14f6ee58> /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
        0x18a990000 -         0x18c8d255f UIKitCore arm64e  <5e794caa41623ff6861e45f29f6b8ac0> /System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore
        0x19002d000 -         0x190072b3f libdispatch.dylib arm64e  <b62778f758273a7ba96da24f7be95416> /usr/lib/system/libdispatch.dylib
        0x1a25f4000 -         0x1a26c78bf FrontBoardServices arm64e  <1d4f7bf8ca623218a0749187a2d191ae> /System/Library/PrivateFrameworks/FrontBoardServices.framework/FrontBoardServices
        0x1aeaf7000 -         0x1aeb9187b dyld arm64e  <cd2e758de1a23b92aae775d38f66ec54> /usr/lib/dyld
        0x1d4ec8000 -         0x1d4ed0c7f GraphicsServices arm64e  <d372e13f75053addae13062656f0b1f6> /System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices
        0x1d8efd000 -         0x1d8f36ebf libsystem_kernel.dylib arm64e  <a9a7ecbd24dd37e6bb23ecbfd9a87e33> /usr/lib/system/libsystem_kernel.dylib
        0x212530000 -         0x21253c3f3 libsystem_pthread.dylib arm64e  <1ee1922008593cbcbdebdf37ca2e8e4f> /usr/lib/system/libsystem_pthread.dylib
        0x21257b000 -         0x2125c2dbf libxpc.dylib arm64e  <6e4f2f21192a30e8a3ad9915add1ebd2> /usr/lib/system/libxpc.dylib

EOF
