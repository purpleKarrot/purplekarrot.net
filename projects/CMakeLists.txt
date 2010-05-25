################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

include(AddReference)
include(XSLTransform)
find_package(BoostBook)
find_package(Git REQUIRED)


macro(add_documentation INPUT)

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

  # copy all dependencies that are not built
  set(DEPENDENCIES)
  foreach(file ${ARGN})
    set(srcfile ${CMAKE_CURRENT_SOURCE_DIR}/${file})
    set(binfile ${CMAKE_CURRENT_BINARY_DIR}/${file})
    if(EXISTS ${srcfile})
      add_custom_command(OUTPUT ${binfile}
        COMMAND ${CMAKE_COMMAND} -E copy ${srcfile} ${binfile}
        DEPENDS ${srcfile})
    endif(EXISTS ${srcfile})
    set(DEPENDENCIES ${DEPENDENCIES} ${binfile})
  endforeach(file ${ARGN})

  quickbook_to_docbook(${DBK_FILE} ${QBK_FILE} ${DEPENDENCIES})

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    ${DBK_FILE} ${XSL_FILES}
    STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY index.html
    MAKE_ALL_TARGET ${THIS_PROJECT_NAME}-doc
    )

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    DESTINATION www/doc)

endmacro(add_documentation INPUT)


macro(add_repository NAME URL)

  set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${NAME})

  if(NOT EXISTS ${PROJECT_SOURCE_DIR})
    execute_process(COMMAND
      ${Git_EXECUTABLE} clone ${URL} ${PROJECT_SOURCE_DIR})
  endif(NOT EXISTS ${PROJECT_SOURCE_DIR})

  add_custom_target(${NAME}-update ${Git_EXECUTABLE} pull origin master
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
add_repository(shutter  git://github.com/shutter/libMaoni.git)
add_repository(glcc     git://github.com/purpleKarrot/glcc.git)
