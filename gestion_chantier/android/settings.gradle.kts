
// Load Flutter SDK path from local.properties
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = file("local.properties")
        require(localPropertiesFile.exists()) { "local.properties file is missing." }

        localPropertiesFile.inputStream().use { properties.load(it) }
        val sdkPath = properties.getProperty("flutter.sdk")
        require(!sdkPath.isNullOrBlank()) { "flutter.sdk not set in local.properties" }
        sdkPath
    }

    // Include Flutter tools
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"

    // ✅ Correction : mise à jour du plugin Android Gradle vers 8.9.1
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    id("com.google.firebase.crashlytics") version("2.8.1") apply false
    // END: FlutterFire Configuration
    id("com.android.library") version "8.9.1" apply false

    // Kotlin (compatible)
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// Include your app module
include(":app")

