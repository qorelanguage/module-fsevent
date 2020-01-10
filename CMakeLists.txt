cmake_minimum_required(VERSION 3.0.0)

project(qore-fsevent-module VERSION 1.0.0)

include(CheckCXXCompilerFlag)
include(CheckCXXSourceCompiles)
include(CheckCXXSymbolExists)
include(CheckIncludeFileCXX)

# Check for C++11.
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
else()
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )

# enable RPATH in macos bins (OS requires this in any case)
if (POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

find_package(Qore 0.9 REQUIRED)
qore_find_pthreads()

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
else()
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -framework CoreFoundation -framework CoreServices")
endif (APPLE)


include_directories( ${CMAKE_SOURCE_DIR}/src )
include_directories( ${CMAKE_SOURCE_DIR}/src/include )
include_directories( ${CMAKE_SOURCE_DIR}/src/efsw )

set(CPP_SRC
)
set(QPP_SRC
    src/fsevent.qpp
    src/constants.qpp
    src/QC_AbstractFsWatcher.qpp
)

set(EFSW_SRC
    src/efsw/Debug.cpp
    src/efsw/DirectorySnapshot.cpp
    src/efsw/DirectorySnapshotDiff.cpp
    src/efsw/DirWatcherGeneric.cpp
    src/efsw/FileInfo.cpp
    src/efsw/FileSystem.cpp
    src/efsw/FileWatcher.cpp
    src/efsw/FileWatcherCWrapper.cpp
    src/efsw/FileWatcherGeneric.cpp
    src/efsw/FileWatcherImpl.cpp
    src/efsw/Log.cpp
    src/efsw/Mutex.cpp
    src/efsw/sophist.h
    src/efsw/String.cpp
    src/efsw/System.cpp
    src/efsw/Thread.cpp
#    src/efsw/Utf.inl
    src/efsw/Watcher.cpp
    src/efsw/WatcherGeneric.cpp
)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(EFSW_SRC ${EFSW_SRC} src/efsw/FileWatcherKqueue.cpp src/efsw/WatcherKqueue.cpp)
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(EFSW_SRC ${EFSW_SRC} src/efsw/FileWatcherInotify.cpp src/efsw/WatcherInotify.cpp)
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "^.*BSD$")
    set(EFSW_SRC ${EFSW_SRC} src/efsw/FileWatcherKqueue.cpp src/efsw/WatcherKqueue.cpp)
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(EFSW_SRC ${EFSW_SRC} src/efsw/FileWatcherWin32.cpp src/efsw/WatcherWin32.cpp)
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(EFSW_SRC ${EFSW_SRC}
        src/efsw/platform/win/FileSystemImpl.cpp
        src/efsw/platform/win/MutexImpl.cpp
        src/efsw/platform/win/SystemImpl.cpp
        src/efsw/platform/win/ThreadImpl.cpp
    )
else ()
    # posix systems
    set(EFSW_SRC ${EFSW_SRC}
        src/efsw/platform/posix/FileSystemImpl.cpp
        src/efsw/platform/posix/MutexImpl.cpp
        src/efsw/platform/posix/SystemImpl.cpp
        src/efsw/platform/posix/ThreadImpl.cpp
    )
endif ()

add_definitions(-DUSE_UTF8 -DEFSW_FSEVENTS_NOT_SUPPORTED=1)

qore_wrap_qpp_value(QPP_SOURCES ${QPP_SRC})

SET (module_name "fsevent")

set(QORE_DOX_TMPL_SRC
  docs/mainpage.dox.tmpl
)

add_library(${module_name} SHARED ${CPP_SRC} ${QPP_SOURCES} ${EFSW_SRC})

if (WIN32 AND MINGW AND MSYS)
    target_compile_definitions(${module_name} PUBLIC BUILDING_DLL)
endif (WIN32 AND MINGW AND MSYS)

qore_binary_module_new(${module_name} ${PROJECT_VERSION} "")

add_custom_target(docs-fsevent)

qore_module_user_module("qlib/FsEventPollerUtil.qm" "")
qore_module_user_module("qlib/FsEventPoller.qm" "FsEventPollerUtil")

qore_dist(${PROJECT_VERSION})

qore_config_info()

FIND_PACKAGE(Doxygen)
if (DOXYGEN_FOUND)
  qore_wrap_dox(QORE_DOX_SRC ${QORE_DOX_TMPL_SRC})
  add_custom_target(QORE_MOD_DOX_FILES DEPENDS ${QORE_DOX_SRC})
  add_dependencies(docs QORE_MOD_DOX_FILES)
endif()
