include(CTest)
enable_testing()

# source files
aux_source_directory(${CMAKE_CURRENT_LIST_DIR} CPROJECT_TEST_SOURCE_FILES)

# output
set(CPROJECT_TEST_OUTPUT_DIRECTORY  ${CMAKE_BINARY_DIR}/tests)

# add test
foreach(_test_file ${CPROJECT_TEST_SOURCE_FILES})
  # retrieve file name
  STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _test_file_name ${_test_file})

  # shared library test
  if (CPROJECT_BUILD_SHARED_LIBS)
    # shared name
    set(_test_file_shared ${_test_file_name}_shared)
    # target exec
    add_executable(${_test_file_shared} ${_test_file})
    # target exec add depends
    add_dependencies(${_test_file_shared} ${CPROJECT_SHARED_LIBRARY})
    # target exec include library
    target_include_directories(${_test_file_shared} PUBLIC ${CPROJECT_INCLUDE_DIRECTORY})
    # target exec link library
    target_link_libraries(${_test_file_shared} ${CPROJECT_SHARED_LIBRARY})
    # target exec cmake config
    set_target_properties(${_test_file_shared} PROPERTIES
      # target output directory
      ARCHIVE_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      # clean and rebuild
      CLEAN_DIRECT_OUTPUT               True
    )
    # Windows need copy shared library to exe directory
    if (WIN32)
      add_custom_command(TARGET ${_test_file_shared} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          ${CPROJECT_SHARED_OUTPUT_DIRECTORY}/${CPROJECT_NAME}.dll
          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      )
    endif()
    # add test
    add_test(${_test_file_shared} ${CPROJECT_TEST_OUTPUT_DIRECTORY}/${_test_file_shared})
  endif()

  # static library test
  if (CPROJECT_BUILD_STATIC_LIBS)
    # static name
    set(_test_file_static ${_test_file_name}_static)
    # target exec
    add_executable(${_test_file_static} ${_test_file})
    # target exec add depends
    add_dependencies(${_test_file_static} ${CPROJECT_STATIC_LIBRARY})
    # target exec include library
    target_include_directories(${_test_file_static} PUBLIC ${CPROJECT_INCLUDE_DIRECTORY})
    # target exec link library
    target_link_libraries(${_test_file_static} ${CPROJECT_STATIC_LIBRARY})
    # target exec cmake config
    set_target_properties(${_test_file_static} PROPERTIES
      # target output directory
      ARCHIVE_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY          ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_TEST_OUTPUT_DIRECTORY}
      # clean and rebuild
      CLEAN_DIRECT_OUTPUT               True
    )
    # add test
    add_test(${_test_file_static} ${CPROJECT_TEST_OUTPUT_DIRECTORY}/${_test_file_static})
  endif()
endforeach()


