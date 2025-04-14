buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Set custom build directory for root project
rootProject.buildDir = file("../build")

// ✅ Set custom build directories for subprojects
subprojects {
    buildDir = file("${rootProject.buildDir}/${project.name}")
}

// ✅ Clean task to delete the custom build directory
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
