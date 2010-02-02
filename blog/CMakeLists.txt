
include(AddBlog)
include(XSLTransform)

file(GLOB BLOG *.qbk)
add_blog(purpleKarrot.xml ${BLOG})

xsl_transform(purpleKarrot.docbook purpleKarrot.xml
  STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  COMMENT "Generating DocBook from purpleKarrot.xml."
  DEPENDS purpleKarrot.xml)

add_custom_target(blog ALL DEPENDS purpleKarrot.docbook)
