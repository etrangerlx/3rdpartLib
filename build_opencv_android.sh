#!/bin/bash
#
# Minimal OpenCV Android Build Script
# This script compiles OpenCV 4.12.0 for Android applications
#

set -e  # Exit on error

# ==================== Configuration ====================
# Android NDK path
NDK_PATH="/home/leixian/software/android-ndk-r25c/"

# OpenCV source directory
OPENCV_SOURCE_DIR="/home/leixian/workspace/3rdpartLib/opencv-4.12.0"

# Build output directory
BUILD_DIR="/home/leixian/workspace/3rdpartLib/opencv-build-android"

# Install directory (SDK output)
INSTALL_DIR="/home/leixian/workspace/3rdpartLib/opencv-android-sdk"

# Android API level (minimum supported Android version)
ANDROID_API_LEVEL=21  # Android 5.0+

# Target ABIs (uncomment the ones you need)
# Options: armeabi-v7a, arm64-v8a, x86, x86_64
TARGET_ABIS=(
    "arm64-v8a"      # 64-bit ARM (most common for modern devices)
    "armeabi-v7a"    # 32-bit ARM (for older devices)
)

# ==================== Build Configuration ====================
# Only build essential modules to minimize binary size
# core: Core functionality (required)
# imgproc: Image processing (cvtColor, resize, warpAffine, etc.)
ENABLED_MODULES=(
    "core"
    "imgproc"
)

