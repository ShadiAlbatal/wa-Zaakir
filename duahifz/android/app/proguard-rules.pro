# Add project specific ProGuard rules here.

# Keep native methods for JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep sherpa-onnx classes (when integrated)
-keep class com.k2fsa.sherpa.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Keep data classes
-keepclassmembers class * {
    *** Companion;
}
-keepclasseswithmembers class * {
    *** Companion;
}
