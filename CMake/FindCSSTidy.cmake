################################################################################
# Copyright (c) 2010 Daniel Pfeifer                                            #
################################################################################

find_program(CSSTIDY_EXECUTABLE csstidy)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CSSTidy DEFAULT_MSG CSSTIDY_EXECUTABLE)

set(CSSTIDY_PARAMETERS --silent=true --template=highest)
