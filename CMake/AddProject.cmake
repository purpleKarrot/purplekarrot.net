
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

# add_project(libMaoni
#   REPOSITORY GIT git://github.com/purpleKarrot/libMaoni.git
#   DOCUMENTATION maoni-doc.xml
#   )
macro(add_project NAME VCS REPOSITORY)

  add_external(THIS_EXTERNAL ${NAME} ${VCS} ${REPOSITORY})

  set(THIS_PROJECT_NAME ${NAME})

  set(PROJECT_SOURCE_DIR ${THIS_EXTERNAL})
  set(PROJECT_BINARY_DIR ${CMAKE_BINARY_DIR}/${NAME})

  add_subdirectory(${PROJECT_SOURCE_DIR} ${PROJECT_BINARY_DIR}
    EXCLUDE_FROM_ALL)
    
  get_target_property(LOC ${NAME}-doc LOCATION)
  set(DEPENDENCIES ${DEPENDENCIES} ${LOC})

endmacro(add_project NAME VCS REPOSITORY)


# collect external projects to documentation
macro(add_projects OUTPUT)

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/projects.qbk)
  file(WRITE ${QBK_FILE}
    "[part Projects\n"
    "  [quickbook 1.5]\n"
    "  [id projects]\n"
    "  [dirname projects]\n"
    "]\n\n")

  set(DEPENDENCIES)

  set(PROJ)
  foreach(ITER ${ARGN})
    if(ITER STREQUAL "PROJECT")
      if(PROJ)
        add_project(${PROJ})
        set(PROJ)
      endif(PROJ)
    else(ITER STREQUAL "PROJECT")
      set(PROJ ${PROJ} ${ITER})
    endif(ITER STREQUAL "PROJECT")
  endforeach(ITER ${ARGN})

  if(PROJ)
    add_project(${PROJ})
  endif(PROJ)

  foreach(DEP ${DEPENDENCIES})
    file(RELATIVE_PATH DEP_REL ${CMAKE_CURRENT_BINARY_DIR} ${DEP})
    file(APPEND ${QBK_FILE} "[xinclude ${DEP_REL}]\n")
  endforeach(DEP ${DEPENDENCIES})

  quickbook_to_boostbook(${OUTPUT} ${QBK_FILE})

endmacro(add_projects OUTPUT)