# ==================== Helper Functions ====================
print_info() {
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

check_ndk() {
    if [ ! -d "$NDK_PATH" ]; then
        echo "ERROR: Android NDK not found at: $NDK_PATH"
        echo "Please set NDK_PATH to your Android NDK directory"
        exit 1
    fi
    
    # Try to find ndk-build
    if [ -f "$NDK_PATH/ndk-build" ]; then
        echo "Found NDK at: $NDK_PATH"
        return 0
    fi
    
    echo "ERROR: Invalid NDK directory. ndk-build not found in $NDK_PATH"
    exit 1
}

check_opencv_source() {
    if [ ! -d "$OPENCV_SOURCE_DIR" ]; then
        echo "ERROR: OpenCV source not found at: $OPENCV_SOURCE_DIR"
        exit 1
    fi
    
    if [ ! -f "$OPENCV_SOURCE_DIR/CMakeLists.txt" ]; then
        echo "ERROR: Invalid OpenCV source directory"
        exit 1
    fi
    
    echo "Found OpenCV source at: $OPENCV_SOURCE_DIR"
}

# ==================== Main Build Process ====================
print_info "OpenCV Android Build Script"

# Check prerequisites
check_ndk
check_opencv_source

# Create build directory
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# Build for each ABI
for ABI in "${TARGET_ABIS[@]}"; do
    print_info "Building for ABI: $ABI"
    
    ABI_BUILD_DIR="$BUILD_DIR/$ABI"
    ABI_INSTALL_DIR="$INSTALL_DIR/$ABI"
    
    mkdir -p "$ABI_BUILD_DIR"
    mkdir -p "$ABI_INSTALL_DIR"
    
    cd "$ABI_BUILD_DIR"
    
    # Configure with CMake
    # Native modules (core, imgproc) will be built as static libraries
    # Java wrapper (libopencv_java.so) will be built as shared library
    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$ANDROID_API_LEVEL" \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$ABI_INSTALL_DIR" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_ANDROID_EXAMPLES=OFF \
        -DBUILD_ANDROID_PROJECTS=OFF \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_DOCS=OFF \
        -DBUILD_opencv_apps=OFF \
        -DBUILD_opencv_java=ON \
        -DBUILD_opencv_python2=OFF \
        -DBUILD_opencv_python3=OFF \
        -DBUILD_LIST="core,imgproc,java" \
        -DBUILD_opencv_calib3d=OFF \
        -DBUILD_opencv_features2d=OFF \
        -DBUILD_opencv_flann=OFF \
        -DBUILD_opencv_highgui=OFF \
        -DBUILD_opencv_imgcodecs=OFF \
        -DBUILD_opencv_ml=OFF \
        -DBUILD_opencv_objdetect=OFF \
        -DBUILD_opencv_photo=OFF \
        -DBUILD_opencv_stitching=OFF \
        -DBUILD_opencv_video=OFF \
        -DBUILD_opencv_videoio=OFF \
        -DBUILD_opencv_dnn=OFF \
        -DBUILD_opencv_gapi=OFF \
        -DWITH_CUDA=OFF \
        -DWITH_OPENCL=OFF \
        -DWITH_IPP=OFF \
        -DWITH_ITT=OFF \
        -DWITH_PROTOBUF=OFF \
        -DWITH_FFMPEG=OFF \
        -DWITH_GSTREAMER=OFF \
        -DWITH_GTK=OFF \
        -DWITH_QT=OFF \
        -DWITH_PNG=OFF \
        -DWITH_JPEG=OFF \
        -DWITH_TIFF=OFF \
        -DWITH_WEBP=OFF \
        -DWITH_OPENJPEG=OFF \
        -DWITH_JASPER=OFF \
        -DWITH_OPENEXR=OFF \
        -DBUILD_JAVA=ON \
        -DANDROID_PROJECTS_BUILD_TYPE=GRADLE \
        "$OPENCV_SOURCE_DIR"
    
    # Build
    print_info "Compiling for $ABI..."
    cmake --build . --config Release -- -j$(nproc)
    
    # Install
    print_info "Installing for $ABI..."
    cmake --install .
    
    print_info "Build completed for $ABI"
done

# ==================== Finalize ====================
print_info "Build Summary"
echo "OpenCV Android SDK installed to: $INSTALL_DIR"
echo ""
echo "Built for ABIs:"
for ABI in "${TARGET_ABIS[@]}"; do
    echo "  - $ABI"
done
echo ""
echo "Generated Libraries:"
echo "  Native layer (static libraries):"
echo "    - $INSTALL_DIR/<ABI>/sdk/native/staticlibs/<ABI>/libopencv_core.a"
echo "    - $INSTALL_DIR/<ABI>/sdk/native/staticlibs/<ABI>/libopencv_imgproc.a"
echo "  Java layer (shared library):"
echo "    - $INSTALL_DIR/<ABI>/sdk/native/libs/<ABI>/libopencv_java4.so  ✅ 已生成"
echo "  Java classes:"
echo "    - $INSTALL_DIR/<ABI>/sdk/java/opencv-*.jar  ⚠️  需要额外获取"
echo ""
echo "✅ Java库已成功生成!"
echo "⚠️  Java JAR文件需要从官方SDK获取或手动构建"
echo ""
echo "获取Java JAR的两种方法:"
echo "1. 从官方OpenCV Android SDK:"
echo "   wget https://github.com/opencv/opencv/releases/download/4.12.0/opencv-4.12.0-android-sdk.zip"
echo "   unzip opencv-4.12.0-android-sdk.zip"
echo "   cp OpenCV-android-sdk/sdk/java/libs/opencv-*.jar $INSTALL_DIR/<ABI>/sdk/java/"
echo ""
echo "2. 手动构建(需要Gradle):"
echo "   cd $BUILD_DIR/<ABI>/opencv_android && ./gradlew assemble"
echo ""
echo "Verify generated files:"
echo "  ls -la $INSTALL_DIR/arm64-v8a/sdk/native/libs/arm64-v8a/libopencv_java4.so"
echo "  ls -la $INSTALL_DIR/arm64-v8a/sdk/java/"
echo ""
echo "To use in your Android app:"
echo "1. Native Layer (C++/JNI):"
echo "   - Copy static libraries from: $INSTALL_DIR/<ABI>/sdk/native/staticlibs/<ABI>/"
echo "   - Link against libopencv_core.a and libopencv_imgproc.a in CMakeLists.txt"
echo ""
echo "2. Java/Kotlin Layer:"
echo "   - Copy libopencv_java4.so from: $INSTALL_DIR/<ABI>/sdk/native/libs/<ABI>/"
echo "   - Copy opencv-*.jar to: app/libs/"
echo "   - Place libopencv_java4.so in app/src/main/jniLibs/<ABI>/"
echo ""
echo "3. Add to your app/build.gradle:"
echo "   android {"
echo "       externalNativeBuild {"
echo "           cmake {"
echo "               arguments '-DOpenCV_DIR=$INSTALL_DIR/\${ANDROID_ABI}/sdk/native/jni'"
echo "           }"
echo "       }"
echo "   }"
echo "   dependencies {"
echo "       implementation files('libs/opencv-*.jar')"
echo "   }"
echo ""
echo "4. In your Java/Kotlin code:"
echo "   static {"
echo "       System.loadLibrary("opencv_java4");"
echo "   }"
echo ""
print_info "Build Complete!"
