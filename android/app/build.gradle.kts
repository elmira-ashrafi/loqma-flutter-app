import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.4"
}
dependencies {
    // Required by flutter_local_notifications (Java 8+ APIs on older Android).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Edge-to-edge helper (enableEdgeToEdge) for Android 15 Play guidance.
    implementation("androidx.activity:activity-ktx:1.10.1")
    implementation("androidx.core:core-ktx:1.16.0")

    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Messaging (IMPORTANT for push notifications)
    implementation("com.google.firebase:firebase-messaging")
}
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}
val googleMapsApiKey: String = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "delivery.loqma"
    // Use SDK 36 so all Android plugins (lifecycle, geolocator, maps, image_picker, etc.) compile.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        val keyAlias = keystoreProperties.getProperty("keyAlias")
        val keyPassword = keystoreProperties.getProperty("keyPassword")
        val storeFilePath = keystoreProperties.getProperty("storeFile")
        val storePassword = keystoreProperties.getProperty("storePassword")
        if (!keyAlias.isNullOrBlank() &&
            !keyPassword.isNullOrBlank() &&
            !storeFilePath.isNullOrBlank() &&
            !storePassword.isNullOrBlank()
        ) {
            create("release") {
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                storeFile = file(storeFilePath)
                this.storePassword = storePassword
            }
        }
    }

    defaultConfig {
        applicationId = "delivery.loqma"
        // You can update following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // Match compileSdk (required by several plugins).
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    buildTypes {
        release {
            signingConfig = if (signingConfigs.findByName("release") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Play Console R8 recommendations: shrink, obfuscate, optimize.
            isMinifyEnabled = true
            isShrinkResources = true
            isCrunchPngs = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // ABI splitting temporarily disabled to resolve conflicts
    // To enable APK splitting later, uncomment this section:
    /*
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = false
        }
    }
    */
}

flutter {
    source = "../.."
}
