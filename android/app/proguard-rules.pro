# Google ML Kit ProGuard Rules
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.ml.** { *; }
-keep class com.google.android.gms.tflite.** { *; }
-keep class com.google.android.libraries.places.** { *; }
-keep class com.google.firebase.ml.** { *; }

# Prevent obfuscation of ML Kit model classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
# Prevent warnings from blocking the build
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.libraries.places.**
