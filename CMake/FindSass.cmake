################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_program(SASS_EXECUTABLE sass)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sass DEFAULT_MSG SASS_EXECUTABLE)
