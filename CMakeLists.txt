cmake_minimum_required(VERSION 2.8.3)

project(qore-fsevent-module)

set (VERSION_MAJOR 1)
set (VERSION_MINOR 0)
set (VERSION_PATCH 0)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )


FIND_PACKAGE (Qore REQUIRED)

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
    src/QC_FSWatcher.qpp
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
    set(EFSW_SRC ${EFSW_SRC} src/efsw/FileWatcherFSEvents.cpp src/efsw/WatcherFSEvents.cpp)
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


add_definitions(-DUSE_UTF8)

qore_wrap_qpp(QPP_SOURCES "${QPP_SRC}")

SET (module_name "fsevent")

add_library(${module_name} SHARED ${CPP_SRC} ${QPP_SOURCES} ${EFSW_SRC})

qore_binary_module(${module_name} "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

qore_dist("${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

qore_config_info()


