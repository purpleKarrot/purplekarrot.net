
include(AddExternal)
include(ParseArguments)


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
  set(XML_FILE ${CMAKE_CURRENT_BINARY_DIR}/${THIS_PROJECT_NAME}.xml)

  # copy to destination directory because quickbook screws up xinclude paths 
  # when the output is not in the source directory
  add_custom_command(OUTPUT ${QBK_FILE}
    COMMAND ${CMAKE_COMMAND} -E copy ${INPUT_PATH} ${QBK_FILE}
    DEPENDS ${INPUT_PATH})

  add_custom_command(OUTPUT ${XML_FILE}
    COMMAND quickbook "--output-file=${XML_FILE}" ${QBK_FILE}
    DEPENDS ${QBK_FILE} ${ARGN})
    
  add_custom_target(${THIS_PROJECT_NAME}-doc DEPENDS ${XML_FILE})
  set_target_properties(${THIS_PROJECT_NAME}-doc PROPERTIES 
    LOCATION ${XML_FILE})

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
    add_subdirectory(${PROJECT_SOURCE_DIR}/doc ${PROJECT_SOURCE_DIR}/bin
      EXCLUDE_FROM_ALL)
    
    get_target_property(LOC ${THIS_PROJECT_NAME}-doc LOCATION)
    if(LOC)
      set(DEPENDENCIES ${DEPENDENCIES} ${LOC})
    endif(LOC)
  endif(EXISTS ${PROJECT_SOURCE_DIR}/doc/CMakeLists.txt)

endmacro(add_repository)


# collect external projects to documentation
macro(add_projects OUTPUT NAME)

  set(REPOSITORIES_URL http://github.com/api/v2/xml/repos/show/${NAME})
  set(REPOSITORIES_XML ${CMAKE_BINARY_DIR}/repositories.xml)
  set(REPOSITORIES_XSL ${CMAKE_SOURCE_DIR}/xsl/repositories/main.xsl)
  set(REPOSITORIES_CMK ${CMAKE_BINARY_DIR}/repositories.cmake)

  file(DOWNLOAD ${REPOSITORIES_URL} ${REPOSITORIES_XML})

  execute_process(COMMAND ${XSLTPROC_EXECUTABLE}
    -o ${REPOSITORIES_CMK} ${REPOSITORIES_XSL} ${REPOSITORIES_XML})

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/projects.qbk)
  file(WRITE ${QBK_FILE}
    "[part Projects\n"
    "  [quickbook 1.5]\n"
    "  [id projects]\n"
    "  [dirname projects]\n"
    "]\n\n")

  set(DEPENDENCIES)
  include(${REPOSITORIES_CMK})

  foreach(DEP ${DEPENDENCIES})
    message(STATUS ${DEP})
    file(RELATIVE_PATH DEP_REL ${CMAKE_CURRENT_BINARY_DIR} ${DEP})
    file(APPEND ${QBK_FILE} "[xinclude ${DEP_REL}]\n")
  endforeach(DEP ${DEPENDENCIES})

  quickbook_to_boostbook(${OUTPUT} ${QBK_FILE})

endmacro(add_projects OUTPUT)
