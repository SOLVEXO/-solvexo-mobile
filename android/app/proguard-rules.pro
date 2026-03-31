# ============================================
# Flutter
# ============================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ============================================
# Google Play Core (fixes R8 missing class errors)
# ============================================
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ============================================
# Dio / OkHttp / Retrofit
# ============================================
-keep class com.squareup.okhttp3.** { *; }
-keep interface com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-dontwarn okio.**

# ============================================
# GetX
# ============================================
-keep class com.get.** { *; }
-dontwarn com.get.**

# ============================================
# GetStorage / Shared Preferences
# ============================================
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================
# Gson (JSON parsing)
# ============================================
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-dontwarn sun.misc.**
-keepattributes Signature
-keepattributes *Annotation*

# ============================================
# Google Maps / Location (if using)
# ============================================
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ============================================
# Firebase (if using)
# ============================================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ============================================
# Image / Cached Network Image
# ============================================
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# ============================================
# Keep your app's model classes
# IMPORTANT: Change 'com.yourpackage' to your actual package name
# ============================================
-keep class com.yourpackage.** { *; }
-keepclassmembers class com.yourpackage.** { *; }

# ============================================
# General - prevent common crashes
# ============================================
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}