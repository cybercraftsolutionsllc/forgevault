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
    afterEvaluate {
        val androidPlugin = project.extensions.findByName("android")
        if (androidPlugin != null) {
            try {
                val getNamespace = androidPlugin.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(androidPlugin) == null) {
                    val setNamespace = androidPlugin.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(androidPlugin, project.group.toString())
                }
            } catch (ignored: Exception) {}
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
