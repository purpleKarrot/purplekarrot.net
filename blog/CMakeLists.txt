################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

include(XSLTransform)
find_package(Git REQUIRED)
find_package(BoostBook REQUIRED)

set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/blog.qbk)
set(QBK_FILE_IN ${QBK_FILE}.in)

file(WRITE ${QBK_FILE_IN}
  "[part Blog\n"
  "  [quickbook 1.5]\n"
  "  [copyright 2010 Daniel Pfeifer]\n"
  "]\n\n"
  )

file(GLOB_RECURSE BLOG_POSTS *.qbk)
set(DEPENDENCIES)

foreach(POST ${BLOG_POSTS})
  execute_process(COMMAND ${GIT_EXECUTABLE} log --pretty=format:%ai -1 ${POST}
    OUTPUT_VARIABLE LAST_REVISION)

  get_filename_component(POST_NAME ${POST} NAME_WE)
  set(POST_QBK ${CMAKE_CURRENT_BINARY_DIR}/${POST_NAME}.qbk)
  set(POST_XML ${CMAKE_CURRENT_BINARY_DIR}/${POST_NAME}.xml)

  configure_file(${POST} ${POST_QBK})
  quickbook_to_boostbook(${POST_XML} ${POST_QBK})

  set(DEPENDENCIES ${DEPENDENCIES} ${POST_XML})
  file(APPEND ${QBK_FILE_IN} "[xinclude ${POST_XML}]\n")
endforeach(POST ${BLOG_POSTS})

configure_file(${QBK_FILE_IN} ${QBK_FILE} COPYONLY)
quickbook_to_docbook(blog.docbook ${QBK_FILE} ${DEPENDENCIES})

xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/www blog.docbook
  STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/blog.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  DIRECTORY index.html
  COMMENT "Generating Website HTML."
  MAKE_ALL_TARGET blog
  )

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/www
  DESTINATION .
  )
