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
                implementation( "com.soywiz.korlibs.korim:korim:2.0.9")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core") {
                    version { strictly("1.5.0-RC") }
                }
            }
        }
    }
}

application {
    mainClassName = "MainKt"
}