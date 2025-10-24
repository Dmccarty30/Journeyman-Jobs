# TODO

## APP WIDE CHANGES

### **Task Overview:**

Update the user authentication and session handling logic in the application to implement a grace period for automatic logouts. This change aims to improve user experience by preventing abrupt session terminations, allowing users a brief window to resume activity without re-authenticating.
Specific Requirements:

**Target Behaviors to Modify:**

Idle/inactivity detection (e.g., no user input or page interactions for a defined period).
App closure or backgrounding (e.g., user switches away from the app or explicitly closes it).
Any other automatic sign-out triggers (e.g., network disconnection, timeout on suspended sessions).

**Current vs. Desired Behavior:**

Current: Immediate sign-out upon detection of the above conditions.
Desired: Delay sign-out by exactly 5 minutes after the condition is detected. During this delay, the session remains active and logged in, even if the app is closed or inactive.

**Implementation Guidelines:**

Start a 5-minute timer only after the triggering condition is confirmed (e.g., after 2 minutes of confirmed inactivity, begin the additional 5-minute grace period).
If the user resumes activity (e.g., reopens the app, performs an action) within the 5 minutes, reset the timer and maintain the session without interruption.
Ensure the delay applies universally across platforms (web, iOS, Android) and session types (e.g., browser tabs, mobile foreground/background).
Log relevant events for debugging (e.g., "Grace period started due to inactivity at [timestamp]") without exposing user data.

**Edge Cases to Handle:**

Multiple triggers in quick succession: Use the latest trigger to reset the timer.
Server-side vs. client-side enforcement: Synchronize timers where possible to avoid desyncs.
Security considerations: Do not extend the grace period beyond 5 minutes; enforce strict sign-out after expiration to maintain compliance.

**Testing Criteria:**

Verify no sign-out occurs within 5 minutes of triggering conditions.
Confirm sign-out happens precisely at the 5-minute mark if no resumption occurs.
Test resumption scenarios to ensure seamless session continuity.

Expected Output: Provide updated code snippets, configuration changes, or pseudocode for the affected modules (e.g., auth service, session manager). Include any necessary UI notifications (e.g., a subtle warning banner at the 4-minute mark: "Session expiring soon—stay active to continue").

## APP THEME

- **Dark Mode**

## ONBOARDING SCREENS

- ***REMOVE THE DARK MODE THEME FROM EVERY SCREEN FROM THE WELCOME SCREEN TO THE HOME SCREEN AND APPLY THE APP WIDE ESTABLISHED LIGHT MODE THEME.***

### WELCOME SCREEN

- **lib\screens\onboarding\welcome_screen.dart**

### AUTH SCREEN

- **lib\screens\onboarding\auth_screen.dart**

### ONBOARDING STEPS SCREEN

- **lib\screens\onboarding\onboarding_steps_screen.dart**

#### STEP 1: BASIC INFORMATION

#### STEP 2

#### STEP 3: PREFERENCES AND FEEDBACK

## HOME SCREEN

- **lib\screens\storm\home_screen.dart**

- When I navigate to the home screen after onboarding it still says welcome back and the users email, that needs to change to the user's first and last name
- I don't understand why in the terminal, it is providing job descriptions, but the app is unable to display those suggested jobs. Here is a portion of the terminal output..

