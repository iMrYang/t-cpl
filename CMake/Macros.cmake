# Retrieve file name from filepath
macro(basename filepath filename)
  STRING(REGEX REPLACE ".+/(.+)\\..*" "\\1" ${filename} ${filepath})
endmacro()

# aux source all sub directory
macro(cproject_aux_source_directory dir variable)
    aux_source_directory(${dir} ${variable})

    file(GLOB _dir_path_list RELATIVE ${dir} ${dir}/*)
    foreach(_dir_path ${_dir_path_list})
        if(IS_DIRECTORY ${dir}/${_dir_path})
            cproject_aux_source_directory(${dir}/${_dir_path} ${variable})
        endif()
    endforeach()
endmacro()

# include all sub directories
macro(cproject_include_directories dir)
    include_directories(${dir})
    file(GLOB _dir_path_list RELATIVE ${dir} ${dir}/*)
    foreach(_dir_path ${_dir_path_list})
        if(IS_DIRECTORY ${dir}/${_dir_path})
            cproject_include_directories(${dir}/${_dir_path})
        endif()
    endforeach()
endmacro()

