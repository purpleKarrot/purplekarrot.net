
find_program(QUICKBOOK_EXECUTABLE quickbook)
if(NOT QUICKBOOK_EXECUTABLE)

  include(AddExternal)
  add_external(QUICKBOOK_SRC_DIR quickbook SVN
    http://svn.boost.org/svn/boost/tags/release/Boost_1_41_0/tools/quickbook/)

  find_package(Boost 1.40.0 REQUIRED
    COMPONENTS filesystem system program_options)
  include_directories(${Boost_INCLUDE_DIRS})

  add_executable(quickbook
    ${QUICKBOOK_SRC_DIR}/detail/actions.cpp
    ${QUICKBOOK_SRC_DIR}/detail/actions_class.cpp
    ${QUICKBOOK_SRC_DIR}/detail/collector.cpp
    ${QUICKBOOK_SRC_DIR}/detail/input_path.cpp
    ${QUICKBOOK_SRC_DIR}/detail/markups.cpp
    ${QUICKBOOK_SRC_DIR}/detail/post_process.cpp
    ${QUICKBOOK_SRC_DIR}/detail/quickbook.cpp
    ${QUICKBOOK_SRC_DIR}/detail/template_stack.cpp
    ${QUICKBOOK_SRC_DIR}/detail/utils.cpp
    )
  target_link_libraries(quickbook ${Boost_LIBRARIES})

endif(NOT QUICKBOOK_EXECUTABLE)

mark_as_advanced(QUICKBOOK_EXECUTABLE)

# Transform Quickbook into BoostBook XML
macro(quickbook_to_boostbook OUTPUT INPUT)

  # If INPUT is not a full path, it's in the current source directory.
  get_filename_component(INPUT_PATH ${INPUT} PATH)
  if(INPUT_PATH STREQUAL "")
    set(INPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${INPUT}")
  else(INPUT_PATH STREQUAL "")
    set(INPUT_PATH ${INPUT})
  endif(INPUT_PATH STREQUAL "")

  add_custom_command(OUTPUT ${OUTPUT}
    COMMAND ${QUICKBOOK_EXECUTABLE} "--output-file=${OUTPUT}" ${INPUT_PATH}
    COMMENT "Generating BoostBook XML from ${INPUT}."
    DEPENDS ${INPUT} ${ARGN})

endmacro(quickbook_to_boostbook OUTPUT INPUT)
