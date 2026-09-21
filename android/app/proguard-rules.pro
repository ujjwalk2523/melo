# Proguard / R8 rules for Melo Music Player Production Release

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Just Audio & ExoPlayer / Media3
-dontwarn com.ryanheise.just_audio.**
-keep class com.ryanheise.just_audio.** { *; }
-keep class androidx.media3.** { *; }
-keep class androidx.media.** { *; }
-dontwarn androidx.media3.**
-dontwarn androidx.media.**
-dontwarn com.google.android.exoplayer2.**
-keep class com.google.android.exoplayer2.** { *; }

# Audio Service
-dontwarn com.ryanheise.audioservice.**
-keep class com.ryanheise.audioservice.** { *; }
-keep class android.support.v4.media.** { *; }
-keep class android.support.v4.media.session.** { *; }

# Audio Session
-dontwarn com.ryanheise.audio_session.**
-keep class com.ryanheise.audio_session.** { *; }

# SQLite3 & Drift Native Persistence
-keep class org.sqlite.** { *; }
-keep class io.simform.** { *; }
-keepclasseswithmembers class * {
    native <methods>;
}
