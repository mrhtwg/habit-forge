import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing config from key.properties if present.
// For open source builds, you can run without a release key:
//   - debug builds use the standard debug keystore
//   - release builds fall back to debug signing if key.properties is absent
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.habitforge.habitforge"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.habitforge.habitforge"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.clear()
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }

    signingConfigs {
        // Both release and debug share the same keystore (habitforge.jks),
        // mirroring the reference project. Credentials come from
        // android/key.properties, which is git-ignored.
        if (keystorePropertiesFile.exists()) {
            val props = keystoreProperties
            create("release") {
                storeFile = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
                keyAlias = props["keyAlias"] as String
                keyPassword = props["keyPassword"] as String
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
            // AGP already provides a 'debug' SigningConfig — reconfigure it
            // instead of creating a duplicate.
            getByName("debug") {
                storeFile = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
                keyAlias = props["keyAlias"] as String
                keyPassword = props["keyPassword"] as String
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        debug {
            // Sign debug builds with the same keystore (reference behavior).
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
        release {
            // If key.properties exists, sign with the release key.
            // Otherwise fall back to debug signing so the project remains
            // buildable out-of-the-box.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Keep the native symbol table (libflutter.so.sym) so Flutter's
            // release-bundle post-check passes; "none" strips it and the build
            // fails with "failed to strip debug symbols from native libraries".
            ndk {
                debugSymbolLevel = "symbol_table"
            }
        }
    }
}

flutter {
    source = "../.."
}

// Apply Google Services only when a real google-services.json is present.
// This lets the open source project build without requiring contributors to
// configure Firebase first. See app/docs/firebase-setup.md when enabling Firebase.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}
