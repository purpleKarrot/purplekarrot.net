################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

include(ParseArguments)
include(AddReference)
include(XSLTransform)
find_package(BoostBook)
find_package(Git REQUIRED)
find_package(ImageMagick COMPONENTS convert)

macro(add_documentation INPUT)
  parse_arguments(DOCUMENTATION "IMAGES" "" ${ARGN})

  # If INPUT is not a full path, it's in the current source directory.
  get_filename_component(INPUT_PATH ${INPUT} PATH)
  if(INPUT_PATH STREQUAL "")
    set(INPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}")
  else(INPUT_PATH STREQUAL "")
    set(INPUT_PATH ${INPUT})
  endif(INPUT_PATH STREQUAL "")

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.qbk)
  set(DBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.docbook)

  # copy to destination directory because quickbook screws up xinclude paths 
  # when the output is not in the source directory
  add_custom_command(OUTPUT ${QBK_FILE}
    COMMAND ${CMAKE_COMMAND} -E copy ${INPUT_PATH} ${QBK_FILE}
    DEPENDS ${INPUT_PATH})

  set(DEPENDENCIES)

  # copy images
  set(IMGDIR ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME})
  file(MAKE_DIRECTORY ${IMGDIR})
  foreach(IMAGE ${DOCUMENTATION_IMAGES})
    get_filename_component(NAME ${IMAGE} NAME)
    get_filename_component(ABSOLUTE ${IMAGE} ABSOLUTE)
    add_custom_command(OUTPUT ${IMGDIR}/s_${NAME}
      COMMAND ${ImageMagick_convert_EXECUTABLE} ${ABSOLUTE} -resize 220x220 ${IMGDIR}/s_${NAME}
      DEPENDS ${ABSOLUTE})
    add_custom_command(OUTPUT ${IMGDIR}/${NAME}
      COMMAND ${ImageMagick_convert_EXECUTABLE} ${ABSOLUTE} -resize 800x600 ${IMGDIR}/${NAME}
      DEPENDS ${ABSOLUTE})
    list(APPEND DEPENDENCIES ${IMGDIR}/s_${NAME} ${IMGDIR}/${NAME})
  endforeach(IMAGE ${DOCUMENTATION_IMAGES})

  # copy all dependencies that are not built
  foreach(file ${DOCUMENTATION_DEFAULT_ARGS})
    set(srcfile ${CMAKE_CURRENT_SOURCE_DIR}/${file})
    set(binfile ${CMAKE_CURRENT_BINARY_DIR}/${file})
    if(EXISTS ${srcfile})
      add_custom_command(OUTPUT ${binfile}
        COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
        DEPENDS ${srcfile})
    endif(EXISTS ${srcfile})
    list(APPEND DEPENDENCIES ${binfile})
  endforeach(file ${DOCUMENTATION_DEFAULT_ARGS})

  quickbook_to_docbook(${DBK_FILE} ${QBK_FILE} ${DEPENDENCIES})

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    ${DBK_FILE} ${XSL_FILES}
    STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY index.html
    MAKE_ALL_TARGET ${THIS_PROJECT_NAME}-doc
    )

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    DESTINATION doc)

endmacro(add_documentation INPUT)


set(PROJECTS
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
    add_subdirectory(${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} EXCLUDE_FROM_ALL)
  endif()
endforeach(PROJECT)
