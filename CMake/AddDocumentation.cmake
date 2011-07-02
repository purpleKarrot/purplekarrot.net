################################################################################
# Copyright (c) 2010-2011 Daniel Pfeifer                                       #
################################################################################

include(BoostXsltproc)
include(CMakeParseArguments)
find_package(ImageMagick COMPONENTS convert)


function(add_documentation INPUT)
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
  set(IMGDIR ${CMAKE_CURRENT_BINARY_DIR}/www/images)
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
    COMMAND $<TARGET_FILE:quickbook> -I "${CMAKE_CURRENT_SOURCE_DIR}"
            "--output-file=${XML_FILE}" ${QBK_FILE}
    DEPENDS ${QBK_FILE} ${DEPENDENCIES}
    )
  boost_xsltproc(${DBK_FILE} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${XML_FILE}
    CATALOGS
      ${BOOSTBOOK_CATALOG}
    DEPENDS
      ${DEPENDENCIES}
    )
  boost_xsltproc(${CMAKE_CURRENT_BINARY_DIR}/www/index.html
    ${CMAKE_SOURCE_DIR}/xsl-html5/chunked.xsl ${DBK_FILE}
    CATALOGS
      ${BOOSTBOOK_CATALOG}
    DEPENDS
      ${XSL_FILES}
    )
  add_custom_target(${THIS_PROJECT_NAME}-doc ALL DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/www/index.html
    )
  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/www/
    DESTINATION doc
    )
endfunction(add_documentation INPUT)
