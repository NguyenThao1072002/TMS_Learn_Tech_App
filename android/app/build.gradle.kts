import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.tms_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tms_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
      
        // Thêm cấu hình để hỗ trợ Google Sign-In
        manifestPlaceholders["appAuthRedirectScheme"] = "com.example.tms_app"
    }

    repositories {
        flatDir {
            // thêm đường dẫn đến thư mục chứa file .aar
            dirs("../zpdk-release-28052021")
        }
    }
    
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            } else {
                // Fallback to debug signing config if no key.properties exists
                keyAlias = "androiddebugkey"
                keyPassword = "android"
                storeFile = file("${System.getenv("ANDROID_HOME")}/debug.keystore") 
                storePassword = "android"
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now,
            // so `flutter run --release` works.

            signingConfig = signingConfigs.getByName("release")
        }
    }
 

}

flutter {
    source = "../.."
}
dependencies {
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.core:core:1.6.0") // Updated to stable version
    // Thêm dependency cho Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation(files("../zpdk-release-28052021/zpdk-release-v3.1.aar"))
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
