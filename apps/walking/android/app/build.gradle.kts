import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties, which is never
// committed. Without it, release builds fall back to the debug key so that
// `flutter run --release` keeps working. See CONTRIBUTING.md.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use(::load)
}

// Preview builds (`flutter build apk -P preview=true`) are for testers. They
// install next to the store version and are signed with a public test key
// from the repository, so every new preview updates the previous one.
val isPreview = project.hasProperty("preview")

android {
    namespace = "com.llarean.walking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.LLarean.JapaneseWalking"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "@string/app_name"
    }

    signingConfigs {
        create("preview") {
            storeFile = rootProject.file("../../../.github/preview/preview.keystore")
            storePassword = "preview"
            keyAlias = "preview"
            keyPassword = "preview"
        }
        if (keystoreProperties.isNotEmpty()) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (isPreview) {
                signingConfigs.getByName("preview")
            } else {
                signingConfigs.findByName("release")
                    ?: signingConfigs.getByName("debug")
            }
            if (isPreview) {
                applicationIdSuffix = ".preview"
                versionNameSuffix = "-preview"
                manifestPlaceholders["appLabel"] = "@string/app_name_preview"
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
