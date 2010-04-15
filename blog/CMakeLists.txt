################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

file(GLOB_RECURSE BLOG_POSTS *.qbk)
add_quickbook(blog.xml "part Blog"
  ID blog
  DIRNAME blog
  COPYRIGHT "2010 Daniel Pfeifer"
  AUTHORS "[Pfeifer, Daniel]"
  XINCLUDE ${BLOG_POSTS}
  )

xsl_transform(blog.docbook blog.xml
  STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  COMMENT "Generating DocBook from blog.xml."
  DEPENDS blog.xml
  )

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
