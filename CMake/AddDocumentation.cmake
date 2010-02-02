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

  # Transform Quickbook into BoostBook XML
  get_filename_component(SOURCE_FILENAME ${SOURCE} NAME_WE)
  set(BOOSTBOOK_FILE ${SOURCE_FILENAME}.xml)
  add_custom_command(OUTPUT ${BOOSTBOOK_FILE}
    COMMAND quickbook "--output-file=${BOOSTBOOK_FILE}" ${THIS_DOC_SOURCE_PATH} 
    DEPENDS ${THIS_DOC_SOURCE_PATH} ${THIS_DOC_DEFAULT_ARGS}
    COMMENT "Generating BoostBook documentation for Boost.${PROJECT_NAME}...")

endmacro(boost_add_documentation)
