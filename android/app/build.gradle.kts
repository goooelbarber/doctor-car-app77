apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'
apply plugin: 'org.jetbrains.kotlin.android'

android {
    namespace "com.example.doctorcar"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.doctorcar"
        minSdkVersion 23
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}
