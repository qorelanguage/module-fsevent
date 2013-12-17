#
# to use the file to build a Qt only version of PHP-Qt, copy it to CMakeLists.txt
#
# make a build/ dir, step into
# run: cmake ..
# run: make
#
# for further information read the README file in php/phpqt
#
cmake_minimum_required(VERSION 2.6)

project(qore-fsevent-module)

set (VERSION_MAJOR 1)
set (VERSION_MINOR 0)
set (VERSION_PATCH 0)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )


SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall")


# make uninstall
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY
)
ADD_CUSTOM_TARGET(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")


SET(QORE_MIN_VERSION "0.8.8")
FIND_PACKAGE (Qore REQUIRED)

FIND_PACKAGE (Doxygen)


add_definitions("-DPACKAGE_VERSION=\"${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}\"")

include_directories( ${QORE_INCLUDE_DIR} )
include_directories( ${CMAKE_SOURCE_DIR}/src )


#link_directories( ${LIBEDIT_LIBRARY_DIRS} )
include_directories( ${CMAKE_SOURCE_DIR}/src/include )
include_directories( ${CMAKE_SOURCE_DIR}/src/efsw )


set(CPP_SRC
)
set(QPP_SRC
    src/fsevent.qpp
    src/constants.qpp
    src/QC_FSWatcher.qpp
)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "debug")
endif (NOT CMAKE_BUILD_TYPE)

string(TOLOWER ${CMAKE_BUILD_TYPE} BUILD_TYPE_LWR)
if (${BUILD_TYPE_LWR} MATCHES "debug")
    add_definitions(-DDEBUG)
else ()
    add_definitions(-DNDEBUG)
endif ()

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
set_target_properties(${module_name} PROPERTIES PREFIX "" SUFFIX "-api-${QORE_API_VERSION}.qmod")
target_link_libraries(${module_name} ${QORE_LIBRARY} )
install( TARGETS ${module_name} DESTINATION ${QORE_MODULES_DIR})


# docs
if (DOXYGEN_FOUND)
    configure_file(${CMAKE_SOURCE_DIR}/docs/Doxyfile.in ${CMAKE_BINARY_DIR}/Doxyfile @ONLY)

    add_custom_target(docs ALL
        ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen" VERBATIM
    )
endif (DOXYGEN_FOUND)



MESSAGE(STATUS "")
MESSAGE(STATUS "-----------------------------")
MESSAGE(STATUS "System: ${CMAKE_SYSTEM}")
IF (APPLE)
    MESSAGE(STATUS "Archs: ${CMAKE_OSX_ARCHITECTURES}")
ENDIF (APPLE)
MESSAGE(STATUS "Compiler: ${CMAKE_CXX_COMPILER} - ${CMAKE_CXX_COMPILER_ID}")
MESSAGE(STATUS "FLags deb: ${CMAKE_CXX_FLAGS_DEBUG}")
MESSAGE(STATUS "FLags rel: ${CMAKE_CXX_FLAGS}")
MESSAGE(STATUS "-----------------------------")


# packaging related stuff
string(TOLOWER ${CMAKE_PROJECT_NAME} CPACK_PACKAGE_NAME)
SET(CPACK_PACKAGE_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
SET(CPACK_SOURCE_GENERATOR "TBZ2")
SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
SET(CPACK_IGNORE_FILES "/CVS/;/\\\\.svn/;\\\\.swp$;\\\\.#;/#;\\\\.~$;\\\\.tar.gz$;/CMakeFiles/;CMakeCache.txt;refresh-copyright-and-license.pl;\\\\.spec$")
SET(CPACK_SOURCE_IGNORE_FILES ${CPACK_IGNORE_FILES})
INCLUDE(CPack)
# simulate autotools' "make dist"
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

