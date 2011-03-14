################################################################################
# Copyright (c) 2010-2011 Daniel Pfeifer                                       #
################################################################################

find_package(Git REQUIRED)
find_package(DocBook REQUIRED)
find_package(XSLTPROC REQUIRED)
include(BoostXsltproc)

set(blog_qbk ${CMAKE_CURRENT_BINARY_DIR}/blog.qbk)
set(blog_xml ${CMAKE_CURRENT_BINARY_DIR}/blog.xml)
set(blog_dbk ${CMAKE_CURRENT_BINARY_DIR}/blog.docbook)

file(WRITE ${blog_qbk}.in
  "[part Blog\n"
  "  [quickbook 1.5]\n"
  "  [copyright 2010-2011 Daniel Pfeifer]\n"
  "]\n\n"
  )

file(GLOB_RECURSE blog_posts *.qbk)
set(dependencies)

foreach(post ${blog_posts})
  execute_process(COMMAND ${GIT_EXECUTABLE} log --pretty=format:%ai -1 ${post}
    OUTPUT_VARIABLE LAST_REVISION
    )
  get_filename_component(post_name ${post} NAME_WE)
  set(post_qbk ${CMAKE_CURRENT_BINARY_DIR}/${post_name}.qbk)
  set(post_xml ${CMAKE_CURRENT_BINARY_DIR}/${post_name}.xml)

  configure_file(${post} ${post_qbk})
  add_custom_command(OUTPUT ${post_xml}
    COMMAND $<TARGET_FILE:quickbook> "--output-file=${post_xml}" ${post_qbk}
    DEPENDS ${post_qbk}
    )
  list(APPEND dependencies ${post_xml})
  file(APPEND ${blog_qbk}.in "[xinclude ${post_xml}]\n")
endforeach(post)

configure_file(${blog_qbk}.in ${blog_qbk} COPYONLY)

add_custom_command(OUTPUT ${blog_xml}
  COMMAND $<TARGET_FILE:quickbook> "--output-file=${blog_xml}" ${blog_qbk}
  DEPENDS ${blog_qbk}
  )

boost_xsltproc(${blog_dbk} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${blog_xml}
  CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
  DEPENDS ${dependencies}
  )

set(blog_html ${CMAKE_CURRENT_BINARY_DIR}/www/index.html)
boost_xsltproc(${blog_html} ${CMAKE_SOURCE_DIR}/xsl/blog.xsl ${blog_dbk}
  CATALOGS ${BOOSTBOOK_CATALOG} ${DOCBOOK_CATALOG}
  PARAMETERS purple.part=blog
  )

add_custom_target(blog ALL DEPENDS ${blog_html})

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/www
  DESTINATION ..
  )
