## 使用方法
### 解压命令
tar -xvf onnxruntime-linux-x64-1.23.2.tgz
### cmake构建方式
只需要在项目中set(ONNXRUNTIME_ROOT_DIR 解压的地址)
下面命令是帮助找到对应头文件和lib库(这里需要多熟悉一下cmake的相关知识)
```
# Configure ONNX Runtime dependency as a separate module

# Allow setting ONNXRUNTIME_ROOT_DIR via environment if not passed
if(NOT ONNXRUNTIME_ROOT_DIR AND DEFINED ENV{ONNXRUNTIME_ROOT_DIR})
    set(ONNXRUNTIME_ROOT_DIR "$ENV{ONNXRUNTIME_ROOT_DIR}")
endif()

if(NOT ONNXRUNTIME_ROOT_DIR)
    message(WARNING "ONNXRUNTIME_ROOT_DIR not set. Set it to the ONNX Runtime install root.")
endif()

set(ONNXRUNTIME_INCLUDE_DIRS ${ONNXRUNTIME_ROOT_DIR}/include)
set(ONNXRUNTIME_LIB_DIRS ${ONNXRUNTIME_ROOT_DIR}/lib)

find_library(ONNXRUNTIME_LIBRARY
        NAMES onnxruntime
        PATHS ${ONNXRUNTIME_LIB_DIRS}
        NO_DEFAULT_PATH
)

if(ONNXRUNTIME_LIBRARY)
    message(STATUS "Found ONNX Runtime: ${ONNXRUNTIME_LIBRARY}")
    # Compute DLL path next to library for Windows
    get_filename_component(ONNXRUNTIME_DLL_NAME ${ONNXRUNTIME_LIBRARY} NAME_WE)
    set(ONNXRUNTIME_DLL "${ONNXRUNTIME_LIB_DIRS}/${ONNXRUNTIME_DLL_NAME}.dll")
    if(EXISTS "${ONNXRUNTIME_DLL}")
        message(STATUS "ONNX Runtime DLL: ${ONNXRUNTIME_DLL}")
    else()
        message(WARNING "ONNX Runtime DLL not found at: ${ONNXRUNTIME_DLL}")
    endif()
else()
    message(WARNING "ONNX Runtime library not found. Please set ONNXRUNTIME_ROOT_DIR correctly.")
endif()

```

### cuda版本
cuda版本可在github上重新下载 