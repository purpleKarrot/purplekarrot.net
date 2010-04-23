include(AddExternal)
include(ParseArguments)
include(XSLTransform)
find_package(BoostBook)

# Transform Quickbook into BoostBook XML
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

  quickbook_to_docbook(${DBK_FILE} ${QBK_FILE} ${ARGN})

  xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME} ${DBK_FILE}
    STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
    CATALOG ${BOOSTBOOK_CATALOG}
    DIRECTORY index.html
    MAKE_ALL_TARGET ${THIS_PROJECT_NAME}-doc
    )

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}
    DESTINATION www/doc)

endmacro(add_documentation INPUT)


set(GITHUB_ARGS
  DESCRIPTION
  OPEN_ISSUES
  HOMEPAGE
  URL
  FORK
  WATCHERS
  FORKS
  PRIVATE
  NAME
  OWNER
  )

macro(add_repository)

  parse_arguments(THIS_PROJ "${GITHUB_ARGS}" "" ${ARGN})
  add_external(THIS_EXTERNAL ${THIS_PROJ_NAME} GIT ${THIS_PROJ_URL}.git)

  set(THIS_PROJECT_NAME ${THIS_PROJ_NAME})
  set(PROJECT_SOURCE_DIR ${THIS_EXTERNAL})

  if(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)
    add_subdirectory(${PROJECT_SOURCE_DIR}/doc ${PROJECT_SOURCE_DIR}/build/doc)
  endif(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)

#    get_target_property(LOC ${THIS_PROJECT_NAME}-doc LOCATION)
#    if(LOC)
#      set(DEPENDENCIES ${DEPENDENCIES} ${LOC})
#    endif(LOC)

endmacro(add_repository)
