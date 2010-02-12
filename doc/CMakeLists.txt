##############################################################
# Copyright (c) 2010 Daniel Pfeifer                          #
##############################################################

find_program(SAXONB_EXECUTABLE saxonb-xslt DOC "The Saxon-B XSLT Processor")

file(GLOB XSL_FILES ${CMAKE_SOURCE_DIR}/xsl/*.xsl)

set(DEPGRAPH_XSL ${CMAKE_CURRENT_SOURCE_DIR}/depgraph.xsl)
set(DEPGRAPH_XML ${CMAKE_CURRENT_BINARY_DIR}/depgraph.xml)
set(DEPGRAPH_DOT ${CMAKE_CURRENT_BINARY_DIR}/depgraph.dot)
set(DEPGRAPH_PNG ${CMAKE_CURRENT_BINARY_DIR}/depgraph.png)

set(DEPENDENCIES)
file(WRITE ${DEPGRAPH_XML} "<input>\n")

foreach(FILE ${XSL_FILES})
  list(APPEND DEPENDENCIES ${FILE})
  file(APPEND ${DEPGRAPH_XML} "  <uri>${FILE}</uri>\n")
endforeach(FILE ${XSL_FILES})

file(APPEND ${DEPGRAPH_XML} "</input>\n")

add_custom_command(OUTPUT ${DEPGRAPH_DOT}
  COMMAND ${SAXONB_EXECUTABLE} -xsl:${DEPGRAPH_XSL} -s:${DEPGRAPH_XML} > ${DEPGRAPH_DOT}
  DEPENDS ${DEPGRAPH_XSL} ${DEPGRAPH_XML} ${DEPENDENCIES})

add_custom_target(dependency ALL DEPENDS ${DEPGRAPH_DOT})
