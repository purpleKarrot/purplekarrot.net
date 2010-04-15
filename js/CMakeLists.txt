################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

set(JQUERY_FILE_NAME jquery-1.4.2.min.js)
set(JQUERY_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${JQUERY_FILE_NAME})
if(NOT EXISTS ${JQUERY_FILE_PATH})
  file(DOWNLOAD http://code.jquery.com/${JQUERY_FILE_NAME} ${JQUERY_FILE_PATH})
endif(NOT EXISTS ${JQUERY_FILE_PATH})
install(FILES ${JQUERY_FILE_PATH} DESTINATION www/js)


set(FANCYBOX_FILE_NAME jquery.fancybox-1.3.1.zip)
set(FANCYBOX_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${FANCYBOX_FILE_NAME})
if(NOT EXISTS ${FANCYBOX_FILE_PATH})
  file(DOWNLOAD http://fancybox.googlecode.com/files/${FANCYBOX_FILE_NAME}
    ${FANCYBOX_FILE_PATH})
endif(NOT EXISTS ${FANCYBOX_FILE_PATH})

include(Extract)
extract(${FANCYBOX_FILE_PATH} ${CMAKE_CURRENT_BINARY_DIR})

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/jquery.fancybox-1.3.1/fancybox
  DESTINATION www/js)
