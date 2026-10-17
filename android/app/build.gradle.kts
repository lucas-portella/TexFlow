import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val chaveProperties = Properties()
val chaveArquivo = rootProject.file("key.properties")
if (chaveArquivo.exists()) {
    chaveArquivo.inputStream().use { chaveProperties.load(it) }
}

android {
    namespace = "com.texflow.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.texflow.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (chaveArquivo.exists()) {
            create("release") {
                keyAlias = chaveProperties.getProperty("keyAlias")
                keyPassword = chaveProperties.getProperty("keyPassword")
                storeFile = rootProject.file(chaveProperties.getProperty("storeFile"))
                storePassword = chaveProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (chaveArquivo.exists()) {
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

flutter {
    source = "../.."
}
