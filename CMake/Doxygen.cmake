
include(XSLTransform)
find_package(Doxygen REQUIRED)

# Use Doxygen to parse header files and produce BoostBook output.
#
#   doxygen_to_boostbook(output header1 header2 ...
#     [PARAMETERS param1=value1 param2=value2 ... ])
#
# This macro sets up rules to transform a set of C/C++ header files
# into BoostBook reference documentation. The resulting BoostBook XML
# file will be named by the "output" parameter, and the set of headers
# is provided following the output file. The actual parsing of header
# files is provided by Doxygen, and is transformed into XML through
# various XSLT transformations.
#
# Doxygen has a variety of configuration parameters. One can supply
# extra Doxygen configuration parameters by providing NAME=VALUE pairs
# following the PARAMETERS argument. These parameters will be added to
# the Doxygen configuration file.

macro(doxygen_to_boostbook OUTPUT)

  parse_arguments(THIS_DOXY "PARAMETERS" "" ${ARGN})

  # Create a Doxygen configuration file template
  get_filename_component(DOXYFILE_PATH ${OUTPUT} PATH)
  get_filename_component(DOXYFILE_NAME ${OUTPUT} NAME_WE)
  set(DOXYFILE ${DOXYFILE_PATH}/${DOXYFILE_NAME}.doxyfile)

  execute_process(
    COMMAND ${DOXYGEN_EXECUTABLE} -s -g ${DOXYFILE}
    OUTPUT_QUIET ERROR_QUIET)

  foreach(PARAM ${THIS_DOXY_PARAMETERS})
    file(APPEND ${DOXYFILE} "${PARAM}\n")
  endforeach(PARAM)

  # Update the Doxygen configuration file for XML generation
  file(APPEND ${DOXYFILE} "OUTPUT_DIRECTORY = ${CMAKE_CURRENT_BINARY_DIR}\n")
  file(APPEND ${DOXYFILE} "GENERATE_LATEX = NO\n")
  file(APPEND ${DOXYFILE} "GENERATE_HTML = NO\n")
  file(APPEND ${DOXYFILE} "GENERATE_XML = YES\n")

# set(THIS_DOXY_HEADER_PATH ${CMAKE_SOURCE_DIR}/libs/${libname}/include)

  set(THIS_DOXY_HEADER_LIST "")
  set(THIS_DOXY_HEADERS)
  foreach(HDR ${THIS_DOXY_DEFAULT_ARGS})
    list(APPEND THIS_DOXY_HEADERS ${THIS_DOXY_HEADER_PATH}/${HDR})
    set(THIS_DOXY_HEADER_LIST 
      "${THIS_DOXY_HEADER_LIST} ${THIS_DOXY_HEADER_PATH}/${HDR}")
  endforeach(HDR)
  file(APPEND ${DOXYFILE} "INPUT = ${THIS_DOXY_HEADER_LIST}\n")

  # Generate Doxygen XML
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xml/index.xml
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE}
    COMMENT "Generating Doxygen XML output for ${OUTPUT}."
    DEPENDS ${THIS_DOXY_HEADERS})

  # Collect Doxygen XML into a single XML file
  set_source_files_properties(
    ${CMAKE_CURRENT_BINARY_DIR}/xml/combine.xslt
    PROPERTIES GENERATED TRUE)

  xsl_transform(
    ${CMAKE_CURRENT_BINARY_DIR}/xml/all.xml
    ${CMAKE_CURRENT_BINARY_DIR}/xml/index.xml
    STYLESHEET ${CMAKE_CURRENT_BINARY_DIR}/xml/combine.xslt
    COMMENT "Collecting Doxygen XML output for ${OUTPUT}.")

  # Transform single Doxygen XML file into BoostBook XML
  xsl_transform(${OUTPUT}
    ${CMAKE_CURRENT_BINARY_DIR}/xml/all.xml
    STYLESHEET ${BOOSTBOOK_XSL_DIR}/doxygen/doxygen2boostbook.xsl
    COMMENT "Transforming Doxygen XML into BoostBook XML for ${OUTPUT}.")

endmacro(doxygen_to_boostbook)
