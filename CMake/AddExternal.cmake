
find_package(Git REQUIRED)
find_package(Subversion REQUIRED)
find_program(UNZIP unzip)

macro(add_external SOURCE_VAR NAME VCS URL)

  if(NOT EXISTS ${CMAKE_BINARY_DIR}/external/)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/external/)
  endif(NOT EXISTS ${CMAKE_BINARY_DIR}/external/)

  set(DIRECTORY ${CMAKE_BINARY_DIR}/external/${NAME})
  set(${SOURCE_VAR} ${DIRECTORY})

  if(NOT EXISTS ${DIRECTORY})
    message(STATUS "Fetching external: ${NAME}.")
    string(TOUPPER ${VCS} VCS)
    if(VCS STREQUAL "GIT")
      execute_process(COMMAND
        ${Git_EXECUTABLE} clone ${URL} ${DIRECTORY})
    elseif(VCS STREQUAL "SVN")
      execute_process(COMMAND
        ${Subversion_SVN_EXECUTABLE} --quiet checkout ${URL} ${DIRECTORY})
    elseif(VCS STREQUAL "ZIP")
      file(DOWNLOAD ${URL} ${CMAKE_BINARY_DIR}/${NAME}.zip TIMEOUT 60)
      execute_process(COMMAND
        ${UNZIP} -d ${DIRECTORY} -q ${CMAKE_BINARY_DIR}/${NAME}.zip)
      file(REMOVE ${CMAKE_BINARY_DIR}/${NAME}.zip)
    else()
      MESSAGE(FATAL_ERROR "Invalid VCS: ${VCS}. Supported values are: GIT, SVN and ZIP.")
    endif()
  endif(NOT EXISTS ${DIRECTORY})

endmacro(add_external SOURCE_VAR NAME VCS URL)
