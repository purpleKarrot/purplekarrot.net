################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_program(CAT cat)
find_program(SASS sass)
find_program(YUICOMPRESSOR yui-compressor)

macro(COMBINE OUTPUT)
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND cat ${ARGN} > ${OUTPUT}
    DEPENDS ${ARGN}
    )
endmacro(COMBINE OUTPUT)

macro(COMPRESS INPUT OUTPUT)
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${YUICOMPRESSOR} -o ${OUTPUT} ${INPUT}
    DEPENDS ${INPUT}
    )
endmacro(COMPRESS INPUT OUTPUT)


set(FANCYBOX_FILE_NAME jquery.fancybox-1.3.1.zip)
set(FANCYBOX_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${FANCYBOX_FILE_NAME})
if(NOT EXISTS ${FANCYBOX_FILE_PATH})
  file(DOWNLOAD http://fancybox.googlecode.com/files/${FANCYBOX_FILE_NAME}
    ${FANCYBOX_FILE_PATH})
endif(NOT EXISTS ${FANCYBOX_FILE_PATH})

set(FANCYBOX_DIR ${CMAKE_CURRENT_BINARY_DIR}/jquery.fancybox-1.3.1/fancybox)

if(NOT EXISTS ${FANCYBOX_DIR})
  include(Extract)
  extract(${FANCYBOX_FILE_PATH} ${CMAKE_CURRENT_BINARY_DIR})
endif(NOT EXISTS ${FANCYBOX_DIR})


set(JQUERY_FILE_NAME jquery-1.4.2.js)
set(JQUERY_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${JQUERY_FILE_NAME})
if(NOT EXISTS ${JQUERY_FILE_PATH})
  file(DOWNLOAD http://code.jquery.com/${JQUERY_FILE_NAME} ${JQUERY_FILE_PATH})
endif(NOT EXISTS ${JQUERY_FILE_PATH})

#http://www.goat1000.com/tagcanvas.php
set(TAGCANVAS_FILE_NAME jquery.tagcanvas.js)
set(TAGCANVAS_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TAGCANVAS_FILE_NAME})
if(NOT EXISTS ${TAGCANVAS_FILE_PATH})
  file(DOWNLOAD http://www.goat1000.com/${TAGCANVAS_FILE_NAME} ${TAGCANVAS_FILE_PATH})
endif(NOT EXISTS ${TAGCANVAS_FILE_PATH})


set(SASS_INPUT_FILES
  css/pixelGreen.sass
  css/admonition.sass
  css/navigation.sass
  css/sidebar.sass
  css/disqus.sass
  css/code.sass
  )

set(CSS_FILE  ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.css)
set(RAW_FILE  ${CMAKE_CURRENT_BINARY_DIR}/uncompressed.css)
set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.sass)

set(DEPENDENCIES)
file(REMOVE ${SASS_FILE})

foreach(FILE ${SASS_INPUT_FILES})
  file(RELATIVE_PATH FILE ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/${FILE})
  file(APPEND ${SASS_FILE} "@import ${FILE}\n")
endforeach(FILE ${SASS_INPUT_FILES})

add_custom_command(OUTPUT ${RAW_FILE}
  COMMAND ${SASS} ${SASS_FILE} ${RAW_FILE}
  DEPENDS ${SASS_INPUT_FILES}
  )


set(COMBINED_CSS ${CMAKE_CURRENT_BINARY_DIR}/combined.css)

combine(${COMBINED_CSS}
  ${RAW_FILE}
  ${FANCYBOX_DIR}/jquery.fancybox-1.3.1.css
  )

set(JS_UNCOMPRESSED ${CMAKE_CURRENT_BINARY_DIR}/uncompressed.js)
set(JS_COMPRESSED   ${CMAKE_CURRENT_BINARY_DIR}/purplekarrot.js)

combine(${JS_UNCOMPRESSED}
  ${JQUERY_FILE_PATH}
  ${TAGCANVAS_FILE_PATH}
  ${FANCYBOX_DIR}/jquery.fancybox-1.3.1.js
  )

compress(${COMBINED_CSS} ${CSS_FILE})
compress(${JS_UNCOMPRESSED} ${JS_COMPRESSED})

add_custom_target(css ALL DEPENDS ${CSS_FILE})
add_custom_target(js  ALL DEPENDS ${JS_COMPRESSED})

install(FILES ${CSS_FILE} ${JS_COMPRESSED} DESTINATION www)