```terminal
I/flutter (23394): [RouterRefresh] Onboarding status changed - triggering router refresh
D/ConnectivityManager(23394): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4671)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5360)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5327)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5301)] [com.google.firebase.firestore.remote.AndroidConnectivityMonitor.configureNetworkMonitoring(AndroidConnectivityMonitor.java:87)] [com.google.firebase.firestore.remote.AndroidConnectivityMonitor.<init>(AndroidConnectivityMonitor.java:64)] [com.google.firebase.firestore.remote.RemoteComponenetProvider.createConnectivityMonitor(RemoteComponenetProvider.java:94)] [com.google.firebase.firestore.remote.RemoteComponenetProvider.initialize(RemoteComponenetProvider.java:41)] [com.google.firebase.firestore.core.ComponentProvider.initialize(ComponentProvider.java:158)] [com.google.firebase.firestore.core.FirestoreClient.initialize(FirestoreClient.java:284)] [com.google.firebase.firestore.core.FirestoreClient.lambda$new$0$com-google-firebase-firestore-core-FirestoreClient(FirestoreClient.java:109)] [com.google.firebase.firestore.core.FirestoreClient$$ExternalSyntheticLambda10.run(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue.lambda$enqueue$2(AsyncQueue.java:445)] [com.google.firebase.firestore.util.AsyncQueue$$ExternalSyntheticLambda4.call(D8$$SyntheticClass:0)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor.lambda$executeAndReportResult$1(AsyncQueue.java:330)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$$ExternalSyntheticLambda2.run(D8$$SyntheticClass:0)] [java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:487)] [java.util.concurrent.FutureTask.run(FutureTask.java:264)] [java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:307)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)] [com.google.firebase.firestore.util.AsyncQueue$SynchronizedShutdownAwareExecutor$DelayedStartFactory.run(AsyncQueue.java:235)] [java.lang.Thread.run(Thread.java:1012)]
D/ConnectivityManager(23394): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4671)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5360)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5327)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5301)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.configureNetworkMonitoring(AndroidChannelBuilder.java:217)] [io.grpc.android.AndroidChannelBuilder$AndroidChannel.<init>(AndroidChannelBuilder.java:198)] [io.grpc.android.AndroidChannelBuilder.build(AndroidChannelBuilder.java:169)] [com.google.firebase.firestore.remote.GrpcCallProvider.initChannel(GrpcCallProvider.java:116)] [com.google.firebase.firestore.remote.GrpcCallProvider.lambda$initChannelTask$6$com-google-firebase-firestore-remote-GrpcCallProvider(GrpcCallProvider.java:242)] [com.google.firebase.firestore.remote.GrpcCallProvider$$ExternalSyntheticLambda4.call(D8$$SyntheticClass:0)] [com.google.android.gms.tasks.zzz.run(com.google.android.gms:play-services-tasks@@18.1.0:1)] [com.google.firebase.firestore.util.ThrottledForwardingExecutor.lambda$execute$0$com-google-firebase-firestore-util-ThrottledForwardingExecutor(ThrottledForwardingExecutor.java:54)] [com.google.firebase.firestore.util.ThrottledForwardingExecutor$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)] [java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)] [java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)] [java.lang.Thread.run(Thread.java:1012)]
I/flutter (23394): [RouterRefresh] Auth state changed - triggering router refresh
I/flutter (23394): [RouterRefresh] Onboarding status changed - triggering router refresh
W/WindowOnBackDispatcher(23394): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(23394): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/flutter (23394): ConcurrentOperationManager: Queued operation loadJobs_1761329119209_0 (loadJobs)
I/flutter (23394): ConcurrentOperationManager: Starting operation loadJobs_1761329119209_0 (loadJobs)
I/flutter (23394): ConnectivityService initialized - Initial state: Online
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
D/ConnectivityManager(23394): StackLog: [android.net.ConnectivityManager.sendRequestForNetwork(ConnectivityManager.java:4671)] [android.net.ConnectivityManager.registerDefaultNetworkCallbackForUid(ConnectivityManager.java:5360)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5327)] [android.net.ConnectivityManager.registerDefaultNetworkCallback(ConnectivityManager.java:5301)] [dev.fluttercommunity.plus.connectivity.ConnectivityBroadcastReceiver.onListen(ConnectivityBroadcastReceiver.java:77)] [io.flutter.plugin.common.EventChannel$IncomingStreamRequestHandler.onListen(EventChannel.java:218)] [io.flutter.plugin.common.EventChannel$IncomingStreamRequestHandler.onMessage(EventChannel.java:197)] [io.flutter.embedding.engine.dart.DartMessenger.invokeHandler(DartMessenger.java:292)] [io.flutter.embedding.engine.dart.DartMessenger.lambda$dispatchMessageToQueue$0$io-flutter-embedding-engine-dart-DartMessenger(DartMessenger.java:319)] [io.flutter.embedding.engine.dart.DartMessenger$$ExternalSyntheticLambda0.run(D8$$SyntheticClass:0)]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/VRI[MainActivity]@e4e64a(23394): call setFrameRateCategory for touch hint category=no preference, reason=boost timeout, vri=VRI[MainActivity]@e4e64a
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
I/flutter (23394): 🔍 DEBUG: Loading suggested jobs for user YWmNWnSM3FWMDKSfO0mmuFTjurS2
I/flutter (23394): 📋 User preferences:
I/flutter (23394):   - Preferred locals: [84, 111, 222]
I/flutter (23394):   - Construction types: [distribution, transmission, dataCenter, industrial]
I/flutter (23394):   - Hours per week: >70
I/flutter (23394):   - Per diem: 200+
I/flutter (23394): 🔄 Querying jobs where local in: [84, 111, 222]
W/Firestore(23394): (26.0.2) [Firestore]: Listen for Query(target=Query(jobs where localin[84,111,222] and deleted==false order by -timestamp, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/journeyman-jobs/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9qb3VybmV5bWFuLWpvYnMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2pvYnMvaW5kZXhlcy9fEAEaCwoHZGVsZXRlZBABGgkKBWxvY2FsEAEaDQoJdGltZXN0YW1wEAIaDAoIX19uYW1lX18QAg, cause=null}
```

