
macro(add_quickbook OUTPUT)

  parse_arguments(THIS
    "VERSION;ID;DIRNAME;COPYRIGHT;PURPOSE;CATEGORY;AUTHORS;LICENSE;SOURCE_MODE;XINCLUDE"
    ""
    ${ARGN}
    )

  get_filename_component(QBK_NAME ${OUTPUT} NAME_WE)

  set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/${QBK_NAME}.qbk)
  file(WRITE ${QBK_FILE} "[${THIS_DEFAULT_ARGS}\n  [quickbook 1.5]\n")

  if(THIS_VERSION)
    file(APPEND ${QBK_FILE} "  [version ${THIS_VERSION}]\n")
  endif(THIS_VERSION)

  if(THIS_ID)
    file(APPEND ${QBK_FILE} "  [id ${THIS_ID}]\n")
  endif(THIS_ID)

  if(THIS_DIRNAME)
    file(APPEND ${QBK_FILE} "  [dirname ${THIS_DIRNAME}]\n")
  endif(THIS_DIRNAME)

  if(THIS_COPYRIGHT)
    file(APPEND ${QBK_FILE} "  [copyright ${THIS_COPYRIGHT}]\n")
  endif(THIS_COPYRIGHT)

  if(THIS_PURPOSE)
    file(APPEND ${QBK_FILE} "  [purpose ${THIS_PURPOSE}]\n")
  endif(THIS_PURPOSE)

  if(THIS_CATEGORY)
    file(APPEND ${QBK_FILE} "  [category ${THIS_CATEGORY}]\n")
  endif(THIS_CATEGORY)

  if(THIS_AUTHORS)
    file(APPEND ${QBK_FILE} "  [authors ${THIS_AUTHORS}]\n")
  endif(THIS_AUTHORS)

  if(THIS_LICENSE)
    file(APPEND ${QBK_FILE} "  [license ${THIS_LICENSE}]\n")
  endif(THIS_LICENSE)

  if(THIS_SOURCE_MODE)
    file(APPEND ${QBK_FILE} "  [source-mode ${THIS_SOURCE_MODE}]\n")
  endif(THIS_SOURCE_MODE)

  file(APPEND ${QBK_FILE} "]\n\n")

  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${QBK_NAME})

  set(DEPENDENCIES)
  foreach(POST ${THIS_XINCLUDE})
  
    get_filename_component(POST_EX ${POST} EXT)
    string(TOUPPER ${POST_EX} POST_EX)

    if(POST_EX STREQUAL ".QBK")
      get_filename_component(POST_NAME ${POST} NAME_WE)
      set(POST_PATH ${CMAKE_CURRENT_BINARY_DIR}/${QBK_NAME}/${POST_NAME}.xml)
      quickbook_to_boostbook(${POST_PATH} ${POST})
    elseif(POST_EX STREQUAL ".XML")
      get_filename_component(POST_PATH ${POST} ABSOLUTE)
    else()
      message(SEND_ERROR "${POST} has unsupported file extension ${POST_EX}.")
      set(POST_PATH)
    endif()

    if(POST_PATH)
      file(APPEND ${QBK_FILE} "[xinclude ${POST_PATH}]\n")
      set(DEPENDENCIES ${DEPENDENCIES} ${POST_PATH})
    endif(POST_PATH)

  endforeach(POST ${THIS_XINCLUDE})

  quickbook_to_boostbook(${OUTPUT} ${QBK_FILE} ${DEPENDENCIES})

endmacro(add_quickbook OUTPUT)
