allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Attempt to satisfy Flutter's case-sensitive root check by using a relative path string
    rootProject.layout.buildDirectory.set(layout.projectDirectory.dir("build"))
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
