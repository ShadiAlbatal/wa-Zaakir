# Build native library for DuaHifz

cmake_minimum_required(VERSION 3.10)
project("duahifz_native")

# Add your native library
add_library(
    duahifz_native
    SHARED
    speech_recognition.cpp
)

# Include libraries
find_library(
    log-lib
    android
)

# Link libraries
target_link_libraries(
    duahifz_native
    ${log-lib}
    android
)
