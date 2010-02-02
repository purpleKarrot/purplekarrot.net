
include(AddExternal)

add_external(BOOSTBOOK_DIR boostbook SVN
  http://svn.boost.org/svn/boost/tags/release/Boost_1_41_0/tools/boostbook/)

set(BOOSTBOOK_XSL_DIR ${BOOSTBOOK_DIR}/xsl)

# Find the DocBook DTD (version 4.2)
find_path(DOCBOOK_DTD_DIR docbookx.dtd
  PATHS /usr/share/xml/docbook/schema/dtd/4.2
  DOC "Path to the DocBook DTD")
if(NOT DOCBOOK_DTD_DIR)
  message(SEND_ERROR "The DocBook DTD (version 4.2) could not be found!")
endif(NOT DOCBOOK_DTD_DIR)

# Find the DocBook XSL stylesheets
find_path(DOCBOOK_XSL_DIR html/html.xsl
  PATHS /usr/share/xml/docbook/stylesheet/docbook-xsl 
  DOC "Path to the DocBook XSL stylesheets")
if(NOT DOCBOOK_XSL_DIR)
  message(SEND_ERROR "The DocBook XSL stylesheets could not be found!")
endif(NOT DOCBOOK_XSL_DIR)

set(BOOSTBOOK_CATALOG ${CMAKE_BINARY_DIR}/boostbook_catalog.xml)
file(WRITE ${BOOSTBOOK_CATALOG}
  "<?xml version=\"1.0\"?>\n"
  "<!DOCTYPE catalog\n"
  "  PUBLIC \"-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN\"\n"
  "  \"http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd\">\n"
  "<catalog xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">\n"
  "  <rewriteURI"
    " uriStartString=\"http://www.boost.org/tools/boostbook/dtd/\""
    " rewritePrefix=\"file://${BOOSTBOOK_DIR}/dtd/\""
    "/>\n"
  "  <rewriteURI"
    " uriStartString=\"http://docbook.sourceforge.net/release/xsl/current/\""
    " rewritePrefix=\"file://${DOCBOOK_XSL_DIR}/\""
    "/>\n"
  "  <rewriteURI"
    " uriStartString=\"http://www.oasis-open.org/docbook/xml/4.2/\""
    " rewritePrefix=\"file://${DOCBOOK_DTD_DIR}/\""
    "/>\n"
  "</catalog>\n"
  )
