import org.gradle.api.GradleException
import org.gradle.api.JavaVersion

fun locateJava17Home(): java.io.File? {
    val envHomes = listOf(
        "JAVA_HOME",
        "JDK_HOME",
        "JAVA17_HOME",
        "JDK17_HOME",
        "JAVA_HOME_17",
        "JAVA_HOME_17_X64"
    )
        .mapNotNull { System.getenv(it) }
        .map { java.io.File(it) }

    val wellKnownRoots = listOf(
        java.io.File("C:\\Program Files\\Java"),
        java.io.File("C:\\Program Files (x86)\\Java"),
        java.io.File("C:\\Program Files\\Amazon Corretto"),
        java.io.File("C:\\Program Files\\Eclipse Adoptium")
    )

    fun isJava17Home(home: java.io.File): Boolean {
        val javaBinary = home.resolve("bin").resolve(
            if (System.getProperty("os.name").contains("Windows")) "java.exe" else "java"
        )
        val releaseFile = home.resolve("release")
        if (!javaBinary.exists() || !releaseFile.exists()) return false

        return releaseFile.useLines { lines ->
            lines.any { it.trim().startsWith("JAVA_VERSION=\"17") }
        }
    }

    val installedHomes = wellKnownRoots.flatMap { root ->
        root.takeIf { it.exists() && it.isDirectory }
            ?.walkTopDown()
            ?.maxDepth(2)
            ?.filter { it.isDirectory && it.resolve("release").exists() }
            ?.toList()
            ?: emptyList()
    }

    return (envHomes + installedHomes).firstOrNull(::isJava17Home)
}

fun ensureJava17() {
    if (JavaVersion.current() < JavaVersion.VERSION_17) {
        val java17Home = locateJava17Home()
        if (java17Home != null) {
            gradle.startParameter.javaHome = java17Home
            System.setProperty("org.gradle.java.home", java17Home.absolutePath)
            logger.lifecycle("Using Java 17 from ${java17Home.absolutePath}")
        } else {
            throw GradleException(
                "Android Gradle plugin requires Java 17. Set JAVA_HOME to a JDK 17 installation or install JDK 17."
            )
        }
    }
}

ensureJava17()

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val rootProjectDir = rootProject.projectDir.toPath().toAbsolutePath().normalize()
    val subprojectDir = project.projectDir.toPath().toAbsolutePath().normalize()

    if (subprojectDir.startsWith(rootProjectDir)) {
        val newSubprojectBuildDir = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", org.gradle.api.tasks.Delete::class) {
    delete(rootProject.layout.buildDirectory)
}

