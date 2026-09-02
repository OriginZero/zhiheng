import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release 签名：从 android/key.properties 读取（本地开发与 CI 共用同一把正式 key，
// 保证本地安装包与 CI Release 签名一致，覆盖升级不报「签名不正确」）。
//
// key.properties 中的 storeFile 路径相对于 android/app/ 目录解析
// （本地约定文件位于 android/app/upload-keystore.jks，
//  CI 由 Secrets 解出到同一位置，见 .github/workflows/build-android.yml）。
//
// 注意：release 构建在缺少 key.properties 时**直接失败**，不回退 debug 签名——
// debug 证书每台机器/每次 CI 运行都不同，误发 debug 签名包会导致
// 用户覆盖安装失败（INSTALL_FAILED_UPDATE_INCOMPATIBLE），历史上 v1.0–v1.6 均因此无法平滑升级。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun keystoreProperty(name: String): String? = keystoreProperties.getProperty(name)

android {
    namespace = "com.zhiheng.zhiheng"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 依赖 java.time（API 26+），低版本设备需要 desugaring。
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.zhiheng.zhiheng"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            val missing = listOf(
                "storeFile",
                "storePassword",
                "keyAlias",
                "keyPassword",
            ).filter { keystoreProperty(it).isNullOrBlank() }
            if (missing.isNotEmpty()) {
                throw GradleException(
                    "android/key.properties 缺少必填项：${missing.joinToString()}。" +
                        "（本地由 keystore 生成脚本写入；CI 由 Secrets 写入，见 .github/workflows/build-android.yml）",
                )
            }
            create("release") {
                keyAlias = keystoreProperty("keyAlias")
                keyPassword = keystoreProperty("keyPassword")
                storeFile = file(keystoreProperty("storeFile")!!)
                storePassword = keystoreProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning == null) {
                throw GradleException(
                    "release 构建缺少正式签名：请创建 android/key.properties（storeFile 相对 android/app/）\n" +
                        "并生成 keystore（详见 docs/约束性文档.md「发布流程」与 CI Secrets 配置）。\n" +
                        "禁止回退 debug 签名出包：会导致覆盖更新报签名冲突。"
                )
            }
            signingConfig = releaseSigning
        }
    }
}

dependencies {
    // flutter_local_notifications（v1.7+）所需的 core library desugaring。
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
