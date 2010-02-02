##########################################################################
# Boost Documentation Generation                                         #
##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################
# Important developer macros in this file:                               #
#                                                                        #
##########################################################################

# Adds documentation for the current library or tool project
#
#   boost_add_documentation(source1 source2 source3 ...
#     [HEADERS header1 header2 ...]
#     [DOXYGEN_PARAMETERS param1=value1 param2=value2 ...])
#

# This macro describes the documentation for a library or tool, which
# will be built and installed as part of the normal build
# process. Documentation can be in a variety of formats, and the input
# format will determine how that documentation is transformed. The
# documentation's format is determined by its extension, and the
# following input formats are supported:
# 
#   QuickBook
#   BoostBook (.XML extension):
macro(boost_add_documentation SOURCE)
  parse_arguments(THIS_DOC
    "HEADERS;DOXYGEN_PARAMETERS"
    ""
    ${ARGN})

  # If SOURCE is not a full path, it's in the current source
  # directory.
  get_filename_component(THIS_DOC_SOURCE_PATH ${SOURCE} PATH)
  if(THIS_DOC_SOURCE_PATH STREQUAL "")
    set(THIS_DOC_SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}")
  else()
    set(THIS_DOC_SOURCE_PATH ${SOURCE})
  endif()

  # If we are parsing C++ headers (with Doxygen) for reference
  # documentation, do so now and produce the requested BoostBook XML
  # file.
  if (THIS_DOC_HEADERS)
    set(DOC_HEADER_FILES)
    set(DOC_BOOSTBOOK_FILE)
    foreach(HEADER ${THIS_DOC_HEADERS})
      get_filename_component(HEADER_EXT ${HEADER} EXT)
      string(TOUPPER ${HEADER_EXT} HEADER_EXT)
      if (HEADER_EXT STREQUAL ".XML")
        if (DOC_BOOSTBOOK_FILE)
          # Generate this BoostBook file from the headers
          doxygen_to_boostbook(
            ${CMAKE_CURRENT_BINARY_DIR}/${DOC_BOOSTBOOK_FILE}
            ${DOC_HEADER_FILES}
            PARAMETERS ${THIS_DOC_DOXYGEN_PARAMETERS})
          list(APPEND THIS_DOC_DEFAULT_ARGS 
            ${CMAKE_CURRENT_BINARY_DIR}/${DOC_BOOSTBOOK_FILE})
        endif()
        set(DOC_BOOSTBOOK_FILE ${HEADER})
        set(DOC_HEADER_FILES)
      else()
        if (NOT DOC_BOOSTBOOK_FILE)
          message(SEND_ERROR 
            "HEADERS argument to boost_add_documentation must start with a BoostBook XML file name for output")
        endif()
        list(APPEND DOC_HEADER_FILES ${HEADER})
      endif()
    endforeach()

    if (DOC_HEADER_FILES)
      # Generate this BoostBook file from the headers
      doxygen_to_boostbook(
        ${CMAKE_CURRENT_BINARY_DIR}/${DOC_BOOSTBOOK_FILE}
        ${DOC_HEADER_FILES}
        PARAMETERS ${THIS_DOC_DOXYGEN_PARAMETERS})
      list(APPEND THIS_DOC_DEFAULT_ARGS 
        ${CMAKE_CURRENT_BINARY_DIR}/${DOC_BOOSTBOOK_FILE})

    endif()
  endif (THIS_DOC_HEADERS)

  # Figure out the source file extension, which will tell us how to
  # build the documentation.
  get_filename_component(THIS_DOC_EXT ${SOURCE} EXT)
  string(TOUPPER ${THIS_DOC_EXT} THIS_DOC_EXT)
  if (THIS_DOC_EXT STREQUAL ".QBK")

      # Transform Quickbook into BoostBook XML
      get_filename_component(SOURCE_FILENAME ${SOURCE} NAME_WE)
      set(BOOSTBOOK_FILE ${SOURCE_FILENAME}.xml)
      add_custom_command(OUTPUT ${BOOSTBOOK_FILE}
        COMMAND quickbook "--output-file=${BOOSTBOOK_FILE}"
        ${THIS_DOC_SOURCE_PATH} 
        DEPENDS ${THIS_DOC_SOURCE_PATH} ${THIS_DOC_DEFAULT_ARGS}
        COMMENT "Generating BoostBook documentation for Boost.${PROJECT_NAME}...")

      # Transform BoostBook into other formats
      boost_add_documentation(${CMAKE_CURRENT_BINARY_DIR}/${BOOSTBOOK_FILE})

  elseif (THIS_DOC_EXT STREQUAL ".XML")
  
    # Transform BoostBook XML into DocBook XML
    get_filename_component(SOURCE_FILENAME ${SOURCE} NAME_WE)
    set(DOCBOOK_FILE ${SOURCE_FILENAME}.docbook)
    xsl_transform(${DOCBOOK_FILE} ${THIS_DOC_SOURCE_PATH} 
      ${THIS_DOC_DEFAULT_ARGS}
      STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
      CATALOG ${CMAKE_BINARY_DIR}/catalog.xml
      COMMENT "Generating DocBook documentation for Boost.${PROJECT_NAME}..."
      MAKE_TARGET ${PROJECT_NAME}-docbook)

    # Transform DocBook into other formats
    boost_add_documentation(${CMAKE_CURRENT_BINARY_DIR}/${DOCBOOK_FILE})
    
  elseif(THIS_DOC_EXT STREQUAL ".DOCBOOK")
  
    # build HTML documentation
      xsl_transform(
        ${CMAKE_CURRENT_BINARY_DIR}/html 
        ${THIS_DOC_SOURCE_PATH} 
        STYLESHEET ${BOOSTBOOK_XSL_DIR}/html.xsl
        CATALOG ${CMAKE_BINARY_DIR}/catalog.xml
        DIRECTORY HTML.manifest
        PARAMETERS admon.graphics.path=images
                   navig.graphics.path=images
                   boost.image.src=boost.png
        COMMENT "Generating HTML documentaiton for Boost.${PROJECT_NAME}..."
        MAKE_TARGET ${PROJECT_NAME}-html)

      add_custom_command(TARGET ${PROJECT_NAME}-html
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/doc/src/boostbook.css ${CMAKE_CURRENT_BINARY_DIR}/html
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/boost.png ${CMAKE_CURRENT_BINARY_DIR}/html
        )

  else()
    message(SEND_ERROR "Unknown documentation source kind ${SOURCE}.")
  endif()
