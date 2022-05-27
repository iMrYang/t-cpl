# source files
aux_source_directory(${CMAKE_CURRENT_LIST_DIR} CPROJECT_EXAMPLE_SOURCE_FILES)

# output
set(CPROJECT_EXAMPLE_OUTPUT_DIRECTORY  ${CMAKE_SOURCE_DIR}/build/bin/)

# add example
foreach(_example_file ${CPROJECT_EXAMPLE_SOURCE_FILES})
  # retrieve file name
  STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _example_file_name ${_example_file})

  # shared library example
  if (CPROJECT_BUILD_SHARED_LIBS)
    # shared name
    set(_example_file_shared ${_example_file_name}_shared)
    # target exec
    add_executable(${_example_file_shared} ${_example_file})
    # target exec add depends
    add_dependencies(${_example_file_shared} ${CPROJECT_SHARED_LIBRARY})
    # target exec include library
    target_include_directories(${_example_file_shared} PUBLIC ${CPROJECT_INCLUDE_DIRECTORY})
    # target exec link library
    target_link_libraries(${_example_file_shared} ${CPROJECT_SHARED_LIBRARY})
    # target exec cmake config
    set_target_properties(${_example_file_shared} PROPERTIES
      # target output directory
      ARCHIVE_OUTPUT_DIRECTORY          ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY          ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY          ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      # clean and rebuild
      CLEAN_DIRECT_OUTPUT               True
    )
    # Windows need copy shared library to exe directory
    if (WIN32)
      add_custom_command(TARGET ${_example_file_shared} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
          ${CPROJECT_SHARED_OUTPUT_DIRECTORY}/${CPROJECT_NAME}.dll
          ${CPROJECT_EXAMPLE_OUTPUT_DIRECTORY}
      )
    endif()
  endif()

  # static library example
  if (CPROJECT_BUILD_STATIC_LIBS)
    # static name
    set(_example_file_static ${_example_file_name}_static)
    # target exec
    add_executable(${_example_file_static} ${_example_file})
    # target exec add depends
    add_dependencies(${_example_file_static} ${CPROJECT_STATIC_LIBRARY})
    # target exec include library
    target_include_directories(${_example_file_static} PUBLIC ${CPROJECT_INCLUDE_DIRECTORY})
    # target exec link library
    target_link_libraries(${_example_file_static} ${CPROJECT_STATIC_LIBRARY})
    # target exec cmake config
    set_target_properties(${_example_file_static} PROPERTIES
      # target output directory
      ARCHIVE_OUTPUT_DIRECTORY          ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY          ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY          ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_DEBUG    ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      LIBRARY_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY_RELEASE  ${CPROJECT_STATIC_OUTPUT_DIRECTORY}
      # clean and rebuild
      CLEAN_DIRECT_OUTPUT               True
    )
  endif()
endforeach()


