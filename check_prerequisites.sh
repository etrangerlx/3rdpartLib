#!/bin/bash
#
# OpenCV Android Build - Prerequisites Checker
# Run this script before building to verify your environment
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${GREEN}ℹ${NC} $1"
}

echo "=================================================="
echo "OpenCV Android Build - Prerequisites Check"
echo "=================================================="
echo ""

# Check 1: CMake
echo "Checking prerequisites..."
echo ""

if command -v cmake &> /dev/null; then
    CMAKE_VERSION=$(cmake --version | head -n1 | cut -d' ' -f3)
    print_status 0 "CMake found (version $CMAKE_VERSION)"
else
    print_status 1 "CMake not found"
    echo "  Install: sudo apt-get install cmake"
    exit 1
fi

# Check 2: Make/Ninja
if command -v make &> /dev/null; then
    MAKE_VERSION=$(make --version | head -n1)
    print_status 0 "Make found"
elif command -v ninja &> /dev/null; then
    NINJA_VERSION=$(ninja --version)
    print_status 0 "Ninja found (version $NINJA_VERSION)"
else
    print_status 1 "Neither Make nor Ninja found"
    echo "  Install: sudo apt-get install build-essential"
    exit 1
fi

# Check 3: Python (for build scripts)
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_status 0 "Python3 found (version $PYTHON_VERSION)"
else
    print_warning "Python3 not found (optional for some build scripts)"
fi

# Check 4: Android NDK
echo ""
echo "Checking Android NDK..."
NDK_PATH="/home/leixian/workspace/3rdpartLib"

if [ -d "$NDK_PATH" ]; then
    print_status 0 "NDK directory exists: $NDK_PATH"
    
    # Check for essential NDK files
    if [ -f "$NDK_PATH/build/cmake/android.toolchain.cmake" ]; then
        print_status 0 "Android CMake toolchain found"
    else
        print_status 1 "Android CMake toolchain not found"
        print_warning "The NDK path may be incorrect"
        echo "  Expected: $NDK_PATH/build/cmake/android.toolchain.cmake"
    fi
else
    print_status 1 "NDK directory not found: $NDK_PATH"
    echo "  Please download Android NDK from:"
    echo "  https://developer.android.com/ndk/downloads"
    exit 1
fi

# Check 5: OpenCV Source
echo ""
echo "Checking OpenCV source..."
OPENCV_SOURCE_DIR="/home/leixian/workspace/3rdpartLib/opencv-4.12.0"

if [ -d "$OPENCV_SOURCE_DIR" ]; then
    print_status 0 "OpenCV source directory found"
    
    if [ -f "$OPENCV_SOURCE_DIR/CMakeLists.txt" ]; then
        print_status 0 "OpenCV CMakeLists.txt found"
        
        # Try to detect version
        if [ -f "$OPENCV_SOURCE_DIR/modules/core/include/opencv2/core/version.hpp" ]; then
            VERSION_FILE="$OPENCV_SOURCE_DIR/modules/core/include/opencv2/core/version.hpp"
            MAJOR=$(grep "CV_VERSION_MAJOR" "$VERSION_FILE" | awk '{print $3}')
            MINOR=$(grep "CV_VERSION_MINOR" "$VERSION_FILE" | awk '{print $3}')
            REVISION=$(grep "CV_VERSION_REVISION" "$VERSION_FILE" | awk '{print $3}')
            print_info "OpenCV version: $MAJOR.$MINOR.$REVISION"
        fi
    else
        print_status 1 "OpenCV CMakeLists.txt not found"
        exit 1
    fi
else
    print_status 1 "OpenCV source not found: $OPENCV_SOURCE_DIR"
    echo "  Please download OpenCV 4.12.0 from:"
    echo "  https://github.com/opencv/opencv/archive/refs/tags/4.12.0.tar.gz"
    exit 1
fi

# Check 6: Disk Space
echo ""
echo "Checking disk space..."
BUILD_DIR="/home/leixian/workspace/3rdpartLib/opencv-build-android"
AVAILABLE_SPACE=$(df -BG $(dirname "$BUILD_DIR") | tail -1 | awk '{print $4}' | sed 's/G//')

if [ "$AVAILABLE_SPACE" -gt 5 ]; then
    print_status 0 "Sufficient disk space available (${AVAILABLE_SPACE}G)"
else
    print_warning "Limited disk space (${AVAILABLE_SPACE}G available)"
    echo "  Recommended: At least 5GB free space"
fi

# Check 7: Memory
echo ""
echo "Checking system memory..."
TOTAL_MEM=$(free -g | grep Mem | awk '{print $2}')

if [ "$TOTAL_MEM" -gt 4 ]; then
    print_status 0 "Sufficient memory available (${TOTAL_MEM}GB)"
else
    print_warning "Limited memory (${TOTAL_MEM}GB)"
    echo "  Recommended: At least 4GB RAM"
    echo "  Consider reducing parallel jobs in build script"
fi

# Summary
echo ""
echo "=================================================="
echo "Prerequisites Check Summary"
echo "=================================================="
echo ""
print_info "All essential prerequisites are met!"
echo ""
echo "You can now run the build script:"
echo "  chmod +x build_opencv_android.sh"
echo "  ./build_opencv_android.sh"
echo ""
echo "Estimated build time: 30-60 minutes (depends on CPU)"
echo "Estimated disk usage: 3-5 GB"
echo ""
