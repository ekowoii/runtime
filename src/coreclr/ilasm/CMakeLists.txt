project(ilasm)

add_definitions(-DUNICODE)
add_definitions(-D_UNICODE)
add_definitions(-D_FEATURE_NO_HOST)
add_definitions(-D__ILASM__)
add_definitions(-DFEATURE_METADATA_EMIT_PORTABLE_PDB)

add_definitions(-DFEATURE_CORECLR)

include_directories(.)

set(ILASM_SOURCES
  assem.cpp
  writer.cpp
  method.cpp
  asmman.cpp
  main.cpp
  assembler.cpp
  prebuilt/asmparse.cpp
  portable_pdb.cpp
)

set(ILASM_HEADERS
  asmenum.h
  asmman.hpp
  asmparse.h
  asmtemplates.h
  assembler.h
  binstr.h
  class.hpp
  ilasmpch.h
  method.hpp
  nvpair.h
  typar.hpp
  portable_pdb.h
  sha256.h
)

if(CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_APPLE)
  configure_file(
    ../../native/libs/System.Security.Cryptography.Native/pal_crypto_config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/pal_crypto_config.h)
  include_directories(../../native/libs/Common)
  include_directories(../../native/libs/System.Security.Cryptography.Native)
  include_directories(${CMAKE_CURRENT_BINARY_DIR})
endif(CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_APPLE)

if(CLR_CMAKE_TARGET_WIN32)
  list(APPEND ILASM_SOURCES ${ILASM_HEADERS})

  set(ILASM_RESOURCES Native.rc)
  add_definitions(-DFX_VER_INTERNALNAME_STR=ilasm.exe)
endif(CLR_CMAKE_TARGET_WIN32)


if(CLR_CMAKE_HOST_UNIX)
  # Need generate a right form of asmparse.cpp to avoid the following options.
  # Clang also produces a bad-codegen on this prebuilt file with optimization.
  # https://github.com/dotnet/runtime/issues/4776
  add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:-Wno-register>")
  add_compile_options(-Wno-array-bounds)
  add_compile_options(-Wno-unused-label)
  set_source_files_properties( prebuilt/asmparse.cpp PROPERTIES COMPILE_FLAGS "-O0" )
endif(CLR_CMAKE_HOST_UNIX)

if(CLR_CMAKE_HOST_LINUX OR CLR_CMAKE_HOST_FREEBSD OR CLR_CMAKE_HOST_NETBSD OR CLR_CMAKE_HOST_SUNOS OR CLR_CMAKE_HOST_HAIKU)
    # This option is necessary to ensure that the overloaded delete operator defined inside
    # of the utilcode will be used instead of the standard library delete operator.
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Xlinker -Bsymbolic")

    # The following linked options can be inserted into the linker libraries list to
    # ensure proper resolving of circular references between a subset of the libraries.
    set(START_LIBRARY_GROUP -Wl,--start-group)
    set(END_LIBRARY_GROUP -Wl,--end-group)
endif(CLR_CMAKE_HOST_LINUX OR CLR_CMAKE_HOST_FREEBSD OR CLR_CMAKE_HOST_NETBSD OR CLR_CMAKE_HOST_SUNOS OR CLR_CMAKE_HOST_HAIKU)

add_executable_clr(ilasm
  ${ILASM_SOURCES}
  ${ILASM_RESOURCES}
)

set(ILASM_LINK_LIBRARIES
  utilcodestaticnohost
  mscorpe
  ${START_LIBRARY_GROUP} # Start group of libraries that have circular references
  mdcompiler_ppdb
  mdruntime_ppdb
  mdruntimerw_ppdb
  ${END_LIBRARY_GROUP} # End group of libraries that have circular references
  ceefgen
  corguids
)

if(CLR_CMAKE_TARGET_WIN32)
    list(APPEND ILASM_LINK_LIBRARIES
        ${STATIC_MT_CRT_LIB}
        ${STATIC_MT_VCRT_LIB}
        kernel32.lib
        advapi32.lib
        ole32.lib
        oleaut32.lib
        uuid.lib
        user32.lib
        version.lib
        shlwapi.lib
        bcrypt.lib
        RuntimeObject.lib
        coreclrminipal
    )
else()
    list(APPEND ILASM_LINK_LIBRARIES
        coreclrpal
        mscorrc
        coreclrminipal
    )
endif(CLR_CMAKE_TARGET_WIN32)

if(CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_APPLE)
  list(APPEND ILASM_LINK_LIBRARIES System.Security.Cryptography.Native.OpenSsl-Static)
  if(NOT FEATURE_DISTRO_AGNOSTIC_SSL)
    find_package(OpenSSL QUIET)
    if(OPENSSL_FOUND)
      list(APPEND ILASM_LINK_LIBRARIES OpenSSL::SSL OpenSSL::Crypto)
    endif(OPENSSL_FOUND)
  endif(NOT FEATURE_DISTRO_AGNOSTIC_SSL)
endif(CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_APPLE)


if(CLR_CMAKE_HOST_UNIX)
  target_link_libraries(ilasm
    PRIVATE
    ${ILASM_LINK_LIBRARIES}
    utilcodestaticnohost
    mscorrc
    coreclrpal
    ${CMAKE_DL_LIBS}
  )
else()
  target_link_libraries(ilasm
    PRIVATE
    ${ILASM_LINK_LIBRARIES}
    ole32
    oleaut32
    shell32
  )
endif(CLR_CMAKE_HOST_UNIX)

install_clr(TARGETS ilasm DESTINATIONS . COMPONENT iltools)
