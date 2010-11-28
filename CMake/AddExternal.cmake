


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
