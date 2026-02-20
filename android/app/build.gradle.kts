plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.agendaapp.agenda_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Activamos el desugaring para que funcionen las notificaciones
        coreLibraryDesugaringEnabled = true // <--- AÑADIR ESTO
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.agendaapp.agenda_app"
        // Forzamos el minSdk a 21 si no está definido, 
        // ya que desugaring lo requiere como mínimo funcional.
        minSdk = 21 // <--- AÑADIR O CAMBIAR ESTO
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true // <--- AÑADIR ESTO
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Esta es la librería "traductora" que necesita el compilador
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3") // <--- AÑADIR ESTO
}
