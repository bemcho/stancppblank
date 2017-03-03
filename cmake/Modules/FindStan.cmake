# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Google Inc. nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Author: bemcho@gmail.com (Emil Tomov)
#

# FindSTAN.cmake - Find STAN libraries & dependencies.
#
# This module defines the following variables which should be referenced
# by the caller to use the library.
#
# STAN_FOUND: TRUE if STAN and all dependencies have been found.
# STAN_INCLUDE_DIRS: Include directories for STAN.
#
# STAN_VERSION: Extracted from version.hpp.
# STAN_MAIN_VERSION: Equal to 2 if STAN_VERSION = 2.14.0
# STAN_SUB_VERSION: Equal to 14 if STAN_VERSION = 2.14.
# STAN_SUBSUB_VERSION: Equal to 0 if STAN_VERSION = 2.14.0
#
# The following variables control the behaviour of this module:
#
# STAN_INCLUDE_DIR_HINTS: List of additional directories in which to
#                             search for STAN includes.
#
#
# The following variables are also defined by this module, but in line with
# CMake recommended FindPackage() module style should NOT be referenced directly
# by callers (use the plural variables detailed above instead).  These variables
# do however affect the behaviour of the module via FIND_[PATH/LIBRARY]() which
# are NOT re-called (i.e. search for library is not repeated) if these variables
# are set with valid values _in the CMake cache_. This means that if these
# variables are set directly in the cache, either by the user in the CMake GUI,
# or by the user passing -DVAR=VALUE directives to CMake when called (which
# explicitly defines a cache variable), then they will be used verbatim,
# bypassing the HINTS variables and other hard-coded search locations.
#
# STAN_INCLUDE_DIR: Include directory for STAN, not including the
#                       include directory of any dependencies.

# Called if we failed to find STAN or any of it's required dependencies,
# unsets all public (designed to be used externally) variables and reports
# error message at priority depending upon [REQUIRED/QUIET/<NONE>] argument.
MACRO(STAN_REPORT_NOT_FOUND REASON_MSG)
  UNSET(STAN_FOUND)
  UNSET(STAN_INCLUDE_DIRS)
  # Make results of search visible in the CMake GUI if STAN has not
  # been found so that user does not have to toggle to advanced view.
  MARK_AS_ADVANCED(CLEAR STAN_INCLUDE_DIR
                         )
  # Note <package>_FIND_[REQUIRED/QUIETLY] variables defined by FindPackage()
  # use the camelcase library name, not uppercase.
  IF (STAN_FIND_QUIETLY)
    MESSAGE(STATUS "Failed to find STAN - " ${REASON_MSG} ${ARGN})
  ELSEIF (STAN_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Failed to find STAN - " ${REASON_MSG} ${ARGN})
  ELSE()
    # Neither QUIETLY nor REQUIRED, use no priority which emits a message
    # but continues configuration and allows generation.
    MESSAGE("-- Failed to find STAN - " ${REASON_MSG} ${ARGN})
  ENDIF ()
ENDMACRO(STAN_REPORT_NOT_FOUND)

# Search user-installed locations first, so that we prefer user installs
# to system installs where both exist.
#
# TODO: Add standard Windows search locations for STAN.
LIST(APPEND STAN_CHECK_INCLUDE_DIRS
  /usr/local/include
  /usr/local/homebrew/include # Mac OS X
  /opt/local/var/macports/software # Mac OS X.
  /opt/local/include
  /usr/include)


  # Search supplied hint directories first if supplied.
FIND_PATH(STAN_INCLUDE_DIR  NAMES  stan    PATHS ${STAN_INCLUDE_DIR_HINTS}    ${STAN_CHECK_INCLUDE_DIRS})
IF (NOT STAN_INCLUDE_DIR OR
    NOT EXISTS ${STAN_INCLUDE_DIR})
  STAN_REPORT_NOT_FOUND(
    "Could not find STAN include directory, set STAN_INCLUDE_DIR "
    "to directory containing version.hpp")
ENDIF (NOT STAN_INCLUDE_DIR OR
       NOT EXISTS ${STAN_INCLUDE_DIR})


# Mark internally as found, then verify. STAN_REPORT_NOT_FOUND() unsets
# if called.
SET(STAN_FOUND TRUE)
SET(STAN_INCLUDE_DIR ${STAN_INCLUDE_DIR}/stan)
# Extract STAN version from version.hpp
IF (STAN_INCLUDE_DIR)
  SET(STAN_VERSION_FILE ${STAN_INCLUDE_DIR}/version.hpp)
  IF (NOT EXISTS ${STAN_VERSION_FILE})
    STAN_REPORT_NOT_FOUND(
      "Could not find file: ${STAN_VERSION_FILE} "
      "containing version information in STAN install located at: "
      "${STAN_INCLUDE_DIR}.")
  ELSE (NOT EXISTS ${STAN_VERSION_FILE})
    FILE(READ ${STAN_INCLUDE_DIR}/version.hpp STAN_VERSION_FILE_CONTENTS)

    STRING(REGEX MATCH "#define STAN_MAJOR [0-9]+"
      STAN_MAIN_VERSION "${STAN_VERSION_FILE_CONTENTS}")
    STRING(REGEX REPLACE "#define STAN_MAJOR ([0-9]+)" "\\1"
      STAN_MAIN_VERSION "${STAN_MAIN_VERSION}")

    STRING(REGEX MATCH "#define STAN_MINOR [0-9]+"
      STAN_SUB_VERSION "${STAN_VERSION_FILE_CONTENTS}")
    STRING(REGEX REPLACE "#define STAN_MINOR ([0-9]+)" "\\1"
      STAN_SUB_VERSION "${STAN_SUB_VERSION}")

    STRING(REGEX MATCH "#define STAN_PATCH [0-9]+"
      STAN_SUBSUB_VERSION "${STAN_VERSION_FILE_CONTENTS}")
    STRING(REGEX REPLACE "#define STAN_PATCH ([0-9]+)" "\\1"
      STAN_SUBSUB_VERSION "${STAN_SUBSUB_VERSION}")

    # This is on a single line s/t CMake does not interpret it as a list of
    # elements and insert ';' separators which would result in 3.;1.;2 nonsense.
    SET(STAN_VERSION "${STAN_MAIN_VERSION}.${STAN_SUB_VERSION}.${STAN_SUBSUB_VERSION}")
  ENDIF (NOT EXISTS ${STAN_VERSION_FILE})
ENDIF (STAN_INCLUDE_DIR)



# Set standard CMake FindPackage variables if found.
IF (STAN_FOUND)
  SET(STAN_INCLUDE_DIRS ${STAN_INCLUDE_DIR})
ENDIF (STAN_FOUND)

# Handle REQUIRED / QUIET optional arguments and version.
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(STAN
  REQUIRED_VARS STAN_INCLUDE_DIRS
  VERSION_VAR STAN_VERSION)

# Only mark internal variables as advanced if we found STAN, otherwise
# leave them visible in the standard GUI for the user to set manually.
IF (STAN_FOUND)
  MARK_AS_ADVANCED(FORCE STAN_INCLUDE_DIR)
ENDIF (STAN_FOUND)
