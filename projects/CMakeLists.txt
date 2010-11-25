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


macro(add_repository NAME URL)

  set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${NAME})

  if(NOT EXISTS ${PROJECT_SOURCE_DIR})
    execute_process(COMMAND
      ${GIT_EXECUTABLE} clone ${URL} ${PROJECT_SOURCE_DIR})
  endif(NOT EXISTS ${PROJECT_SOURCE_DIR})

  add_custom_target(${NAME}-update ${GIT_EXECUTABLE} pull origin master
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
  add_dependencies(update ${NAME}-update)

  set(THIS_PROJECT_NAME ${NAME})

  if(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)
    add_subdirectory(${PROJECT_SOURCE_DIR}/doc ${PROJECT_SOURCE_DIR}/build/doc)
  endif(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)

endmacro(add_repository NAME URL)


add_custom_target(update)

add_repository(async-db git://github.com/purpleKarrot/async-db.git)
add_repository(libMaoni git://github.com/purpleKarrot/libMaoni.git)
add_repository(JunkLoad git://github.com/purpleKarrot/JunkLoad)
add_repository(glcc     git://github.com/purpleKarrot/glcc.git)
