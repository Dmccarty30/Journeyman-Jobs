# SCRATCHPAD

- **Light Theme** - Quite Light
- **Dark Theme** -Blueberry Bannana

## DATABSE COLLECTIONS

- **User Collection**

- firstName
- lastName
- phoneNumber
- address
- city
- state
- zipcode
- email
- password
- ticketNumber
- homeLocal
- classification
- curentlyWorking
- booksOn
- careerGoals
- howHeardAboutUs
- lookingToAccomplish

- **User Preferences Collection**

- constructionTypes
- HoursPerWeek
- PerDiem
- preferredLocals ==> This is a trick field so the user is going to put down their preferred locals Where they want to work and it's going to become a separated So we need to somehow figure out how to separate or you know in the in the recommended jobs or suggested jobs We're gonna have to separate these locals or understand that this isn't just one preference it's several preferences depending on how many locals they put in the text field

---

## I'm bored and things need to change it from dark to light

- Still getting the same error when i press create a crew button to `app exception on an unexpected error occurede while getting user crews converting objects to an encodable object that is instant of timestamp`
After identifying the root cause of the "create crew" issue, and the correction has been implemented. I need you to ensure that the `job preferences dialog popup` appears immediately after the user has created the crew.

- **Workflow Command**

- /sc:workflow create crew error --strategy systematic --depth deep --parallel

- **Workflow Flags**

## Sub-Agent Delegation Flags

 /superclaude:analyze --uc --ultrathink --all-mcp --persona-analyzer --delegate auto --concurrency [10] --wave-mode force --wave-strategy systematic --wave-delegation tasks --scope module --focus architecture --introspect --parallel

## CREW PREFERENCES DIALOG

- **App Bar**
- The text is too large, or long, or something, you can only read " Set Cre..." maybe decrease the font size of the text

- **App Theme**
- Only a partial implementation of the dialog popup theme

-**Construction Types**

- **REMOVE**
- `Minimum Hourly Rate` and `Maximum Distance`
- `Match Threshold`

- **MODIFY**
- `Prefered Companies` Replace with `Prefered Locals`

- **ADD**


---

## TERMINAL OUTPUT

