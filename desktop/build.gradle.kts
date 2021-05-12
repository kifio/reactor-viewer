plugins {
    kotlin("multiplatform") version "1.5.0"
    application
}

repositories {
    mavenCentral()
}

group = "org.kifio"
version = "1.0"

kotlin {
    jvm {
        withJava()
    }
    sourceSets {
        val jvmMain by getting {
            dependencies {
                implementation(project(":common"))
            }
        }
    }
}

application {
    mainClassName = "MainKt"
}