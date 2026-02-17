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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ── AGP 8.0+ Namespace Patch ──
// Legacy plugins (e.g. isar_flutter_libs) may lack an explicit `namespace`
// causing build failures. This auto-injects `project.group` as fallback.
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val androidExt = extensions.getByName("android")
            if (androidExt is com.android.build.gradle.BaseExtension) {
                if (androidExt.namespace.isNullOrEmpty()) {
                    androidExt.namespace = project.group.toString()
                }
            }
        }
    }
}
