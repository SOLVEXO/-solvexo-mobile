import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

// Release signing is mandatory: any release task fails immediately if
// android/key.properties is missing or incomplete. There is NO fallback to
// the debug keystore.
val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}
if (isReleaseBuild) {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release build aborted: android/key.properties not found. " +
                "Create it with storeFile, storePassword, keyAlias and keyPassword."
        )
    }
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword").forEach { key ->
        if (keystoreProperties.getProperty(key).isNullOrBlank()) {
            throw GradleException("Release build aborted: '$key' is missing in android/key.properties.")
        }
    }
    if (!file(keystoreProperties.getProperty("storeFile")).exists()) {
        throw GradleException(
            "Release build aborted: keystore not found at ${keystoreProperties.getProperty("storeFile")}."
        )
    }
}

android {
    namespace = "com.edudeen.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    signingConfigs {
        if (isReleaseBuild) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.edudeen.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Only resolvable for release builds; failure above is intentional otherwise.
            if (isReleaseBuild) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}