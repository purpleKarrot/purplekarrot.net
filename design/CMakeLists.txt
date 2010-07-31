################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_program(CAT cat)
find_program(SASS sass)
#find_program(CSSTIDY csstidy)
find_program(YUICOMPRESSOR yui-compressor)

macro(COMBINE OUTPUT)
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${CAT} ${ARGN} > ${OUTPUT}
    DEPENDS ${ARGN}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endmacro(COMBINE OUTPUT)

macro(COMPRESS OUTPUT INPUT)
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${YUICOMPRESSOR} -o ${OUTPUT} ${INPUT}
    DEPENDS ${INPUT}
    )
endmacro(COMPRESS OUTPUT INPUT)


set(FANCYBOX_FILE_NAME jquery.fancybox-1.3.1.zip)
set(FANCYBOX_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${FANCYBOX_FILE_NAME})
if(NOT EXISTS ${FANCYBOX_FILE_PATH})
  file(DOWNLOAD http://fancybox.googlecode.com/files/${FANCYBOX_FILE_NAME}
    ${FANCYBOX_FILE_PATH})
endif(NOT EXISTS ${FANCYBOX_FILE_PATH})

include(Extract)
extract(${FANCYBOX_FILE_PATH} ${CMAKE_CURRENT_BINARY_DIR})

set(FANCYBOX_DIR ${CMAKE_CURRENT_BINARY_DIR}/jquery.fancybox-1.3.1/fancybox)


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


file(READ ${FANCYBOX_DIR}/jquery.fancybox-1.3.1.css FANCYBOX_CSS)
string(REGEX REPLACE "/\\* IE \\*/.*" "" FANCYBOX_CSS ${FANCYBOX_CSS})
string(REPLACE "/*" "/*!" FANCYBOX_CSS ${FANCYBOX_CSS}) # conserve copyright
string(REPLACE "url('" "url('/images/" FANCYBOX_CSS ${FANCYBOX_CSS})
set(FANCYBOX_CSS_FILE ${CMAKE_CURRENT_BINARY_DIR}/fancybox.css)
file(WRITE ${FANCYBOX_CSS_FILE} ${FANCYBOX_CSS})


set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.sass)
combine(${SASS_FILE}
  css/pixelGreen.sass
  css/admonition.sass
  css/navigation.sass
  css/sidebar.sass
  css/disqus.sass
  css/code.sass
  )

set(RAW_FILE  ${CMAKE_CURRENT_BINARY_DIR}/uncompressed.css)
add_custom_command(OUTPUT ${RAW_FILE}
  COMMAND ${SASS} ${SASS_FILE} ${RAW_FILE}
  DEPENDS ${SASS_FILE}
  )

set(COMBINED_CSS ${CMAKE_CURRENT_BINARY_DIR}/combined.css)
combine(${COMBINED_CSS}
  ${RAW_FILE}
  ${FANCYBOX_CSS_FILE}
  )

set(JS_UNCOMPRESSED ${CMAKE_CURRENT_BINARY_DIR}/uncompressed.js)
combine(${JS_UNCOMPRESSED}
  ${JQUERY_FILE_PATH}
  ${TAGCANVAS_FILE_PATH}
  ${FANCYBOX_DIR}/jquery.fancybox-1.3.1.js
  )

set(CSS_FILE      ${CMAKE_CURRENT_BINARY_DIR}/purplekarrot.css)
set(JS_COMPRESSED ${CMAKE_CURRENT_BINARY_DIR}/purplekarrot.js)

#add_custom_command(OUTPUT ${CSS_FILE}
#  COMMAND ${CSSTIDY} ${COMBINED_CSS} --silent=true --template=highest ${CSS_FILE}
#  DEPENDS ${COMBINED_CSS}
#  )

compress(${CSS_FILE} ${COMBINED_CSS})
compress(${JS_COMPRESSED} ${JS_UNCOMPRESSED})

add_custom_target(css ALL DEPENDS ${CSS_FILE})
add_custom_target(js  ALL DEPENDS ${JS_COMPRESSED})

install(FILES
  ${CSS_FILE}
  ${JS_COMPRESSED}
  favicon.ico
  DESTINATION .
  )

install(DIRECTORY images DESTINATION .)

file(GLOB FANCYBOX_IMAGES ${FANCYBOX_DIR}/*.gif ${FANCYBOX_DIR}/*.png)
install(FILES ${FANCYBOX_IMAGES} DESTINATION images)