endmacro(boost_add_documentation)
            

##########################################################################
# Documentation tools configuration                                      #
##########################################################################

# Preferred versions of DocBook stylesheets and utilities. We don't
# require these, but we know that they work.
set(WANT_DOCBOOK_DTD_VERSION 4.2)
set(WANT_DOCBOOK_XSL_VERSION 1.73.2)

# Find xsltproc to transform XML documents via XSLT
find_program(XSLTPROC xsltproc DOC "xsltproc transforms XML via XSLT")
set(XSLTPROC_FLAGS "--xinclude" CACHE STRING 
  "Flags to pass to xsltproc to transform XML documents")

# Find the DocBook DTD (version 4.2)
find_path(DOCBOOK_DTD_DIR docbookx.dtd
  PATHS "${CMAKE_BINARY_DIR}/docbook-dtd-${WANT_DOCBOOK_DTD_VERSION}"
  DOC "Path to the DocBook DTD")

# Find the DocBook XSL stylesheets
find_path(DOCBOOK_XSL_DIR html/html.xsl
  PATHS "${CMAKE_BINARY_DIR}/docbook-xsl-${WANT_DOCBOOK_XSL_VERSION}"
  DOC "Path to the DocBook XSL stylesheets")

# Find the BoostBook DTD (it should be in the distribution!)
find_path(BOOSTBOOK_DTD_DIR boostbook.dtd
  PATHS ${CMAKE_SOURCE_DIR}/tools/boostbook/dtd
  DOC "Path to the BoostBook DTD")
mark_as_advanced(BOOSTBOOK_DTD_DIR)

# Find the BoostBook XSL stylesheets (they should be in the distribution!)
find_path(BOOSTBOOK_XSL_DIR docbook.xsl
  PATHS ${CMAKE_SOURCE_DIR}/tools/boostbook/xsl
  DOC "Path to the BoostBook XSL stylesheets")
mark_as_advanced(BOOSTBOOK_XSL_DIR)

# Try to find Doxygen
find_package(Doxygen)

# Generate an XML catalog file.
configure_file(${CMAKE_SOURCE_DIR}/tools/build/CMake/catalog.xml.in
  ${CMAKE_BINARY_DIR}/catalog.xml @ONLY)
