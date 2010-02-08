
include(AddExternal)
include(ParseArguments)

# add_project(libMaoni
#   REPOSITORY GIT git://github.com/purpleKarrot/libMaoni.git
#   DOCUMENTATION maoni-doc.xml
#   )

macro(add_project NAME)

  parse_arguments(THIS "REPOSITORY;DOCUMENTATION" "" ${ARGN})

  add_external(THIS_EXTERNAL ${NAME} ${THIS_REPOSITORY})

  if(THIS_DOCUMENTATION)
    add_subdirectory(${THIS_EXTERNAL}/doc)
  endif(THIS_DOCUMENTATION)

endmacro(add_project NAME)
