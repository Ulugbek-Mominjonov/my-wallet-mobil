import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// `google-services.json` ni `flutterfire configure` yaratadi. Fayl hali
// yo'q bo'lsa plagin QO'LLANMAYDI — shunda Firebase sozlanmasidan oldin
// ham loyiha build bo'ladi (CI va yangi dasturchi uchun muhim).
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// Reliz imzosi `android/key.properties` dan olinadi. Bu fayl `.gitignore`
// da — kalit va parollar repoda saqlanmaydi.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "uz.mywallet.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // `flutter_local_notifications` java.time API'laridan foydalanadi.
        // Desugaring'siz build AAR metadata tekshiruvida to'xtaydi.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // ⚠️ Play Store'ga chiqqandan keyin bu ID o'zgartirilmaydi.
        applicationId = "uz.mywallet.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // `key.properties` bo'lsa — haqiqiy kalit bilan (Play Store uchun);
            // bo'lmasa debug kalit bilan, shunda `flutter run --release`
            // lokal mashinada ham ishlaydi.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Versiya plagin talabidan olingan (flutter_local_notifications 22.3.1).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
