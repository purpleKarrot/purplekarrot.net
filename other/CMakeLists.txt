################################################################################
# Copyright (c) 2010-2011 Daniel Pfeifer                                       #
################################################################################

include(BoostXsltproc)

set(other_html 404.html about.html downloads.html projects.html search.html)
set(dependencies)

foreach(page ${other_html})
  set(input  ${CMAKE_CURRENT_SOURCE_DIR}/${page})
  set(output ${CMAKE_CURRENT_BINARY_DIR}/${page})
  get_filename_component(part ${page} NAME_WE)

  boost_xsltproc(${output} ${CMAKE_SOURCE_DIR}/xsl/other.xsl ${input}
    PARAMETERS purple.part=${part}
    )

  install(FILES ${output} DESTINATION .)
  list(APPEND dependencies ${output})
endforeach(page)

add_custom_target(other_html ALL DEPENDS ${dependencies})
