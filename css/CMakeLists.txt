################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_package(Sass REQUIRED)
find_package(CSSTidy REQUIRED)

set(SASS_INPUT_FILES
  pixelGreen.sass
  admonition.sass
  navigation.sass
  fork-me.sass
  disqus.sass
  code.sass
  )

set(CSS_FILE  ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.css)
set(RAW_FILE  ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.uncompressed.css)
set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.sass)

set(DEPENDENCIES)
file(REMOVE ${SASS_FILE})

foreach(FILE ${SASS_INPUT_FILES})
  file(RELATIVE_PATH FILE ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/${FILE})
  file(APPEND ${SASS_FILE} "@import ${FILE}\n")
endforeach(FILE ${SASS_INPUT_FILES})

add_custom_command(OUTPUT ${RAW_FILE}
  COMMAND ${SASS_EXECUTABLE} ${SASS_FILE} ${RAW_FILE}
  DEPENDS ${SASS_INPUT_FILES}
  )

add_custom_command(OUTPUT ${CSS_FILE}
  COMMAND ${CSSTIDY_EXECUTABLE} ${RAW_FILE} ${CSSTIDY_PARAMETERS} ${CSS_FILE}
  DEPENDS ${RAW_FILE}
  )

add_custom_target(css ALL DEPENDS ${CSS_FILE})

install(FILES ${CSS_FILE} DESTINATION www)
