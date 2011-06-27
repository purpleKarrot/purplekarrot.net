################################################################################
# Copyright (c) 2010-2011 Daniel Pfeifer                                       #
################################################################################

include(BoostXsltproc)
find_package(AsciiDoc REQUIRED)


function(ascii_to_docbook output input)
endfunction(ascii_to_docbook)

set(blog_qbk ${CMAKE_CURRENT_BINARY_DIR}/blog.qbk)
set(blog_xml ${CMAKE_CURRENT_BINARY_DIR}/blog.xml)
set(blog_dbk ${CMAKE_CURRENT_BINARY_DIR}/blog.docbook)

file(WRITE ${blog_qbk}.in
  "[part Blog\n"
  "  [quickbook 1.5]\n"
  "  [copyright 2010-2011 Daniel Pfeifer]\n"
  "]\n\n"
  )

set(dependencies)
set(blog_posts
  effective_find_package.txt
  BoostCMake.qbk
  dputCMake.qbk
  eQute.qbk
  first.qbk
  )

foreach(post ${blog_posts})
  get_filename_component(input "${post}" ABSOLUTE)
  get_filename_component(name  "${post}" NAME_WE)
  get_filename_component(ext   "${post}" EXT)

  set(output "${CMAKE_CURRENT_BINARY_DIR}/${name}.xml")

  if(ext STREQUAL ".txt")
    add_custom_command(OUTPUT "${output}"
      COMMAND
        ${ASCIIDOC_EXECUTABLE}
        "--backend=docbook"
        "--out-file=${output}"
        "${input}"
      DEPENDS
        "${input}"
      )
  elseif(ext STREQUAL ".qbk")
    add_custom_command(OUTPUT "${output}"
      COMMAND
        $<TARGET_FILE:quickbook>
        "--output-file=${output}"
        "${input}"
      DEPENDS
        "${input}"
      )
  endif()

  list(APPEND dependencies ${output})
  file(APPEND ${blog_qbk}.in "[xinclude ${output}]\n")
endforeach(post)

configure_file(${blog_qbk}.in ${blog_qbk} COPYONLY)

add_custom_command(OUTPUT ${blog_xml}
  COMMAND $<TARGET_FILE:quickbook> "--output-file=${blog_xml}" ${blog_qbk}
  DEPENDS ${blog_qbk}
  )

boost_xsltproc(${blog_dbk} ${BOOSTBOOK_XSL_DIR}/docbook.xsl ${blog_xml}
  DEPENDS ${dependencies}
  )

set(blog_html ${CMAKE_CURRENT_BINARY_DIR}/www/index.html)
boost_xsltproc(${blog_html} ${CMAKE_SOURCE_DIR}/xsl/blog.xsl ${blog_dbk}
  PARAMETERS purple.part=blog
  DEPENDS ${XSL_FILES}
  )

add_custom_target(blog ALL DEPENDS ${blog_html})

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/www
  DESTINATION ..
  )
