plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.agendaapp.agenda_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // En KTS se escribe así:
        isCoreLibraryDesugaringEnabled = true 
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Corregimos el error de depreciación de jvmTarget
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.agendaapp.agenda_app"
        minSdk = 21 // Requisito para desugaring
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // En KTS las funciones llevan paréntesis
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
