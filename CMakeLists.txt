##############################################################
# Copyright (c) 2010 Daniel Pfeifer                          #
##############################################################

cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(purplekarrot.net)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)

#if windows
#  set(Boost_USE_STATIC_LIBS ON)
#  add_definitions(-DBOOST_ALL_NO_LIB)
#  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
#  add_definitions(-D_SCL_SECURE_NO_WARNINGS)
#endif

include(BoostBook)
include(Doxygen)
include(QuickBook)

set(OUTPUT_PATH /home/daniel/Desktop/purple)

add_subdirectory(blog)
add_subdirectory(css)
