
include(AddExternal)
include(ParseArguments)
find_package(Java)

add_external(XSLTDOC_DIR XSLTdoc SVN
  https://xsltdoc.svn.sourceforge.net/svnroot/xsltdoc/1.2.2/)

# TARGET_DIR
# The absolute or relative path to the target directory 
# where the HTML files are created. If a relative path
# is used it is always relative to the config file. 

# SOURCE_DIR
# The absolute or relative path to the source directory.
# This is where the XSLT source files can be found.
# If a relative path is used it is always relative 
# to the config file.

# default args
# A list of source code files which shall be documented. 
# Only stylesheets which are not included by another
# have to be listed here. The included stylesheets
# are found automatically by following the include or
# the import statements in the including stylesheet.
# Relative references are relative to the SourceDirectory
# defined above.

macro(add_xsltdoc NAME)

  parse_arguments(THIS_XSLTDOC
    "TITLE;INTRODUCTION;TARGET_DIR;SOURCE_DIR" "" ${ARGN})

  if(IS_ABSOLUTE ${THIS_XSLTDOC_SOURCE_DIR})
    file(RELATIVE_PATH THIS_XSLTDOC_SOURCE_DIR
      ${CMAKE_CURRENT_BINARY_DIR} ${THIS_XSLTDOC_SOURCE_DIR})
  endif(IS_ABSOLUTE ${THIS_XSLTDOC_SOURCE_DIR})

  set(ROOT_STYLESHEETS)
  foreach(FILE ${THIS_XSLTDOC_DEFAULT_ARGS})
    set(ROOT_STYLESHEETS "${ROOT_STYLESHEETS}    <File href=\"${FILE}\"/>\n")
  endforeach(FILE ${THIS_XSLTDOC_DEFAULT_ARGS})

  set(CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/${NAME}.xml)
  file(WRITE ${CONFIG_FILE}
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<XSLTdocConfig>\n"
    "  <Title>${THIS_XSLTDOC_TITLE}</Title>\n"
    "  <Introduction>${THIS_XSLTDOC_INTRODUCTION}</Introduction>\n"
    "  <TargetDirectory path=\"${THIS_XSLTDOC_TARGET_DIR}\"/>\n"
    "  <SourceDirectory path=\"${THIS_XSLTDOC_SOURCE_DIR}\"/>\n"
    "  <RootStylesheets>\n${ROOT_STYLESHEETS}  </RootStylesheets>\n"
    "</XSLTdocConfig>\n")

  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${NAME}
    COMMAND ${JAVA_RUNTIME} -jar ${XSLTDOC_DIR}/lib/saxon8.jar
            ${CONFIG_FILE} ${XSLTDOC_DIR}/xsl/xsltdoc.xsl)

  add_custom_target(${NAME}-html ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${NAME})

endmacro(add_xsltdoc NAME)
