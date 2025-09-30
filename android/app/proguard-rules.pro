# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep HMS classes
-keep class com.huawei.** { *; }
-keep class com.hianalytics.** { *; }
-keep interface com.huawei.** { *; }

# Keep Location and Site Kit classes
-keep class com.huawei.hms.location.** { *; }
-keep class com.huawei.hms.site.** { *; }
-keep interface com.huawei.hms.location.** { *; }
-keep interface com.huawei.hms.site.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }

# General Android
-dontwarn java.lang.invoke.**