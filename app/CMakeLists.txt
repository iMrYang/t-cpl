# output
set(APP_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build/bin/)

# source files
aux_source_directory(${CMAKE_CURRENT_LIST_DIR}/   CPROJECT_APP_SOURCE_FILES)

# add suffix
set(APP_USE_SUFFIX  OFF)
if (${CPROJECT_BUILD_CPROJECT_SHARED_LIBS} AND ${CPROJECT_BUILD_CPROJECT_STATIC_LIBS})
  set(APP_USE_SUFFIX  ON)
endif()

# shared library test
if (CPROJECT_BUILD_CPROJECT_SHARED_LIBS)
  # add test
  foreach(_app_file ${CPROJECT_APP_SOURCE_FILES})
    # retrieve file name
    STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _app_file_name ${_app_file})
    # rename
    if (APP_USE_SUFFIX)
      set(_app_file_name ${_app_file_name}_shared)
    endif()
    # exec
    add_executable(${_app_file_name} ${_app_file})
    # add depends
    add_dependencies(${_app_file_name} ${CPROJECT_SHARED_LIBRARY})
    # include library
    target_include_directories(${_app_file_name} PUBLIC ${CPROJECT_ISEC_INCLUDE_DIRECTORY})
    # link library
    target_link_libraries(${_app_file_name} ${CPROJECT_SHARED_LIBRARY})
    # install
    install(TARGETS ${_app_file_name} DESTINATION bin)
  endforeach()
endif()

# static library test
if (CPROJECT_BUILD_CPROJECT_STATIC_LIBS)
  # add test
  foreach(_app_file ${CPROJECT_APP_SOURCE_FILES})
    # retrieve file name
    STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" _app_file_name ${_app_file})
    # rename
    if (APP_USE_SUFFIX)
      set(_app_file_name ${_app_file_name}_static)
    endif()
    # add exec
    add_executable(${_app_file_name} ${_app_file})
    # add depends
    add_dependencies(${_app_file_name} ${CPROJECT_STATIC_LIBRARY})
    # link library
    target_link_libraries(${_app_file_name} ${CPROJECT_STATIC_LIBRARY})
    # install
    install(TARGETS ${_app_file_name} DESTINATION bin)
  endforeach()
endif()