D/nativeloader(12428): Extending system_exposed_libraries: libhumantracking.arcsoft.so:libPortraitDistortionCorrection.arcsoft.so:libPortraitDistortionCorrectionCali.arcsoft.so:libface_landmark.arcsoft.so:libFacialStickerEngine.arcsoft.so:libfrtracking_engine.arcsoft.so:libFaceRecognition.arcsoft.so:libveengine.arcsoft.so:lib_pet_detection.arcsoft.so:libae_bracket_hdr.arcsoft.so:libhigh_res.arcsoft.so:libhybrid_high_dynamic_range.arcsoft.so:libimage_enhancement.arcsoft.so:liblow_light_hdr.arcsoft.so:libhigh_dynamic_range.arcsoft.so:libsuperresolution_raw.arcsoft.so:libuwsuperresolution.arcsoft.so:libobjectcapture_jni.arcsoft.so:libobjectcapture.arcsoft.so:libFacialAttributeDetection.arcsoft.so:libaudiomirroring_jni.audiomirroring.samsung.so:libBeauty_v4.camera.samsung.so:libexifa.camera.samsung.so:libjpega.camera.samsung.so:libOpenCv.camera.samsung.so:libC2paDps.camera.samsung.so:libVideoClassifier.camera.samsung.so:libImageScreener.camera.samsung.so:libMyFilter.camera.samsung.so:libtflite2.myfilters.camera.samsung.so:libHIDTSnapJ
I/flutter (12428): User granted permission
D/ApplicationLoaders(12428): Returning zygote-cached class loader: /system_ext/framework/androidx.window.extensions.jar
D/ApplicationLoaders(12428): Returning zygote-cached class loader: /system_ext/framework/androidx.window.sidecar.jar
W/.journeymanjobs(12428): Loading /data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/oat/arm64/base.odex non-executable as it requires an image which we failed to load
D/nativeloader(12428): Configuring clns-14 for other apk /data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/base.apk. target_sdk_version=36, uses_libraries=, library_path=/data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/lib/arm64:/data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/base.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand:/data/user/0/com.google.android.gms
E/GoogleApiManager(12428): Failed to get service from broker. 
E/GoogleApiManager(12428): java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
E/GoogleApiManager(12428):      at android.os.Parcel.createExceptionOrNull(Parcel.java:3257)
E/GoogleApiManager(12428):      at android.os.Parcel.createException(Parcel.java:3241)
E/GoogleApiManager(12428):      at android.os.Parcel.readException(Parcel.java:3224)
E/GoogleApiManager(12428):      at android.os.Parcel.readException(Parcel.java:3166)
E/GoogleApiManager(12428):      at bbbq.a(:com.google.android.gms@253830035@25.38.30 (260400-807569344):36)
E/GoogleApiManager(12428):      at bazv.z(:com.google.android.gms@253830035@25.38.30 (260400-807569344):143)
E/GoogleApiManager(12428):      at bagr.run(:com.google.android.gms@253830035@25.38.30 (260400-807569344):42)
E/GoogleApiManager(12428):      at android.os.Handler.handleCallback(Handler.java:959)
E/GoogleApiManager(12428):      at android.os.Handler.dispatchMessage(Handler.java:100)
E/GoogleApiManager(12428):      at clyj.mK(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
E/GoogleApiManager(12428):      at clyj.dispatchMessage(:com.google.android.gms@253830035@25.38.30 (260400-807569344):5)
E/GoogleApiManager(12428):      at android.os.Looper.loopOnce(Looper.java:257)
E/GoogleApiManager(12428):      at android.os.Looper.loop(Looper.java:342)
E/GoogleApiManager(12428):      at android.os.HandlerThread.run(HandlerThread.java:85)
W/FlagRegistrar(12428): Failed to register com.google.android.gms.providerinstaller#com.mccarty.journeymanjobs
W/FlagRegistrar(12428): fqsu: 17: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagRegistrar(12428):         at fqsw.a(:com.google.android.gms@253830035@25.38.30 (260400-807569344):13)
W/FlagRegistrar(12428):         at gnso.d(:com.google.android.gms@253830035@25.38.30 (260400-807569344):3)
W/FlagRegistrar(12428):         at gnsq.run(:com.google.android.gms@253830035@25.38.30 (260400-807569344):130)
W/FlagRegistrar(12428):         at gnux.execute(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
W/FlagRegistrar(12428):         at gnsy.f(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
W/FlagRegistrar(12428):         at gnsy.m(:com.google.android.gms@253830035@25.38.30 (260400-807569344):99)
W/FlagRegistrar(12428):         at gnsy.r(:com.google.android.gms@253830035@25.38.30 (260400-807569344):17)
W/FlagRegistrar(12428):         at fiyg.hJ(:com.google.android.gms@253830035@25.38.30 (260400-807569344):35)
W/FlagRegistrar(12428):         at ewwg.run(:com.google.android.gms@253830035@25.38.30 (260400-807569344):12)
W/FlagRegistrar(12428):         at gnux.execute(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
W/FlagRegistrar(12428):         at ewwh.b(:com.google.android.gms@253830035@25.38.30 (260400-807569344):18)
W/FlagRegistrar(12428):         at ewww.b(:com.google.android.gms@253830035@25.38.30 (260400-807569344):36)
W/FlagRegistrar(12428):         at ewwy.d(:com.google.android.gms@253830035@25.38.30 (260400-807569344):25)
W/FlagRegistrar(12428):         at baea.c(:com.google.android.gms@253830035@25.38.30 (260400-807569344):9)
W/FlagRegistrar(12428):         at bagp.q(:com.google.android.gms@253830035@25.38.30 (260400-807569344):48)
W/FlagRegistrar(12428):         at bagp.d(:com.google.android.gms@253830035@25.38.30 (260400-807569344):10)
W/FlagRegistrar(12428):         at bagp.g(:com.google.android.gms@253830035@25.38.30 (260400-807569344):192)
W/FlagRegistrar(12428):         at bagp.onConnectionFailed(:com.google.android.gms@253830035@25.38.30 (260400-807569344):2)
W/FlagRegistrar(12428):         at bagr.run(:com.google.android.gms@253830035@25.38.30 (260400-807569344):70)
W/FlagRegistrar(12428):         at android.os.Handler.handleCallback(Handler.java:959)
W/FlagRegistrar(12428):         at android.os.Handler.dispatchMessage(Handler.java:100)
W/FlagRegistrar(12428):         at clyj.mK(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
W/FlagRegistrar(12428):         at clyj.dispatchMessage(:com.google.android.gms@253830035@25.38.30 (260400-807569344):5)
W/FlagRegistrar(12428):         at android.os.Looper.loopOnce(Looper.java:257)
W/FlagRegistrar(12428):         at android.os.Looper.loop(Looper.java:342)
W/FlagRegistrar(12428):         at android.os.HandlerThread.run(HandlerThread.java:85)
W/FlagRegistrar(12428): Caused by: baci: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagRegistrar(12428):         at bazh.a(:com.google.android.gms@253830035@25.38.30 (260400-807569344):15)
W/FlagRegistrar(12428):         at baed.a(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
W/FlagRegistrar(12428):         at baea.c(:com.google.android.gms@253830035@25.38.30 (260400-807569344):5)
W/FlagRegistrar(12428):         ... 12 more
D/nativeloader(12428): Load /data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/base.apk!/lib/arm64-v8a/libconscrypt_gmscore_jni.so using ns clns-14 from class loader (caller=/data/app/~~-mTKN4DEvhuHTYLfPKZVMg==/com.google.android.gms-AwFoEJDFrdV9DSqXwIjJqA==/base.apk): ok
V/NativeCrypto(12428): Registering com/google/android/gms/org/conscrypt/NativeCrypto's 319 native methods...
W/.journeymanjobs(12428): Accessing hidden method Ljava/security/spec/ECParameterSpec;->getCurveName()Ljava/lang/String; (unsupported, reflection, allowed)
I/ProviderInstaller(12428): Installed default security provider GmsCore_OpenSSL
D/ConnectivityManager(12428): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4671)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5360)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5327)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5301)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.configureNetworkMonitoring(AndroidChannelBuilder.java:217)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.<init>(AndroidChannelBuilder.java:198)] [io.grpc.android.AndroidChannelBuilder.build(AndroidChannelBuilder.java:169)] [com.google.firebase.firestore.remote.GrpcCallProvider.initChannel(GrpcCallProvider.java:116)] [com.google.firebase.firestore.remote.GrpcCallProvider.lambda$initChannelTask$6$com-google-firebase-firestore-remote-GrpcCallProvider(GrpcCallProvider.java:242)] [com.google.firebase.firestore.remote.GrpcCallProvider$$ExternalSyntheticLambda4.call(D8$$SyntheticClass:0)] [com.google.android.gms.tasks.zzz.run(com.google.android.gms:play-services-tasks@@18.1.0:1)] [com.google.firebase.firestore.util.ThrottledForwardingExecutor.lambda$execute$0$com-google-firebase-firestore-util-ThrottledForwardingExecutor(ThrottledForwardingExecutor.java:54)] [com.google.firebase.firestore.util.ThrottledForwardingExecutor$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)] [java.lang.Thread.run(Thread.java:1012)]
I/flutter (12428): User granted permission
W/.journeymanjobs(12428): Accessing hidden field Ljava/net/Socket;->impl:Ljava/net/SocketImpl; (unsupported, reflection, allowed)
W/.journeymanjobs(12428): Accessing hidden method Ljava/security/spec/ECParameterSpec;->setCurveName(Ljava/lang/String;)V (unsupported, reflection, allowed)
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@eee0387
I/flutter (12428): User granted permission
I/flutter (12428): FCM token stored in Firestore
I/flutter (12428): FCM Service initialized successfully
I/flutter (12428): FCM token stored in Firestore
I/flutter (12428): FCM Service initialized successfully
I/flutter (12428): FCM token stored in Firestore
I/flutter (12428): FCM Service initialized successfully
I/flutter (12428): ConcurrentOperationManager: Queued operation loadJobs_1761324753036_0 (loadJobs)
I/flutter (12428): ConcurrentOperationManager: Starting operation loadJobs_1761324753036_0 (loadJobs)
I/flutter (12428): ConnectivityService initialized - Initial state: Online
W/WindowOnBackDispatcher(12428): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(12428): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
D/ConnectivityManager(12428): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4671)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5360)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5327)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5301)] [dev.fluttercommunity.plus.connectivity.ConnectivityBroadcastReceiver.onListen(ConnectivityBroadcastReceiver.java:77)] [io.flutter.plugin.common.EventChannel$IncomingStreamRequestHandler.onListen(EventChannel.java:218)] [io.flutter.plugin.common.EventChannel$IncomingStreamRequestHandler.onMessage(EventChannel.java:197)] [io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:292)] [io.flutter.embedding.engine.dart.DartMessenger.lambda$dispatchMessageToQueue$0$io-flutter-embedding-engine-dart-DartMessenger(DartMessenger.java:319)] [io.flutter.embedding.engine.dart.DartMessenger$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)]
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(notifications where userId==YWmNWnSM3FWMDKSfO0mmuFTjurS2 and isRead==false order by __name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (12428): ----------------FIREBASE CRASHLYTICS----------------
I/flutter (12428): Cannot use the Ref of jobsProvider after it has been disposed. This typically happens if:
I/flutter (12428): - A provider rebuilt, but the previous "build" was still pending and is still performing operations.
I/flutter (12428):   You should therefore either use `ref.onDispose` to cancel pending work, or
I/flutter (12428):   check `ref.mounted` after async gaps or anything that could invalidate the provider.
I/flutter (12428): - You tried to use Ref inside `onDispose` or other life-cycles.
I/flutter (12428):   This is not supported, as the provider is already being disposed.
I/flutter (12428): #0      Ref._throwIfInvalidUsage (package:riverpod/src/core/ref.dart:220:7)
I/flutter (12428): #1      AnyNotifier.state (package:riverpod/src/core/provider/notifier_provider.dart:82:9)
I/flutter (12428): #2      JobsNotifier.loadJobs (package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart:211:15)
I/flutter (12428): <asynchronous suspension>
I/flutter (12428): ----------------------------------------------------
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
D/InputTransport(12428): Input channel destroyed: 'ClientS', fd=215
D/InputTransport(12428): Input channel destroyed: 'ClientS', fd=198
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /system/app/DictDiotekForSec/DictDiotekForSec.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hmO8wQO9HjX093wZ39RTcA==/com.samsung.android.app.interpreter-7NEVbxXNXSjcVUYoNAyn-Q==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '/data/resource-cache/android-SemWT_com.samsung.android.app.interpreter-rdBt.frro' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~4wadYFB7u6RN-TlD_CKe8w==/com.samsung.android.samsungpass-7C0VA_BVJ7VRQQNjblBVsQ==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~tqscc3YInU40IaO5MgwXTQ==/ai.perplexity.app.android-WG0POHD0LTTlWkUJ03pC8Q==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~tqscc3YInU40IaO5MgwXTQ==/ai.perplexity.app.android-WG0POHD0LTTlWkUJ03pC8Q==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~tqscc3YInU40IaO5MgwXTQ==/ai.perplexity.app.android-WG0POHD0LTTlWkUJ03pC8Q==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~iE2waYGKR1dgI7FWl-_nTg==/com.anthropic.claude-8McryQeZqWw3WuYCx8m7LQ==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~iE2waYGKR1dgI7FWl-_nTg==/com.anthropic.claude-8McryQeZqWw3WuYCx8m7LQ==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~iE2waYGKR1dgI7FWl-_nTg==/com.anthropic.claude-8McryQeZqWw3WuYCx8m7LQ==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~iE2waYGKR1dgI7FWl-_nTg==/com.anthropic.claude-8McryQeZqWw3WuYCx8m7LQ==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~7x8YCi_Z1NYg5ejhIEFEzw==/com.microsoft.emmx-x11LJ17ZndZZzkeS3cVKPQ==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~OZGeUITubg6rsrBLGPT7iA==/com.microsoft.launcher-b2pFxur_lZTH_lGXgl-fFQ==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~ZUKven4CdBDkbKYbE5roQQ==/com.microsoft.office.onenote-MLHTxmMpdL693j3LkMyO0g==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~ZUKven4CdBDkbKYbE5roQQ==/com.microsoft.office.onenote-MLHTxmMpdL693j3LkMyO0g==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~ZUKven4CdBDkbKYbE5roQQ==/com.microsoft.office.onenote-MLHTxmMpdL693j3LkMyO0g==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~PjoXlReNq8cUauMG2g1hZg==/com.microsoft.todos-4cik8Ulb09hMwlhCONiLvw==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~D2NVPsYWGMch73erQ1XkvQ==/com.openai.chatgpt-tQCRvm8dYQJ42MFhSrJAug==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~D2NVPsYWGMch73erQ1XkvQ==/com.openai.chatgpt-tQCRvm8dYQJ42MFhSrJAug==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~D2NVPsYWGMch73erQ1XkvQ==/com.openai.chatgpt-tQCRvm8dYQJ42MFhSrJAug==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~D2NVPsYWGMch73erQ1XkvQ==/com.openai.chatgpt-tQCRvm8dYQJ42MFhSrJAug==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_amazon_ads.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_amazon_ads.config.xxhdpi.apk' with 1 weak references        
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_minipay.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~u_MF9yGwk9TauZqSuELF1g==/com.opera.mini.native-53N3s9V30HejrlbmKxImoA==/split_minipay.config.arm64_v8a.apk' with 1 weak references        
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hXHLcPcPh_iUwXZtF6-20A==/com.touchtype.swiftkey-TUdz30goW_wxWBqBsHMqXQ==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hXHLcPcPh_iUwXZtF6-20A==/com.touchtype.swiftkey-TUdz30goW_wxWBqBsHMqXQ==/split_FederatedComputationCore.apk' with 1 weak references       
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hXHLcPcPh_iUwXZtF6-20A==/com.touchtype.swiftkey-TUdz30goW_wxWBqBsHMqXQ==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hXHLcPcPh_iUwXZtF6-20A==/com.touchtype.swiftkey-TUdz30goW_wxWBqBsHMqXQ==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~hXHLcPcPh_iUwXZtF6-20A==/com.touchtype.swiftkey-TUdz30goW_wxWBqBsHMqXQ==/split_config.xxhdpi.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~xsZCOZ6uu2zwJ__zUOfGjA==/company.thebrowser.arc-QG-oikEkaBuPKBtL8UfOOg==/base.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~xsZCOZ6uu2zwJ__zUOfGjA==/company.thebrowser.arc-QG-oikEkaBuPKBtL8UfOOg==/split_config.arm64_v8a.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~xsZCOZ6uu2zwJ__zUOfGjA==/company.thebrowser.arc-QG-oikEkaBuPKBtL8UfOOg==/split_config.en.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~xsZCOZ6uu2zwJ__zUOfGjA==/company.thebrowser.arc-QG-oikEkaBuPKBtL8UfOOg==/split_config.es.apk' with 1 weak references
W/.journeymanjobs(12428): ApkAssets: Deleting an ApkAssets object '<empty> and /data/app/~~xsZCOZ6uu2zwJ__zUOfGjA==/company.thebrowser.arc-QG-oikEkaBuPKBtL8UfOOg==/split_config.xxhdpi.apk' with 1 weak references
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@eee0387
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
E/GoogleApiManager(12428): Failed to get service from broker. 
E/GoogleApiManager(12428): java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
E/GoogleApiManager(12428):      at android.os.Parcel.createExceptionOrNull(Parcel.java:3257)
E/GoogleApiManager(12428):      at android.os.Parcel.createException(Parcel.java:3241)
E/GoogleApiManager(12428):      at android.os.Parcel.readException(Parcel.java:3224)
E/GoogleApiManager(12428):      at android.os.Parcel.readException(Parcel.java:3166)
E/GoogleApiManager(12428):      at bbbq.a(:com.google.android.gms@253830035@25.38.30 (260400-807569344):36)
E/GoogleApiManager(12428):      at bazv.z(:com.google.android.gms@253830035@25.38.30 (260400-807569344):143)
E/GoogleApiManager(12428):      at bagr.run(:com.google.android.gms@253830035@25.38.30 (260400-807569344):42)
E/GoogleApiManager(12428):      at android.os.Handler.handleCallback(Handler.java:959)
E/GoogleApiManager(12428):      at android.os.Handler.dispatchMessage(Handler.java:100)
E/GoogleApiManager(12428):      at clyj.mK(:com.google.android.gms@253830035@25.38.30 (260400-807569344):1)
E/GoogleApiManager(12428):      at clyj.dispatchMessage(:com.google.android.gms@253830035@25.38.30 (260400-807569344):5)
E/GoogleApiManager(12428):      at android.os.Looper.loopOnce(Looper.java:257)
E/GoogleApiManager(12428):      at android.os.Looper.loop(Looper.java:342)
E/GoogleApiManager(12428):      at android.os.HandlerThread.run(HandlerThread.java:85)
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@eee0387
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@eee0387
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://crashlyticsreports-pa.googleapis.com/v1/firelog/legacy/batchlog
I/flutter (12428): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (12428): 📋 User preferences:
I/flutter (12428):   - Preferred locals: [84, 111, 222]
I/flutter (12428):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (12428):   - Hours per week: >70
I/flutter (12428):   - Per diem: 200+
I/flutter (12428): 🔄 Querying jobs where local in: [84, 111, 222]
W/WindowOnBackDispatcher(12428): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(12428): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@eee0387
I/TRuntime.CctTransportBackend(12428): Status Code: 200
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=high hint, reason=touch, vri=VRI[MainActivity]@eee0387
W/WindowOnBackDispatcher(12428): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(12428): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)