- *Quick Actions*

- *Suggested Jobs*

- Use @docs\plans\MISSING_METHODS_IMPLEMENTATION.dart as a guide to implementing suggested jobs based off of user defined job preferences

## JOB SCREEN

- **lib\screens\storm\jobs_screen.dart**

- I noticed that the text formatting on the jobs card on the job screen is correct with title Case however when you put details and the dialog pop up appears none of the text values are formatted as Title Case so I need to apply the Title Case formatting on the dialog box for jobs on the job screen

## STORM SCREEN

- **lib\screens\storm\storm_screen.dart**

- **Contractor Section**

- The contractor section sill doesn't display the `contractor cards`. I need to figure out why.

## TAILBOARD SCREEN

- **lib\features\crews\screens\tailboard_screen.dart**

- ***FIX OVERFLOW ERROR***

```terminal
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 25 pixels on the right.

The relevant error-causing widget was:
  Row
  Row:file:///C:/Users/david/Desktop/Journeyman-Jobs/lib/features/crews/screens/tailboard_screen.dart:357:14

To inspect this widget in Flutter DevTools, visit:
http://127.0.0.1:9103/#/inspector?uri=http%3A%2F%2F127.0.0.1%3A55030%2F2cfMmq1q1bk%3D%2F&inspectorRef=inspector-0

The overflowing RenderFlex has an orientation of Axis.horizontal.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and
black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the
RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be
seen. If the content is legitimately bigger than the available space, consider clipping it with a
ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex,
like a ListView.
The specific RenderFlex in question is: RenderFlex#3948c relayoutBoundary=up9 OVERFLOWING:
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

```

### CREATE CREWS SCREEN

- **lib\features\crews\screens\create_crew_screen.dart**

- **SET CREW PREFERENCES**

- **lib\widgets\dialogs\user_job_preferences_dialog.dart**

### JOBS

- **docs\tailboard\jobs-tab.png**

### FEED

- **docs\tailboard\feed-tab.png**

### CHAT

- **docs\tailboard\chat-tab.png**

### MEMBERS

- **docs\tailboard\members-tab.png**

## LOCALS SCREEN

- **lib\screens\storm\locals_screen.dart**

## SETTINGS SCREEN

- `ACCOUNT SECTION`

- **lib\screens\storm\settings_screen.dart**

- On the setting screen at the top it says Welcome back brother I don't understand why this is here on the settings screen this is not a landing page That makes no sense

- When you click on the job preference container in the profile section of the settings screen dialog box appears in that dialog box need to correct the overflow error on the save preference button
- Need to add journeyman lineman as a classification on the job preference remove apprentice electrician Remove Master electrician remove solar systems technician Remove Instrumentation technician
- In the construction type section remove renewable energy education health care transportation and manufacturing
- Remove min minimum hourly wage from dialog box And maximum travel distance apply the AT theme toast the electrical circuit toast or snack bar that appears when you save your preferences
- ** Need to implement or add so update user document or preferences related to the user when the user presses the save preferences button because I just checked Firebase and there's nothing in the fire base collection

### PROFILE SCREEN

#### PERSONAL TAB

#### PROFESSIONAL TAB

#### SETTINGS TAB

### TRAINING AND CERTIFICATES SCREEN

#### CERTIFICATES TAB

#### COURSES TAB

#### HISTORY TAB

- `SUPPORT SECTION`

### HELP AND SUPPORT SCREEN

#### FAQ TAB

#### CONTACT TAB

#### GUIDES TAB

### RESOURCES SCREEN

#### DOCUMENTS TAB

- **IBEW CONSTITUTION**

- **SAFETY**

- **TECHNICAL**

#### TOOLS TAB

- **CALCULATORS**

- **REFERENCES**

#### LINKS TAB

- **IBEW OFFICIAL**

- **TRAINING**

- **HELPFUL**

- ADD a container for "Union Pay Scales". and have the link icon connected to <https://unionpayscales.com/trades/ibew-linemen/>
- ADD another container for "Union Pay Scales". and have the link icon and have it set to dispay @lib\widgets\pay_scale_card.dart instead of navidating to the devices browser

- **SAFETY**

- connect NFPA to <https://www.nfpa.org/en/for-professionals/codes-and-standards/list-of-codes-and-standards#sortCriteria=%40computedproductid%20ascending%2C%40productid%20ascending&aq=%40culture%3D%22en%22&cq=%40tagtype%3D%3D(%22Standards%20Development%20Process%22)%20%20>
