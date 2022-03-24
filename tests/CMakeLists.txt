include(CTest)
enable_testing()

# source files
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/   CPROJECT_TEST_SOURCE_FILES)

# add suffix
set(TEST_USE_SUFFIX  OFF)
if (${CPROJECT_BUILD_CPROJECT_SHARED_LIBS} AND ${CPROJECT_BUILD_CPROJECT_STATIC_LIBS})
  set(TEST_USE_SUFFIX  ON)
endif()

# shared library test
if (CPROJECT_BUILD_CPROJECT_SHARED_LIBS)
  # add test
  foreach(_test_file ${CPROJECT_TEST_SOURCE_FILES})
    # retrieve file name
    STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _test_file_name ${_test_file})
    # rename
    if (TEST_USE_SUFFIX)
      set(_test_file_name ${_test_file_name}_shared)
    endif()
    # exec
    add_executable(${_test_file_name} ${_test_file})
    # add depends
    add_dependencies(${_test_file_name} ${CPROJECT_SHARED_LIBRARY})
    # include library
    target_include_directories(${_test_file_name} PUBLIC ${CPROJECT_INCLUDE_DIRECTORY})
    # link library
    target_link_libraries(${_test_file_name} ${CPROJECT_SHARED_LIBRARY})
    # copy shared library
    if (MSVC)
    add_custom_command(TARGET ${_test_file_name} POST_BUILD
      # copy library to target directory
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CPROJECT_SHARED_LIBRARY_FILE} ./
    )
    endif()
    # add test
    add_test(${_test_file_name} ${_test_file_name})
  endforeach()
endif()

# static library test
if (CPROJECT_BUILD_CPROJECT_STATIC_LIBS)
  # add test
  foreach(_test_file ${CPROJECT_TEST_SOURCE_FILES})
    # retrieve file name
    STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _test_file_name ${_test_file})
    # rename
    if (TEST_USE_SUFFIX)
      set(_test_file_name ${_test_file_name}_static)
    endif()
    # add exec
    add_executable(${_test_file_name} ${_test_file})
    # add depends
    add_dependencies(${_test_file_name} ${CPROJECT_STATIC_LIBRARY})
    # link library
    target_link_libraries(${_test_file_name} ${CPROJECT_STATIC_LIBRARY})
    # add test
    add_test(${_test_file_name} ${_test_file_name})
  endforeach()
endif()
