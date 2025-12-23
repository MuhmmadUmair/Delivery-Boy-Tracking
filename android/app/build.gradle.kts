plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // Flutter plugin (must be after Android & Kotlin)
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ Google Services plugin (NO version here)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.firebase_google_apple_notif"
    compileSdk = 36   // required by google_sign_in_android
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.firebase_google_apple_notif"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ Firebase BoM (controls all Firebase versions)
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // ✅ Firebase products (NO versions)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
