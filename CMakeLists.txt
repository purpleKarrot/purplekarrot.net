################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(purplekarrot.net)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CToolBox)

set(CMAKE_INSTALL_PREFIX /var)

if(MSVC)
  set(Boost_USE_STATIC_LIBS ON)
  add_definitions(-DBOOST_ALL_NO_LIB)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS)
endif(MSVC)

################################################################################

file(GLOB_RECURSE XSL_FILES xsl/*.xsl)

add_subdirectory(blog)
add_subdirectory(css)
add_subdirectory(js)
add_subdirectory(other)
add_subdirectory(projects)

install(DIRECTORY images DESTINATION www)
install(FILES static/favicon.ico DESTINATION www)

################################################################################
