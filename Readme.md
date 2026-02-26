## 1、下载使用依赖库
|thirdpart name|source url|使用方法|
|---|---|---|
| onnxruntime   |[linux](https://github.com/microsoft/onnxruntime/releases/download/v1.23.2/onnxruntime-linux-x64-1.23.2.tgz)  | onnxruntime |
|QNN|||


## 2、源码编译三方依赖库
|算法名称|源码地址|源码编译脚本|cmake构建方法|C++接口调用|
|---|---|---|---|---|
|opencv|[OpenCV](https://github.com/opencv/opencv/archive/refs/tags/4.12.0.tar.gz) [OpenCV_Contrib](https://github.com/opencv/opencv_contrib/archive/refs/tags/4.12.0.tar.gz)|[build_opencv_android.sh](build_opencv_android.sh)|见下方说明|
|NCNN||||


### OpenCV Android 编译说明

**此脚本配置为混合编译模式:**
- **Native层 (C++/JNI)**: 静态库 (.a 文件)
  - `libopencv_core.a`: 核心功能
  - `libopencv_imgproc.a`: 图像处理 (cvtColor, resize, warpAffine 等)
- **Java层**: 动态库 (.so 文件)
  - `libopencv_java.so`: Java/Kotlin API支持
  - `OpenCV.jar`: Java类库

这种配置可以同时满足Native代码使用静态链接(减小APK体积)和Java层使用动态库的需求。

#### 前置要求
1. 已下载并解压 Android NDK
2. 已安装 CMake (3.10+)
3. 已下载 OpenCV 4.12.0 源码

#### 快速使用

**‼️ 重要提示:** 
当前脚本已更新为混合编译模式（native静态库 + Java动态库）。
如果您之前已经编译过OpenCV，需要**删除旧的构建目录**后重新编译：

```bash
# 清理旧的编译结果
rm -rf /home/leixian/workspace/3rdpartLib/opencv-build-android
rm -rf /home/leixian/workspace/3rdpartLib/opencv-android-sdk

# 重新编译
chmod +x build_opencv_android.sh
./build_opencv_android.sh
```

**步骤 0: 检查环境(推荐)**
```bash
# 运行环境检查脚本
chmod +x check_prerequisites.sh
./check_prerequisites.sh
```

**方式一:直接运行脚本(使用默认配置)**
```bash
# 1. 确保 NDK 路径正确(需要修改脚本中的 NDK_PATH)
# 2. 给脚本添加执行权限
chmod +x build_opencv_android.sh

# 3. 运行脚本
./build_opencv_android.sh
```

**方式二:自定义配置**
```bash
# 1. 修改配置文件
vim opencv_android_config.sh  # 根据需要修改 NDK 路径、API level、目标架构等

# 2. 在脚本中引用配置(可选)
# 在 build_opencv_android.sh 开头添加:
# source opencv_android_config.sh

# 3. 运行编译
./build_opencv_android.sh
```

#### 配置说明
- **NDK_PATH**: Android NDK 安装目录路径
- **ANDROID_API_LEVEL**: 最低支持的 Android API 版本(21 = Android 5.0)
- **TARGET_ABIS**: 目标架构
  - `arm64-v8a`: 64位 ARM (现代设备必须)
  - `armeabi-v7a`: 32位 ARM (旧设备支持)
  - `x86_64`: 64位 x86 (模拟器)
  - `x86`: 32位 x86 (模拟器)

#### 输出结果
编译完成后,SDK 将输出到: `/home/leixian/workspace/3rdpartLib/opencv-android-sdk/`

**✅ 编译成功状态:**
```
编译输出路径: /home/leixian/workspace/3rdpartLib/opencv-build-android/arm64-v8a/
Java库已生成: libopencv_java4.so (7.29MB)

已安装到SDK: /home/leixian/workspace/3rdpartLib/opencv-android-sdk/arm64-v8a/sdk/native/libs/arm64-v8a/libopencv_java4.so
```

**当前可用的文件结构:**
```
opencv-android-sdk/
├── arm64-v8a/
│   └── sdk/
│       ├── native/
│       │   ├── jni/                      # CMake配置文件
│       │   │   ├── include/              # C++头文件
│       │   │   └── OpenCVConfig.cmake
│       │   ├── staticlibs/arm64-v8a/ # Native层静态库
│       │   │   ├── libopencv_core.a
│       │   │   └── libopencv_imgproc.a
│       │   └── libs/arm64-v8a/       # ✅ Java层动态库 (已生成)
│       │       └── libopencv_java4.so 
│       └── java/                     # Java类库 (需要额外获取)
│           └── (待添加OpenCV-*.jar)
└── armeabi-v7a/
    └── (相同结构)
```

**获取OpenCV Java JAR的方法:**

1. **方法一: 从官方OpenCV Android SDK获取**
   ```bash
   # 下载官方OpenCV Android SDK
   wget -O opencv-android-sdk.zip https://github.com/opencv/opencv/releases/download/4.12.0/opencv-4.12.0-android-sdk.zip
   unzip opencv-android-sdk.zip
   cp OpenCV-android-sdk/sdk/java/libs/opencv-*.jar /home/leixian/workspace/3rdpartLib/opencv-android-sdk/arm64-v8a/sdk/java/
   ```

2. **方法二: 手动构建(需要Gradle)**
   ```bash
   cd /home/leixian/workspace/3rdpartLib/opencv-build-android/arm64-v8a/opencv_android
   ./gradlew assemble
   # 生成的JAR在: opencv/build/outputs/aar/opencv-release.aar
   ```

**当前SDK状态检查:**
```bash
# 检查Java库文件
ls -la /home/leixian/workspace/3rdpartLib/opencv-android-sdk/arm64-v8a/sdk/native/libs/arm64-v8a/

# 检查Java类库(可能缺失)
ls -la /home/leixian/workspace/3rdpartLib/opencv-android-sdk/arm64-v8a/sdk/java/
```

#### 在 Android Studio 中使用

**方案一: Native层(C++/JNI)使用静态库**

**1. 项目结构**
```
YourApp/
├── app/
│   ├── src/main/
│   │   ├── cpp/
│   │   │   ├── CMakeLists.txt
│   │   │   └── native-lib.cpp
│   │   ├── jniLibs/          # 仅放Java层的.so
│   │   │   ├── arm64-v8a/
│   │   │   │   └── libopencv_java.so
│   │   │   └── armeabi-v7a/
│   │   │       └── libopencv_java.so
│   │   └── java/
│   └── libs/
│       └── OpenCV.jar         # Java类库
```

**2. 修改 app/build.gradle**
```gradle
android {
    defaultConfig {
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a'
        }
        
        externalNativeBuild {
            cmake {
                // 指定OpenCV SDK路径
                arguments "-DOpenCV_DIR=${project.rootDir}/../opencv-android-sdk/\${ANDROID_ABI}/sdk/native/jni"
            }
        }
    }
    
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }
    }
}

dependencies {
    // 添加OpenCV Java库
    implementation files('libs/OpenCV.jar')
}
```

**3. 创建 CMakeLists.txt** (参考 CMakeLists.txt.example)
```cmake
cmake_minimum_required(VERSION 3.10.2)
project("myopencvapp")

# 设置OpenCV路径(将使用静态库)
set(OpenCV_DIR ${CMAKE_SOURCE_DIR}/../jniLibs/opencv-android-sdk/${ANDROID_ABI}/sdk/native/jni)
find_package(OpenCV REQUIRED)

# 创建你的native库
add_library(myopencvapp SHARED native-lib.cpp)

# 链接OpenCV静态库
target_link_libraries(
    myopencvapp
    ${OpenCV_LIBS}  # 自动链接 libopencv_core.a 和 libopencv_imgproc.a
    android
    log
)
```

**4. Java/Kotlin代码中加载库**
```kotlin
class MainActivity : AppCompatActivity() {
    companion object {
        init {
            // 加载OpenCV Java包装库
            System.loadLibrary("opencv_java")
            // 然后加载你自己的native库
            System.loadLibrary("myopencvapp")
        }
    }
}
```

**方案二: 仅使用Java API**

如果只在Java/Kotlin层使用OpenCV:

```kotlin
import org.opencv.core.Mat
import org.opencv.core.CvType
import org.opencv.imgproc.Imgproc

class MainActivity : AppCompatActivity() {
    companion object {
        init {
            System.loadLibrary("opencv_java")
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 使用OpenCV Java API
        val mat = Mat(100, 100, CvType.CV_8UC3)
        Imgproc.cvtColor(mat, mat, Imgproc.COLOR_BGR2GRAY)
    }
}
```

#### 常见问题

**Q: NDK 路径错误**
```
ERROR: Android NDK not found
```
A: 请确保 `NDK_PATH` 指向正确的 NDK 目录,该目录应包含 `ndk-build` 文件

**Q: 编译时间太长**
A: 
- 减少 TARGET_ABIS,只编译需要的架构
- 减少 CPU 核心数:`-j4` 替代 `-j$(nproc)`
- 禁用不需要的模块

**Q: 如何减小库体积**
A: 当前配置已经优化:
- ✅ Native使用静态库 - 支持链接时优化和死代码消除
- ✅ 仅编译 core + imgproc + java 模块
- ✅ 禁用所有第三方依赖(PNG, JPEG, FFmpeg等)

**混合编译模式体积:**
- 静态库 (per ABI): ~3-5MB (.a 文件)
- Java动态库 (per ABI): ~2-4MB (libopencv_java.so)
- Java类库: ~0.5MB (OpenCV.jar)
- 预计总大小 (2个ABI): ~10-20MB

**与全动态库方案对比:**
- 全动态库: 最终APK较大(无法删除未使用代码)
- 混合方案: APK更小(静态库支持LTO优化)



