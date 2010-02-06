
find_package(Git REQUIRED)
find_package(Subversion REQUIRED)

macro(add_external SOURCE_VAR NAME VCS URL)

  if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/external/)
  endif(NOT EXISTS ${CMAKE_BINARY_DIR}/external/)

  set(DIRECTORY ${CMAKE_BINARY_DIR}/external/${NAME})
  set(${SOURCE_VAR} ${DIRECTORY})

  string(TOUPPER ${VCS} VCS)
  if(VCS STREQUAL "GIT")
    set(EXTERNAL_CO_COMMAND
      ${Git_EXECUTABLE} clone ${URL} ${DIRECTORY})
    set(EXTERNAL_UP_COMMAND
      ${Git_EXECUTABLE} pull origin master)
  elseif(VCS STREQUAL "SVN")
    set(EXTERNAL_CO_COMMAND
      ${Subversion_SVN_EXECUTABLE} --quiet checkout ${URL} ${DIRECTORY})
    set(EXTERNAL_UP_COMMAND
      ${Subversion_SVN_EXECUTABLE} --quiet update)
  else()
    MESSAGE(FATAL_ERROR "Invalid VCS: ${VCS}. Supported values are: GIT and SVN.")
  endif()

  if(NOT EXISTS ${DIRECTORY})
    message(STATUS "Fetching ${NAME} from ${VCS}.")
    execute_process(COMMAND ${EXTERNAL_CO_COMMAND})
  endif(NOT EXISTS ${DIRECTORY})

  add_custom_target(${NAME}-update 
    COMMAND ${EXTERNAL_UP_COMMAND}
    WORKING_DIRECTORY ${DIRECTORY}
    COMMENT "Update ${NAME} to latest revision."
    )

endmacro(add_external SOURCE_VAR NAME VCS URL)
