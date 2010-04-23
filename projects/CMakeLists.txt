################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

set(MY_GITHUB_NAME purpleKarrot)
set(REPOSITORIES_URL http://github.com/api/v2/xml/repos/show/${MY_GITHUB_NAME})
set(REPOSITORIES_XML ${CMAKE_CURRENT_BINARY_DIR}/repositories.xml)
set(REPOSITORIES_XSL ${CMAKE_SOURCE_DIR}/xsl/repositories/main.xsl)
set(REPOSITORIES_CMK ${CMAKE_CURRENT_BINARY_DIR}/repositories.cmake)

file(DOWNLOAD ${REPOSITORIES_URL} ${REPOSITORIES_XML})

execute_process(COMMAND ${XSLTPROC_EXECUTABLE}
  -o ${REPOSITORIES_CMK} ${REPOSITORIES_XSL} ${REPOSITORIES_XML})

#set(DEPENDENCIES)
include(${REPOSITORIES_CMK})

#set(QBK_FILE ${CMAKE_CURRENT_BINARY_DIR}/projects.qbk)
#file(WRITE ${QBK_FILE}
#  "[part Projects\n"
#  "  [quickbook 1.5]\n"
#  "  [id projects]\n"
#  "  [dirname projects]\n"
#  "]\n\n")

#foreach(DEP ${DEPENDENCIES})
#  message(STATUS ${DEP})
#  file(RELATIVE_PATH DEP_REL ${CMAKE_CURRENT_BINARY_DIR} ${DEP})
#  file(APPEND ${QBK_FILE} "[xinclude ${DEP_REL}]\n")
#endforeach(DEP ${DEPENDENCIES})

# quickbook_to_docbook(projects.docbook ${QBK_FILE})

# xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/html projects.docbook
#  STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
#  CATALOG ${BOOSTBOOK_CATALOG}
#  DIRECTORY index.html
#  COMMENT "Generating Website HTML."
#  MAKE_ALL_TARGET projects-html
#  )
