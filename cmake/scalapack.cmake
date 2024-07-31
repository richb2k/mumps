include(ExternalProject)
include(GNUInstallDirs)

if(find AND NOT TARGET SCALAPACK::SCALAPACK)

if(NOT DEFINED SCALAPACK_VENDOR)
  if(LAPACK_VENDOR MATCHES "^MKL")
    set(SCALAPACK_VENDOR MKL)
  elseif(NOT DEFINED LAPACK_VENDOR AND
    (DEFINED ENV{MKLROOT} AND IS_DIRECTORY "$ENV{MKLROOT}"))
    set(SCALAPACK_VENDOR MKL)
    set(LAPACK_VENDOR MKL)
  endif()
endif()

if(MKL IN_LIST SCALAPACK_VENDOR AND NOT MKL64 IN_LIST SCALAPACK_VENDOR)
  if(intsize64)
    list(APPEND SCALAPACK_VENDOR MKL64)
  endif()
endif()

if(find_static)
  list(APPEND SCALAPACK_VENDOR STATIC)
endif()

find_package(SCALAPACK COMPONENTS ${SCALAPACK_VENDOR})

endif()

if(SCALAPACK_FOUND OR TARGET SCALAPACK::SCALAPACK)
  return()
endif()

set(scalapack_cmake_args
-DBUILD_SINGLE:BOOL=${BUILD_SINGLE}
-DBUILD_DOUBLE:BOOL=${BUILD_DOUBLE}
-DBUILD_COMPLEX:BOOL=${BUILD_COMPLEX}
-DBUILD_COMPLEX16:BOOL=${BUILD_COMPLEX16}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
-DBUILD_TESTING:BOOL=off
-DCMAKE_BUILD_TYPE:STRING=Release
)

file(READ ${CMAKE_CURRENT_LIST_DIR}/libraries.json json)

string(JSON scalapack_url GET ${json} scalapack git)
string(JSON scalapack_tag GET ${json} scalapack tag)

set(SCALAPACK_INCLUDE_DIRS ${CMAKE_INSTALL_FULL_INCLUDEDIR})
file(MAKE_DIRECTORY ${SCALAPACK_INCLUDE_DIRS})
if(NOT IS_DIRECTORY ${SCALAPACK_INCLUDE_DIRS})
  message(FATAL_ERROR "Could not create directory: ${SCALAPACK_INCLUDE_DIRS}")
endif()

if(BUILD_SHARED_LIBS)
  set(SCALAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}scalapack${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}blacs${CMAKE_SHARED_LIBRARY_SUFFIX}
  )
else()
  set(SCALAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}scalapack${CMAKE_STATIC_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}blacs${CMAKE_STATIC_LIBRARY_SUFFIX}
  )
endif()

ExternalProject_Add(scalapack
GIT_REPOSITORY ${scalapack_url}
GIT_TAG ${scalapack_tag}
GIT_SHALLOW true
CMAKE_ARGS ${scalapack_cmake_args}
TEST_COMMAND ""
BUILD_BYPRODUCTS ${SCALAPACK_LIBRARIES}
CONFIGURE_HANDLED_BY_BUILD true
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_PATCH true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)

add_library(SCALAPACK::SCALAPACK INTERFACE IMPORTED GLOBAL)
target_include_directories(SCALAPACK::SCALAPACK INTERFACE ${SCALAPACK_INCLUDE_DIRS})
target_link_libraries(SCALAPACK::SCALAPACK INTERFACE ${SCALAPACK_LIBRARIES})

add_dependencies(SCALAPACK::SCALAPACK scalapack)
