
# Transform BoostBook XML into DocBook
macro(latex_to_docbook INPUT)

  add_custom_command(OUTPUT ${QBK_FILE}
    COMMAND ${CMAKE_COMMAND} -E copy ${INPUT_PATH} ${QBK_FILE}
    DEPENDS ${INPUT_PATH})


  string(REGEX REPLACE ".tex$" ".xml" OUTPUT ${INPUT})
  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND htlatex ${INPUT} xhtml,docbook -cunihtf -cdocbk
    DEPENDS ${INPUT}
    )

endmacro(boostbook_to_docbook OUTPUT INPUT)

htlatex seminar.tex xhtml,docbook -cunihtf -cdocbk