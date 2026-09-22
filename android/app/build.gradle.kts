import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Reliz imzosi (DEPLOY.md 2-bo'lim): `android/key.properties` — CI sirlardan
// yaratadi; lokal/CI'da bo'lmasa release build debug kalit bilan imzolanadi.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "uz.mywallet.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (rejali eslatmalar, BR-168) talabi.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
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
        // E2E (patrol, E20-T04): har test toza ilova ma'lumotlari bilan.
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }

    // Muhitlar (DEPLOY.md 3-bo'lim): bir telefonda uchala versiya yonma-yon
    // o'rnatilishi mumkin; backend manzili --dart-define-from-file orqali.
    // AGP 9: flavor bo'yicha ilova nomi (resValue) uchun yoqiladi.
    buildFeatures {
        resValues = true
    }

    flavorDimensions += "env"
    productFlavors {
        // deepLinkScheme — taklif havolasi (mywallet://invite/<kod>) va auth
        // qaytish manzili; har muhitda o'ziniki (bir telefonda uchalasi ham).
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "My Wallet Dev")
            manifestPlaceholders["deepLinkScheme"] = "mywallet-dev"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".stg"
            resValue("string", "app_name", "My Wallet Stg")
            manifestPlaceholders["deepLinkScheme"] = "mywallet-stg"
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "My Wallet")
            manifestPlaceholders["deepLinkScheme"] = "mywallet"
        }
    }

    signingConfigs {
        if (!keystoreProperties.isEmpty) {
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
            signingConfig = if (keystoreProperties.isEmpty) {
                signingConfigs.getByName("debug")
            } else {
                signingConfigs.getByName("release")
            }
            // R8: kod va resurslar qisqartiriladi; plaginlar o'z qoidalarini
            // beradi, ilovaga xoslari — proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}
