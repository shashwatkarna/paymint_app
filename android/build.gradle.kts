allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Overiding the build directory to resolve the drive-letter case mismatch (f: vs F:) on Windows
    rootProject.layout.buildDirectory.set(layout.projectDirectory.dir("../build"))
}

subprojects {
    project.evaluationDependsOn(":app")
    
    // Workaround for plugin unit tests failing on different drive letters (F: vs C:)
    tasks.whenTaskAdded {
        if (name.contains("UnitTest")) {
            enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
