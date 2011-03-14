################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

include(AddReference)
include(BoostXsltproc)
find_package(Git REQUIRED)
find_package(ImageMagick COMPONENTS convert)

# Transform Quickbook into BoostBook XML
macro(quickbook_to_boostbook OUTPUT INPUT)

  # If INPUT is not a full path, it's in the current source directory.
  get_filename_component(INPUT_PATH ${INPUT} PATH)
  if(INPUT_PATH STREQUAL "")
    set(INPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}")
  else(INPUT_PATH STREQUAL "")
    set(INPUT_PATH ${INPUT})
  endif(INPUT_PATH STREQUAL "")


endmacro(quickbook_to_boostbook OUTPUT INPUT)

# Transform BoostBook XML into DocBook
macro(boostbook_to_docbook OUTPUT INPUT)
  xsl_transform(${OUTPUT} ${INPUT}
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    COMMENT "Generating DocBook from ${INPUT}."
    DEPENDS ${INPUT} ${ARGN}
    )
endmacro(boostbook_to_docbook OUTPUT INPUT)

# Transform Quickbook into BoostBook XML, then BoostBook XML into DocBook
macro(quickbook_to_docbook OUTPUT INPUT)
  get_filename_component(XML_FILE ${INPUT} NAME_WE)
  set(XML_FILE ${XML_FILE}.xml)
  quickbook_to_boostbook(${XML_FILE} ${INPUT} ${ARGN})
  boostbook_to_docbook(${OUTPUT} ${XML_FILE} ${ARGN})
endmacro(quickbook_to_docbook OUTPUT INPUT)


macro(add_documentation INPUT)
  cmake_parse_arguments(DOCUMENTATION "" "" "IMAGES" ${ARGN})

  # If INPUT is not a full path, it's in the current source directory.
  get_filename_component(INPUT_PATH ${INPUT} PATH)
  if(INPUT_PATH STREQUAL "")
    set(INPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}")
  else(INPUT_PATH STREQUAL "")
    set(INPUT_PATH ${INPUT})
  endif(INPUT_PATH STREQUAL "")

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.qbk)
  set(XML_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.xml)
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
  foreach(file ${DOCUMENTATION_UNPARSED_ARGUMENTS})
    set(srcfile ${CMAKE_CURRENT_SOURCE_DIR}/${file})
    set(binfile ${CMAKE_CURRENT_BINARY_DIR}/${file})
    if(EXISTS ${srcfile})
      add_custom_command(OUTPUT ${binfile}
        COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
        DEPENDS ${srcfile})
    endif(EXISTS ${srcfile})
    list(APPEND DEPENDENCIES ${binfile})
  endforeach(file ${DOCUMENTATION_DEFAULT_ARGS})

  add_custom_command(OUTPUT ${XML_FILE}
    COMMAND $<TARGET_FILE:quickbook> #-I ${CMAKE_CURRENT_SOURCE_DIR}
            "--output-file=${XML_FILE}" ${QBK_FILE}
    DEPENDS ${QBK_FILE} ${DEPENDENCIES}
    )
  boost_xsltproc(${DBK_FILE} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${XML_FILE}
    CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
    DEPENDS ${DEPENDENCIES}
    )
  boost_xsltproc(${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}/index.html
    ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl ${DBK_FILE}
    CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
    DEPENDS ${XSL_FILES}
    )
  add_custom_target(${THIS_PROJECT_NAME}-doc ALL DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}/index.html
    )
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    DESTINATION doc
    )
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
    # add_subdirectory(${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR} EXCLUDE_FROM_ALL)
    add_subdirectory(${PROJECT_SOURCE_DIR}/doc ${PROJECT_BINARY_DIR})
  endif()
endforeach(PROJECT)
