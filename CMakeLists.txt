################################################################################
# Copyright (c) 2010-2011 Daniel Pfeifer                                       #
################################################################################

cmake_minimum_required(VERSION 2.8.4 FATAL_ERROR)
project(purplekarrot.net)

set(BOOST_BUILD_DOCUMENTATION ON)
find_package(Boost COMPONENTS boostbook quickbook NO_MODULE)
include(${Boost_USE_FILE})

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)

set(CMAKE_INSTALL_PREFIX /var/www)

if(MSVC)
  set(Boost_USE_STATIC_LIBS ON)
  add_definitions(-DBOOST_ALL_NO_LIB)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS)
endif(MSVC)

################################################################################

file(GLOB_RECURSE XSL_FILES xsl-html5/*.xsl)

add_subdirectory(blog)
add_subdirectory(design)
add_subdirectory(other)
add_subdirectory(projects)

################################################################################
