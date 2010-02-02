
find_program(SASS_EXECUTABLE sass)

set(INPUT ${CMAKE_CURRENT_SOURCE_DIR}/purpleKarrot.sass)
set(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/purpleKarrot.css)

set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/purpleKarrot.sass)

file(WRITE ${SASS_FILE}
  "@import ${CMAKE_CURRENT_SOURCE_DIR}/pixelGreen.sass\n"
  "@import ${CMAKE_CURRENT_SOURCE_DIR}/admonition.sass\n"
  )

add_custom_command(OUTPUT ${OUTPUT}
  COMMAND ${SASS_EXECUTABLE} ${INPUT} ${OUTPUT}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Generating CSS from ${INPUT}."
  DEPENDS purpleKarrot.sass
          pixelGreen.sass
          admonition.sass
          disqus.sass
  )

add_custom_target(styles ALL DEPENDS ${OUTPUT})

install(FILES ${OUTPUT} DESTINATION ${OUTPUT_PATH}/css)
