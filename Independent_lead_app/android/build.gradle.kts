import com.android.build.gradle.LibraryExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // Fix missing namespace on older plugins (e.g. twilio_voice) required by AGP 8+.
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension> {
            if (namespace == null) {
                namespace = "com.twilio.twilio_voice"
            }
        }
    }
}

subprojects {
    // Old plugins (e.g. flutter_media_downloader) use deprecated Kotlin APIs
    // like toLowerCase(). These are only warnings, but something in the
    // toolchain is treating warnings as errors. Force it back off so these
    // old plugins can still compile.
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            allWarningsAsErrors.set(false)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
} 