################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_package(Git REQUIRED)
include(AddDocumentation)

macro(boost_documentation)
  add_documentation(${ARGN})
endmacro(boost_documentation)

set(PROJECTS
  Boost.CMake
# async-db
  libMaoni
  Equalizer
# JunkLoad
# glcc
  )

foreach(PROJECT ${PROJECTS})
  set(PROJECT_SOURCE_DIR ${CMAKE_SOURCE_DIR}/../${PROJECT})
  set(PROJECT_BINARY_DIR ${CMAKE_BINARY_DIR}/${PROJECT})

  if(EXISTS ${PROJECT_SOURCE_DIR})
    message(STATUS "${PROJECT} dir: ${PROJECT_SOURCE_DIR}")
  elseif(NOT EXISTS ${PROJECT_BINARY_DIR}-src)
    set(PROJECT_SOURCE_DIR ${PROJECT_BINARY_DIR}-src)
    set(PROJECT_GIT_URL "git://github.com/purpleKarrot/${PROJECT}.git")
    execute_process(COMMAND
      ${GIT_EXECUTABLE} clone ${PROJECT_GIT_URL} ${PROJECT_SOURCE_DIR})
  endif()

  set(THIS_PROJECT_NAME ${PROJECT})

  if(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)
    # add_subdirectory(${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} EXCLUDE_FROM_ALL)
    add_subdirectory(${PROJECT_SOURCE_DIR}/doc ${PROJECT_BINARY_DIR})
  endif()
endforeach(PROJECT)
