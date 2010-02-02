
macro(add_blog OUTPUT)

  get_filename_component(BLOG_NAME ${OUTPUT} NAME_WE)

  set(BLOG_QBK ${CMAKE_CURRENT_BINARY_DIR}/${BLOG_NAME}.qbk)
  file(WRITE ${BLOG_QBK}
    "[part Blog\n"
    "  [quickbook 1.5]\n"
    "  [version 1.0]\n"
    "  [id blog]\n"
    "  [dirname blog]\n"
    "]\n\n"
    )

  set(BOOSTBOOK_FILES ${OUTPUT})
  quickbook_to_boostbook(${OUTPUT} ${BLOG_QBK})

  foreach(POST ${ARGN})

    get_filename_component(POST_WE ${POST} NAME_WE)
    set(POST_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${POST_WE}.xml)

    quickbook_to_boostbook(${POST_OUTPUT} ${POST})
    file(APPEND ${BLOG_QBK} "[xinclude ${POST_OUTPUT}]\n")

    set(BOOSTBOOK_FILES ${BOOSTBOOK_FILES} ${POST_OUTPUT})

  endforeach(POST ${ARGN})

  add_custom_target(${BLOG_NAME} ALL DEPENDS ${BOOSTBOOK_FILES})

endmacro(add_blog OUTPUT)
