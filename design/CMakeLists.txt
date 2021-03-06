################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

include(BoostExtract)

find_program(CAT cat)
find_program(SASS sass)
#find_program(CSSTIDY csstidy)
find_program(YUICOMPRESSOR yui-compressor)


function(file_download file url md5)
  if(NOT IS_ABSOLUTE "${file}")
    set(file "${CMAKE_CURRENT_BINARY_DIR}/${file}")
  endif()

  if(EXISTS "${file}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E md5sum "${file}"
      OUTPUT_VARIABLE output
      )
    if("${output}" MATCHES "^${md5} ")
      return()
    endif()
  endif()

  message(STATUS "Downloading '${url}'")
  file(DOWNLOAD "${url}" "${file}" SHOW_PROGRESS EXPECTED_MD5 "${md5}")
endfunction(file_download)


macro(COMBINE OUTPUT)
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${CAT} ${ARGN} > ${OUTPUT}
    DEPENDS ${ARGN}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endmacro(COMBINE OUTPUT)

option(USE_COMPRESSION "compress css and js" ON)

macro(COMPRESS OUTPUT INPUT)
  if(USE_COMPRESSION)
    add_custom_command(OUTPUT ${OUTPUT}
      COMMAND ${YUICOMPRESSOR} -o ${OUTPUT} ${INPUT}
      DEPENDS ${INPUT})
  else(USE_COMPRESSION)
    add_custom_command(OUTPUT ${OUTPUT}
      COMMAND ${CMAKE_COMMAND} -E copy ${INPUT} ${OUTPUT} 
      DEPENDS ${INPUT})
  endif(USE_COMPRESSION)
endmacro(COMPRESS OUTPUT INPUT)

file_download(jquery.js
  http://code.jquery.com/jquery-1.6.1.js
  137d4b8b58f69c747fed3415894e73f4
  )

#http://www.goat1000.com/tagcanvas.php
file_download(tagcanvas.js
  http://www.goat1000.com/jquery.tagcanvas.js
  e04a1ced02b00ece17b098bbe26fd048
  )

boost_extract(fancybox DOWNLOAD
  http://fancybox.googlecode.com/files/jquery.fancybox-1.3.4.zip
  f964f34f37237a33f62188cebbbb927a
  )

set(FANCYBOX_DIR "${CMAKE_CURRENT_BINARY_DIR}/fancybox/fancybox")

file(READ ${FANCYBOX_DIR}/jquery.fancybox-1.3.4.css FANCYBOX_CSS)
string(REGEX REPLACE "/\\* IE \\*/.*" "" FANCYBOX_CSS "${FANCYBOX_CSS}")
string(REPLACE "/*" "/*!" FANCYBOX_CSS "${FANCYBOX_CSS}") # conserve copyright
string(REPLACE "url('" "url('/images/" FANCYBOX_CSS "${FANCYBOX_CSS}")
set(FANCYBOX_CSS_FILE ${CMAKE_CURRENT_BINARY_DIR}/fancybox.css)
file(WRITE ${FANCYBOX_CSS_FILE}.in "${FANCYBOX_CSS}")
configure_file(${FANCYBOX_CSS_FILE}.in ${FANCYBOX_CSS_FILE} COPY_ONLY)


set(SASS_FILE ${CMAKE_CURRENT_BINARY_DIR}/stylesheet.sass)
combine(${SASS_FILE}
  css/fonts.sass
  css/pixelGreen.sass
  css/admonition.sass
  css/navigation.sass
  css/sidebar.sass
  css/disqus.sass
  css/code.sass
  css/search.sass
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
  "${CMAKE_CURRENT_BINARY_DIR}/jquery.js"
  "${CMAKE_CURRENT_BINARY_DIR}/tagcanvas.js"
  ${FANCYBOX_DIR}/jquery.fancybox-1.3.4.js
  ${FANCYBOX_DIR}/jquery.easing-1.3.pack.js
  js/twitter.js
  js/ready.js
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
  favicon.png
  DESTINATION .
  )

install(DIRECTORY fonts images DESTINATION .)

file(GLOB FANCYBOX_IMAGES ${FANCYBOX_DIR}/*.gif ${FANCYBOX_DIR}/*.png)
install(FILES ${FANCYBOX_IMAGES} DESTINATION images)
