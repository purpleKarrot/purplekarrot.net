
find_program(SASS_EXECUTABLE sass)

macro(add_css OUTPUT)

if(SASS_EXECUTABLE)

  get_filename_component(NAME ${OUTPUT} NAME_WE)
  set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/${NAME}.sass)

  set(DEPENDENCIES)
  file(REMOVE ${SASS_FILE})
  
  foreach(DEPENDENCY ${ARGN})
    set(DEPENDENCIES ${DEPENDENCIES} ${DEPENDENCY})
    file(APPEND ${SASS_FILE} "@import ../${DEPENDENCY}\n")
  endforeach(DEPENDENCY ${ARGN})

  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${SASS_EXECUTABLE} ${SASS_FILE} ${OUTPUT}
    DEPENDS ${DEPENDENCIES}
    )

  add_custom_target(${NAME}-css ALL DEPENDS ${OUTPUT})

endif(SASS_EXECUTABLE)

endmacro(add_css OUTPUT)
