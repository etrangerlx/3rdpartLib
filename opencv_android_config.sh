#!/bin/bash
#
# OpenCV Android Build Configuration
# Modify these settings according to your needs
#

# ==================== Path Configuration ====================
# IMPORTANT: Set this to your actual Android NDK directory
export NDK_PATH="/home/leixian/workspace/3rdpartLib"

# OpenCV source (auto-detected, change if needed)
export OPENCV_SOURCE_DIR="/home/leixian/workspace/3rdpartLib/opencv-4.12.0"

# opencv_contrib modules (optional, uncomment if you have it)
# export OPENCV_CONTRIB_DIR="/home/leixian/workspace/3rdpartLib/opencv_contrib-4.12.0"

# Output directories
export BUILD_DIR="/home/leixian/workspace/3rdpartLib/opencv-build-android"
export INSTALL_DIR="/home/leixian/workspace/3rdpartLib/opencv-android-sdk"

# ==================== Android Configuration ====================
# Minimum Android API level (21 = Android 5.0)
export ANDROID_API_LEVEL=21

# Target ABIs - comment out the ones you don't need
export TARGET_ABIS=(
    "arm64-v8a"      # Required for modern 64-bit ARM devices
    "armeabi-v7a"    # Optional: 32-bit ARM (older devices)
    # "x86_64"       # Optional: x86 64-bit (emulators)
    # "x86"          # Optional: x86 32-bit (emulators)
)

# ==================== Build Options ====================
# Build type: Release or Debug
export BUILD_TYPE="Release"

# Enable/disable static libraries (ON = static .a files for native, OFF = shared .so files)
# Note: Java wrapper (libopencv_java.so) is always built as shared library
export BUILD_STATIC=ON

# Number of parallel jobs (default: all CPU cores)
export BUILD_JOBS=$(nproc)

# OpenCV Modules Configuration
# Build core and imgproc as static libraries for native use
# Build java module to generate libopencv_java.so for Java/Kotlin layer
# - core: Essential data structures and basic operations
# - imgproc: Image processing (cvtColor, resize, warpAffine, filter2D, etc.)
# - java: Java bindings (generates libopencv_java.so)
export BUILD_MODULES="core,imgproc,java"

# Explicitly disable all other modules to minimize binary size
export DISABLE_MODULES=(
    "calib3d"        # Camera calibration
    "features2d"    # Feature detection
    "flann"         # Fast nearest neighbor search
    "highgui"       # High-level GUI
    "imgcodecs"     # Image codecs (PNG, JPEG, etc.)
    "ml"            # Machine learning
    "objdetect"     # Object detection
    "photo"         # Computational photography
    "stitching"     # Image stitching
    "video"         # Video analysis
    "videoio"       # Video I/O
    "dnn"           # Deep neural networks
    "gapi"          # Graph API
    "python"        # Python bindings
    "java"          # Java bindings
    "objc"          # Objective-C bindings
    "js"            # JavaScript bindings
    "ts"            # Test framework
    "world"         # Combined module
)

# ==================== Optional Features ====================
# Set to ON to enable, OFF to disable
export WITH_CUDA=OFF
export WITH_OPENCL=OFF
export WITH_VULKAN=OFF
export WITH_PROTOBUF=OFF
export WITH_FFMPEG=OFF
export WITH_GSTREAMER=OFF

# ==================== Size Optimization ====================
# Set to ON for smaller binaries (but slower performance)
export ENABLE_NEON=ON          # ARM NEON optimization
export BUILD_WITH_DEBUG_INFO=OFF
export BUILD_EXAMPLES=OFF
export BUILD_TESTS=OFF
export BUILD_PERF_TESTS=OFF
export BUILD_DOCS=OFF
