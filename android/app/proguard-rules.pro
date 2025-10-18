# Keep WebRTC classes to prevent libpenguin.so errors
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Add any additional ProGuard rules here as needed