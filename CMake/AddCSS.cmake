
include(FindPackageHandleStandardArgs)

find_program(SASS_EXECUTABLE sass)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Sass DEFAULT_MSG SASS_EXECUTABLE)

find_program(CSSTIDY_EXECUTABLE csstidy)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(csstidy DEFAULT_MSG CSSTIDY_EXECUTABLE)
set(CSSTIDY_PARAMETERS --silent=true --template=highest)

macro(add_css OUTPUT)

  get_filename_component(NAME ${OUTPUT} NAME_WE)
  set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/${NAME}.sass)
  set(MESS_FILE ${CMAKE_CURRENT_BINARY_DIR}/${NAME}-raw.css)

  set(DEPENDENCIES)
  file(REMOVE ${SASS_FILE})
  
  foreach(DEPENDENCY ${ARGN})
    set(DEPENDENCIES ${DEPENDENCIES} ${DEPENDENCY})
    file(APPEND ${SASS_FILE} "@import ../${DEPENDENCY}\n")
  endforeach(DEPENDENCY ${ARGN})

  add_custom_command(OUTPUT ${MESS_FILE}
    COMMAND ${SASS_EXECUTABLE} ${SASS_FILE} ${MESS_FILE}
    DEPENDS ${DEPENDENCIES}
    )

  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${CSSTIDY_EXECUTABLE} ${MESS_FILE} ${CSSTIDY_PARAMETERS} ${OUTPUT}
    DEPENDS ${MESS_FILE}
    )

  add_custom_target(${NAME}-css ALL DEPENDS ${OUTPUT})

endmacro(add_css OUTPUT)
