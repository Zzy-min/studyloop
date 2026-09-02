import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

val integrityPropertiesFile = rootProject.file("play-integrity.properties")
val integrityProperties = Properties()
if (integrityPropertiesFile.exists()) {
    FileInputStream(integrityPropertiesFile).use(integrityProperties::load)
}

val requiredSigningProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingSigningProperties = requiredSigningProperties.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}
val storeFilePath = keystoreProperties.getProperty("storeFile")
val releaseStoreFile = storeFilePath?.let { path ->
    file(path).takeIf { it.exists() } ?: rootProject.file(path).takeIf { it.exists() }
}
val releaseSigningError = when {
    !keystorePropertiesFile.exists() -> "android/key.properties is required for a release build."
    missingSigningProperties.isNotEmpty() -> "android/key.properties is missing: ${missingSigningProperties.joinToString()}"
    releaseStoreFile == null -> "The release keystore in android/key.properties does not exist."
    else -> null
}

val requestedReleaseBuild = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (requestedReleaseBuild && releaseSigningError != null) {
    throw GradleException(
        "Refusing to build a distributable artifact with debug signing. $releaseSigningError"
    )
}

android {
    namespace = "com.zzy.studyloop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.zzy.studyloop"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        buildConfig = true
    }

    val cloudProjectNumber = integrityProperties
        .getProperty("cloudProjectNumber")
        ?.trim()
        .orEmpty()
    defaultConfig {
        buildConfigField(
            "String",
            "PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER",
            "\"$cloudProjectNumber\"",
        )
    }

    signingConfigs {
        create("release") {
            if (releaseSigningError == null) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    implementation("com.google.android.play:integrity:1.4.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
