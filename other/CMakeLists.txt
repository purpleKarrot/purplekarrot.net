################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

set(OTHER_HTML 404.html about.html downloads.html search.html)
foreach(PAGE ${OTHER_HTML})
  xsl_transform(
    ${CMAKE_CURRENT_BINARY_DIR}/${PAGE}
    ${CMAKE_CURRENT_SOURCE_DIR}/${PAGE}
    STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/other/other.xsl
    MAKE_ALL_TARGET ${PAGE}
    )
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PAGE} DESTINATION www)
endforeach(PAGE ${OTHER_HTML})