══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 25 pixels on the right.

The relevant error-causing widget was:
  Row
  Row:file:///C:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/screens/tailboard_screen.dart:357:14

To inspect this widget in Flutter DevTools, visit:
http://127.0.0.1:9103/#/inspector?uri=http%3A%2F%2F127.0.0.1%3A49719%2F9j-N_dC8Xeg%3D%2F&inspectorRef=inspector-0

The overflowing RenderFlex has an orientation of Axis.horizontal.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and
black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the
RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be
seen. If the content is legitimately bigger than the available space, consider clipping it with a
ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex,
like a ListView.
The specific RenderFlex in question is: RenderFlex#409ea relayoutBoundary=up9 OVERFLOWING:
  creator: Row ← Padding ← DecoratedBox ← Container ← Flexible ← Row ← LayoutBuilder ← Column ←
    Padding ← ColoredBox ← Container ← Column ← ⋯
  parentData: offset=Offset(12.0, 8.0) (can use size)
  constraints: BoxConstraints(0.0<=w<=93.3, 0.0<=h<=Infinity)
  size: Size(93.3, 18.0)
  direction: horizontal
  mainAxisAlignment: start
  mainAxisSize: min
  crossAxisAlignment: center
  textDirection: ltr
  verticalDirection: down
  spacing: 0.0
◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
════════════════════════════════════════════════════════════════════════════════════════════════════

W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/VRI[MainActivity]@eee0387(12428): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@eee0387
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter (12428): 📡 Getting posts for crew test1-8-1761312778334 (limit: 20)
W/Firestore(12428): (26.0.2) [Firestore]: Listen for Query(target=Query(posts where crewId==test1-8-1761312778334 and isDeleted==false order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/TRuntime.CctTransportBackend(12428): Making request to: https://crashlyticsreports-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
D/FirebaseSessions(12428): App backgrounded on com.mccarty.journeymanjobs
I/flutter (12428): [Lifecycle] App inactive (lost focus)
I/ImeFocusController(12428): onPreWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController(12428): onPostWindowFocus: skipped hasWindowFocus=false mHasImeFocus=true
D/InputTransport(12428): Input channel destroyed: 'ClientS', fd=212
I/VRI[MainActivity]@eee0387(12428): handleAppVisibility mAppVisible = true visible = false
D/VRI[MainActivity]@eee0387(12428): visibilityChanged oldVisibility=true newVisibility=false
I/SurfaceView@6d820b7(12428): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ........ 0,0-1440,3088} of VRI[MainActivity]@eee0387
I/SurfaceView(12428): 114827447 Changes: creating=false format=false size=false visible=true alpha=false hint=false visible=true left=false top=false z=false attached=true lifecycleStrategy=false
I/SurfaceView(12428): 114827447 Cur surface: Surface(name=null mNativeObject=-5476376625728854336)/@0xafceac2
I/SurfaceView(12428): 114827447 surfaceDestroyed
I/SurfaceView@6d820b7(12428): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ........ 0,0-1440,3088}
I/SurfaceView@6d820b7(12428): updateSurface: mVisible = false mSurface.isValid() = true
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
V/SurfaceView(12428): Layout: x=0 y=0 w=1440 h=3088, frame=Rect(0, 0 - 1440, 3088)
D/SurfaceView(12428): 74468008 windowPositionLost, frameNr = 0
D/HWUI    (12428): CacheManager::trimMemory(20)
I/VRI[MainActivity]@eee0387(12428): Relayout returned: old=(0,0,1440,3088) new=(0,0,1440,3088) relayoutAsync=false req=(1440,3088)8 dur=8 res=0x2 s={false 0x0} ch=true seqId=0
I/SurfaceView@6d820b7(12428): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ........ 0,0-1440,3088} of VRI[MainActivity]@eee0387
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
D/VRI[MainActivity]@eee0387(12428): Not drawing due to not visible. Reason=!mAppVisible && !mForceDecorViewVisibility
D/VRI[MainActivity]@eee0387(12428): Pending transaction will not be applied in sync with a draw due to view not visible
D/HWUI    (12428): CacheManager::trimMemory(20)
I/VRI[MainActivity]@eee0387(12428): stopped(true) old = false
D/VRI[MainActivity]@eee0387(12428): WindowStopped on com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity set to true
D/HWUI    (12428): CacheManager::trimMemory(20)
I/flutter (12428): [Lifecycle] App hidden
I/flutter (12428): [Lifecycle] App paused (backgrounded)
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
I/flutter (12428): ConnectivityService initialized - Initial state: Online
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
I/FA      (12428): Application backgrounded at: timestamp_millis: 1761325665587
V/NativeCrypto(12428): Read error: ssl=0xb400007b87301f58: I/O error during system call, Software caused connection abort
V/NativeCrypto(12428): Write error: ssl=0xb400007b87301f58: I/O error during system call, Broken pipe
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=End of stream or IOException, cause=null}.
V/NativeCrypto(12428): SSL shutdown failed: ssl=0xb400007b87301f58: I/O error during system call, Success
W/Firestore(12428): (26.0.2) [WriteStream]: (95656) Stream closed with status: Status{code=UNAVAILABLE, description=End of stream or IOException, cause=null}.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:124)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
W/Firestore(12428): (26.0.2) [WatchStream]: (7a3d618) Stream closed with status: Status{code=UNAVAILABLE, description=Unable to resolve host firestore.googleapis.com, cause=java.lang.RuntimeException: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:223)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.doResolve(DnsNameResolver.java:282)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$Resolve.run(DnsNameResolver.java:318)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
W/Firestore(12428):     at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
W/Firestore(12428):     at java.lang.Thread.run(Thread.java:1012)
W/Firestore(12428): Caused by: java.net.UnknownHostException: Unable to resolve host "firestore.googleapis.com": No address associated with hostname
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:156)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupAllHostAddr(Inet6AddressImpl.java:103)
W/Firestore(12428):     at java.net.InetAddress.getAllByName(InetAddress.java:1152)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver$JdkAddressResolver.resolveAddress(DnsNameResolver.java:632)
W/Firestore(12428):     at io.grpc.internal.DnsNameResolver.resolveAddresses(DnsNameResolver.java:219)
W/Firestore(12428):     ... 5 more
W/Firestore(12428): Caused by: android.system.GaiException: android_getaddrinfo failed: EAI_NODATA (No address associated with hostname)
W/Firestore(12428):     at libcore.io.Linux.android_getaddrinfo(Native Method)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at libcore.io.BlockGuardOs.android_getaddrinfo(BlockGuardOs.java:222)
W/Firestore(12428):     at libcore.io.ForwardingOs.android_getaddrinfo(ForwardingOs.java:133)
W/Firestore(12428):     at java.net.Inet6AddressImpl.lookupHostByName(Inet6AddressImpl.java:135)
W/Firestore(12428):     ... 9 more
W/Firestore(12428): }.
W/ManagedChannelImpl(12428): [{0}] Failed to resolve name. status={1}
I/VRI[MainActivity]@eee0387(12428): handleAppVisibility mAppVisible = false visible = true
I/VRI[MainActivity]@eee0387(12428): stopped(false) old = true
D/VRI[MainActivity]@eee0387(12428): WindowStopped on com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity set to false
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
D/FirebaseSessions(12428): App foregrounded on com.mccarty.journeymanjobs
I/flutter (12428): [Lifecycle] App hidden
I/flutter (12428): [Lifecycle] App inactive (lost focus)
I/SurfaceView@6d820b7(12428): onWindowVisibilityChanged(0) false io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ......ID 0,0-1440,3088} of VRI[MainActivity]@eee0387
D/SurfaceView@6d820b7(12428): updateSurface: surface is not valid
I/SurfaceView@6d820b7(12428): releaseSurfaces: viewRoot = VRI[MainActivity]@eee0387
D/VRI[MainActivity]@eee0387(12428): applyTransactionOnDraw applyImmediately
I/InsetsSourceConsumer(12428): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity
I/InsetsSourceConsumer(12428): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity
I/BufferQueueProducer(12428): [](id:308c00000002,api:0,p:1065353216,c:12428) setDequeueTimeout:2077252342
I/BLASTBufferQueue_Java(12428): new BLASTBufferQueue, mName= VRI[MainActivity]@eee0387 mNativeObject= 0xb400007ad739d450 sc.mNativeObject= 0xb400007b87301f50 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760 android.view.Choreographer.doCallbacks:1216 android.view.Choreographer.doFrame:1142 android.view.Choreographer$FrameDisplayEventReceiver.run:1707
I/BLASTBufferQueue_Java(12428): update, w= 1440 h= 3088 mName = VRI[MainActivity]@eee0387 mNativeObject= 0xb400007ad739d450 sc.mNativeObject= 0xb400007b87301f50 format= -3 caller= android.graphics.BLASTBufferQueue.<init>:88 android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3397 android.view.ViewRootImpl.relayoutWindow:11361 android.view.ViewRootImpl.performTraversals:4544 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542
W/libc    (12428): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (12428): Access denied finding property "vendor.gpp.create_frc_extension"
I/VRI[MainActivity]@eee0387(12428): Relayout returned: old=(0,0,1440,3088) new=(0,0,1440,3088) relayoutAsync=false req=(1440,3088)0 dur=9 res=0x3 s={true 0xb4000079573007c0} ch=true seqId=0
D/VRI[MainActivity]@eee0387(12428): mThreadedRenderer.initialize() mSurface={isValid=true 0xb4000079573007c0} hwInitialized=true
I/SurfaceView(12428): 114827447 Changes: creating=false format=false size=false visible=false alpha=false hint=false visible=false left=false top=false z=false attached=true lifecycleStrategy=false
I/SurfaceView@6d820b7(12428): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ......ID 0,0-1440,3088} of VRI[MainActivity]@eee0387
I/SurfaceView(12428): 114827447 Changes: creating=true format=false size=false visible=true alpha=false hint=false visible=true left=false top=false z=false attached=true lifecycleStrategy=false
I/BufferQueueProducer(12428): [](id:308c00000003,api:0,p:0,c:12428) setDequeueTimeout:2077252342
I/BLASTBufferQueue_Java(12428): update, w= 1440 h= 3088 mName = null mNativeObject= 0xb400007ad738a530 sc.mNativeObject= 0xb400007b873167d0 format= 4 caller= android.view.SurfaceView.createBlastSurfaceControls:1642 android.view.SurfaceView.updateSurface:1318 android.view.SurfaceView.setWindowStopped:474 android.view.SurfaceView.surfaceCreated:2172 android.view.ViewRootImpl.notifySurfaceCreated:3312 android.view.ViewRootImpl.performTraversals:5036        
I/SurfaceView(12428): 114827447 Cur surface: Surface(name=null mNativeObject=0)/@0xafceac2
I/SurfaceView@6d820b7(12428): pST: sr = Rect(0, 0 - 1440, 3088) sw = 1440 sh = 3088
D/SurfaceView(12428): 114827447 performSurfaceTransaction RenderWorker position = [0, 0, 1440, 3088] surfaceSize = 1440x3088
W/libc    (12428): Access denied finding property "vendor.display.enable_optimal_refresh_rate"
W/libc    (12428): Access denied finding property "vendor.gpp.create_frc_extension"
I/SurfaceView@6d820b7(12428): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@6d820b7(12428): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView(12428): 114827447 visibleChanged -- surfaceCreated
I/SurfaceView@6d820b7(12428): surfaceCreated 1 #1 io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ......ID 0,0-1440,3088}
E/qdgralloc(12428): GetSize: Unrecognized pixel format: 0x38
E/Gralloc4(12428): isSupported(1, 1, 56, 1, ...) failed with 5
E/GraphicBufferAllocator(12428): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 5
E/AHardwareBuffer(12428): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -5), handle=0x0
E/qdgralloc(12428): GetSize: Unrecognized pixel format: 0x3b
E/Gralloc4(12428): isSupported(1, 1, 59, 1, ...) failed with 5
E/GraphicBufferAllocator(12428): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 5
E/AHardwareBuffer(12428): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -5), handle=0x0
E/qdgralloc(12428): GetSize: Unrecognized pixel format: 0x38
E/Gralloc4(12428): isSupported(1, 1, 56, 1, ...) failed with 5
E/GraphicBufferAllocator(12428): Failed to allocate (4 x 4) layerCount 1 format 56 usage b00: 5
E/AHardwareBuffer(12428): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -5), handle=0x0
E/qdgralloc(12428): GetSize: Unrecognized pixel format: 0x3b
E/Gralloc4(12428): isSupported(1, 1, 59, 1, ...) failed with 5
E/GraphicBufferAllocator(12428): Failed to allocate (4 x 4) layerCount 1 format 59 usage b00: 5
E/AHardwareBuffer(12428): GraphicBuffer(w=4, h=4, lc=1) failed (Unknown error -5), handle=0x0
I/SurfaceView(12428): 114827447 surfaceChanged -- format=4 w=1440 h=3088
I/SurfaceView@6d820b7(12428): surfaceChanged (1440,3088) 1 #1 io.flutter.embedding.android.FlutterSurfaceView{6d820b7 V.E...... ......ID 0,0-1440,3088}
I/SurfaceView(12428): 114827447 surfaceRedrawNeeded
V/SurfaceView(12428): Layout: x=0 y=0 w=1440 h=3088, frame=Rect(0, 0 - 1440, 3088)
D/VRI[MainActivity]@eee0387(12428): reportNextDraw android.view.ViewRootImpl.performTraversals:5193 android.view.ViewRootImpl.doTraversal:3708 android.view.ViewRootImpl$TraversalRunnable.run:12542 android.view.Choreographer$CallbackRecord.run:1751 android.view.Choreographer$CallbackRecord.run:1760
D/VRI[MainActivity]@eee0387(12428): Setup new sync=wmsSync-VRI[MainActivity]@eee0387#4
I/VRI[MainActivity]@eee0387(12428): Creating new active sync group VRI[MainActivity]@eee0387#5
D/VRI[MainActivity]@eee0387(12428): Start draw after previous draw not visible
D/VRI[MainActivity]@eee0387(12428): registerCallbacksForSync syncBuffer=false
D/SurfaceView(12428): 114827447 updateSurfacePosition RenderWorker, frameNr = 1, position = [0, 0, 1440, 3088] surfaceSize = 1440x3088
I/SurfaceView@6d820b7(12428): uSP: rtp = Rect(0, 0 - 1440, 3088) rtsw = 1440 rtsh = 3088
I/SurfaceView@6d820b7(12428): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@6d820b7(12428): aOrMT: VRI[MainActivity]@eee0387 t = android.view.SurfaceControl$Transaction@f22f298 fN = 1 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1792 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:398
I/VRI[MainActivity]@eee0387(12428): mWNT: t=0xb400007ac7331090 mBlastBufferQueue=0xb400007ad739d450 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.SurfaceView.applyOrMergeTransaction:1723 android.view.SurfaceView.-$$Nest$mapplyOrMergeTransaction:0 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1792
D/VRI[MainActivity]@eee0387(12428): Received frameDrawingCallback syncResult=0 frameNum=1.
I/VRI[MainActivity]@eee0387(12428): mWNT: t=0xb400007ac735aed0 mBlastBufferQueue=0xb400007ad739d450 fn= 1 HdrRenderState mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$11.onFrameDraw:15016 android.view.ThreadedRenderer$1.onFrameDraw:761 <bottom of call stack>
I/VRI[MainActivity]@eee0387(12428): Setting up sync and frameCommitCallback
I/BLASTBufferQueue(12428): [VRI[MainActivity]@eee0387#2](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient(12428): apply transaction with the first frame. layerId: 36618, bufferData(ID: 53377853554730, frameNumber: 1)
I/VRI[MainActivity]@eee0387(12428): Received frameCommittedCallback lastAttemptedDrawFrameNum=1 didProduceBuffer=true
I/BLASTBufferQueue(12428): [SurfaceView[com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity]@0#3](f:0,a:0,s:0) onFrameAvailable the first frame is available
I/SurfaceComposerClient(12428): apply transaction with the first frame. layerId: 36621, bufferData(ID: 53377853554725, frameNumber: 1)
D/VRI[MainActivity]@eee0387(12428): reportDrawFinished seqId=0
I/SurfaceView(12428): 114827447 finishedDrawing
I/TRuntime.CctTransportBackend(12428): Making request to: https://firebaselogging-pa.googleapis.com/v1/firelog/legacy/batchlog
V/NativeCrypto(12428): Read error: ssl=0xb400007b872f5f58: I/O error during system call, Software caused connection abort
V/NativeCrypto(12428): SSL shutdown failed: ssl=0xb400007b872f5f58: I/O error during system call, Broken pipe
D/VRI[MainActivity]@eee0387(12428): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb4000079573007c0}
I/flutter (12428): [Lifecycle] App resumed, validating session
D/InputMethodManagerUtils(12428): startInputInner - Id : 0
I/InputMethodManager(12428): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/flutter (12428): [Lifecycle] Session expired on app resume (>24 hours), signing out
D/InputTransport(12428): Input channel constructed: 'ClientS', fd=210
I/flutter (12428): ConnectivityService initialized - Initial state: Online
I/InsetsSourceConsumer(12428): applyRequestedVisibilityToControl: visible=false, type=ime, host=com.mccarty.journeymanjobs/com.mccarty.journeymanjobs.MainActivity
I/VRI[MainActivity]@eee0387(12428): handleResized, frames=ClientWindowFrames{frame=[0,0][1440,3088] display=[0,0][1440,3088] parentFrame=[0,0][0,0]} displayId=0 dragResizing=false compatScale=1.0 frameChanged=false attachedFrameChanged=false configChanged=false displayChanged=false compatScaleChanged=false dragResizingChanged=false
D/ConnectivityManager(12428): StackLog: [android.net.ConnectivityManager.unregisterNetworkCallback(ConnectivityManager.java:5470)] [com.google.firebase.firestore.remote.AndroidConnectivityMonitor.lambda$configureNetworkMonitoring$0$com-google-firebase-firestore-remote-AndroidConnectivityMonitor(AndroidConnectivityMonitor.java:89)] [com.google.firebase.firestore.remote.AndroidConnectivityMonitor$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)] [com.google.firebase.firestore.remote.AndroidConnectivityMonitor.shutdown(AndroidConnectivityMonitor.java:77)] [com.google.firebase.firestore.remote.RemoteStore.shutdown(RemoteStore.java:330)] [com.google.firebase.firestore.core.FirestoreClient.lambda$terminate$6$com-google-firebase-firestore-core-FirestoreClient(FirestoreClient.java:153)] [com.google.firebase.firestore.core.FirestoreClient$$ExternalSyntheticLambda9.run(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor.lambda$executeAndInitiateShutdown$2(AsyncQueue.java:359)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$$ExternalSyntheticLambda0.call(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor.lambda$executeAndReportResult$1(AsyncQueue.java:330)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$$ExternalSyntheticLambda2.run(D8$$SyntheticClass:0)] [java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:487)] [java.util.concurrent.FutureTask.run(FutureTask.java:264)] [java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:307)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$DelayedStartFactory.run(AsyncQueue.java:235)] [java.lang.Thread.run(Thread.java:1012)]
D/ConnectivityManager(12428): StackLog: [android.net.ConnectivityManager.unregisterNetworkCallback(ConnectivityManager.java:5470)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel$1.run(AndroidChannelBuilder.java:223)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.unregisterNetworkListener(AndroidChannelBuilder.java:246)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.shutdown(AndroidChannelBuilder.java:254)] [com.google.firebase.firestore.remote.GrpcCallProvider.shutdown(GrpcCallProvider.java:149)] [com.google.firebase.firestore.remote.FirestoreChannel.shutdown(FirestoreChannel.java:130)] [com.google.firebase.firestore.remote.Datastore.shutdown(Datastore.java:100)] [com.google.firebase.firestore.remote.RemoteStore.shutdown(RemoteStore.java:333)] [com.google.firebase.firestore.core.FirestoreClient.lambda$terminate$6$com-google-firebase-firestore-core-FirestoreClient(FirestoreClient.java:153)] [com.google.firebase.firestore.core.FirestoreClient$$ExternalSyntheticLambda9.run(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor.lambda$executeAndInitiateShutdown$2(AsyncQueue.java:359)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$$ExternalSyntheticLambda0.call(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor.lambda$executeAndReportResult$1(AsyncQueue.java:330)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$$ExternalSyntheticLambda2.run(D8$$SyntheticClass:0)] [java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:487)] [java.util.concurrent.FutureTask.run(FutureTask.java:264)] [java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:307)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$DelayedStartFactory.run(AsyncQueue.java:235)] [java.lang.Thread.run(Thread.java:1012)]
D/FirebaseAuth(12428): Notifying id token listeners about a sign-out event.
D/FirebaseAuth(12428): Notifying auth state listeners about a sign-out event.
I/CredManProvService(12428): In CredentialProviderFrameworkImpl onClearCredential
I/flutter (12428): User granted permission
I/flutter (12428): FCM Service initialized successfully
I/TRuntime.CctTransportBackend(12428): Status Code: 200
I/CredManProvService(12428): Clear result returned from framework: 
I/flutter (12428): ----------------FIREBASE CRASHLYTICS----------------
I/flutter (12428): Cannot use the Ref of sessionTimeoutProvider after it has been disposed. This typically happens if:
I/flutter (12428): - A provider rebuilt, but the previous "build" was still pending and is still performing operations.
I/flutter (12428):   You should therefore either use `ref.onDispose` to cancel pending work, or
I/flutter (12428):   check `ref.mounted` after async gaps or anything that could invalidate the provider.
I/flutter (12428): - You tried to use Ref inside `onDispose` or other life-cycles.
I/flutter (12428):   This is not supported, as the provider is already being disposed.
I/flutter (12428): #0      Ref._throwIfInvalidUsage (package:riverpod/src/core/ref.dart:220:7)
I/flutter (12428): #1      AnyNotifier.state= (package:riverpod/src/core/provider/notifier_provider.dart:91:9)
I/flutter (12428): #2      SessionTimeoutNotifier._initializeService.<anonymous closure> (package:journeyman_jobs/providers/riverpod/session_timeout_provider.dart:127:7)
I/flutter (12428): #3      SessionTimeoutService.endSession (package:journeyman_jobs/services/session_timeout_service.dart:173:28)
I/flutter (12428): <asynchronous suspension>
I/flutter (12428): #4      AppLifecycleService._validateSessionOnResume (package:journeyman_jobs/services/app_lifecycle_service.dart:115:9)
I/flutter (12428): <asynchronous suspension>
I/flutter (12428): ----------------------------------------------------
W/WindowOnBackDispatcher(12428): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(12428): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/TRuntime.CctTransportBackend(12428): Making request to: https://crashlyticsreports-pa.googleapis.com/v1/firelog/legacy/batchlog
I/TRuntime.CctTransportBackend(12428): Status Code: 200
