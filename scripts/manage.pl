#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;
use File::Path;

# c-project-layout directory
$project_root_dir = dirname(dirname(abs_path($0)));
$project_build_dir = "$project_root_dir/build";
$project_toolchain_dir = "$project_root_dir/CMake/Toolchains";

# config
$cmake_work_dir = "${project_build_dir}";
$cmake_toolchain_file = "";
$cmake_build_type = "Release";
$CMAKE_SYSTEM_PROCESSOR = "";
$cmake_toolset_name = "";
$cmake_install_prefix= "";

sub help()
{
    print("\n");
    print("Usage: $0 [Command] [Options]\n");
    print("\n");
    print("Command:\n");
    print("    build  - Build project\n");
    print("    test   - Test project\n");
    print("    clean  - Clean project\n");
    print("\n");
    print("Options:\n");
    print("    -c           - CMake cross compile toolchains file\n");
    print("    -t           - Target build type('Release','Debug'), default is 'Release'\n");
    print("    -p           - Target build arch('x86','x86_64')\n");
    print("    -T           - Specify toolset name if supported by generator(ex: VS2017 set 'v141_xp' to support WinXP )\n");
    print("    -h           - Display help and exit\n");
    print("        --prefix - Install directory prefix\n");
    print("\n");
}

sub build()
{
    # create project
    if (! -d $cmake_work_dir) {
        # create dir
        mkpath($cmake_work_dir) or die("create directory '$cmake_work_dir' error\n");
    }

    # chdir
    chdir($cmake_work_dir) or die("change directory '$cmake_work_dir' error\n");

    # cmake init project
    $cmake_init_cmd="cmake ${project_root_dir} -DCMAKE_BUILD_TYPE=${cmake_build_type}";

    # cmake init project(add system option) https://cmake.org/cmake/help/v3.16/generator/Visual%20Studio%2016%202019.html#platform-selection
    if ("$^O" eq "MSWin32") {
        # Windows

        # windows choose default processor
        if ("${CMAKE_SYSTEM_PROCESSOR}" eq "") {
            if (log(~0 +1)/log(2) eq 64) {
                $CMAKE_SYSTEM_PROCESSOR = "x86_64";
            } else {
                $CMAKE_SYSTEM_PROCESSOR = "x86";
            }
        }

        # init cmake
        if ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86") {
            $cmake_init_cmd="$cmake_init_cmd -A Win32";
        } elsif ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86_64") {
            $cmake_init_cmd="$cmake_init_cmd -A x64";
        } else {
            die("Target processor('$CMAKE_SYSTEM_PROCESSOR') error\n");
        }

        # cross compile
        if ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86_64") {
            if (${cmake_toolchain_file} eq "") {
                $cmake_toolchain_file = "${project_toolchain_dir}/Windows_x86_64.cmake"
            }

        } elsif ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86") {
            if (${cmake_toolchain_file} eq "") {
                $cmake_toolchain_file = "${project_toolchain_dir}/Windows_x86.cmake"
            }

        } else {
            die("Target processor('$CMAKE_SYSTEM_PROCESSOR') error\n");
        }

    } elsif ("$^O" eq "linux") {
        # Linux

        # cross compile
        if ("${CMAKE_SYSTEM_PROCESSOR}" eq "") {
            # no set is default

        } elsif ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86_64") {
            # 64bit do not change

        } elsif ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86") {
            # if x86_64 cross compile x86
            if (log(~0 +1)/log(2) eq 64) {
                if ("${CMAKE_SYSTEM_PROCESSOR}" eq "x86") {
                    if (${cmake_toolchain_file} eq "") {
                        $cmake_toolchain_file = "${project_toolchain_dir}/Linux_x86.cmake";
                    }
                }
            }

        } else {
            # arm
            $cmake_toolchain_file = "${project_toolchain_dir}/Linux_${CMAKE_SYSTEM_PROCESSOR}.cmake";

            # arm must exist toolchain file
            if ( ! -f ${cmake_toolchain_file}) {
                die("Target processor('$CMAKE_SYSTEM_PROCESSOR') no toolchain file\n");
            }
        }
    }

    # cmake init add cross compile toolchain file option
    if (${cmake_toolchain_file} ne "") {
        # check exist
        if (! -e $cmake_toolchain_file) {
            die("Cross compile toolchinas not exist, file: '$cmake_toolchain_file'\n");
        }
        # append command
        $cmake_init_cmd = "${cmake_init_cmd} -DCMAKE_TOOLCHAIN_FILE=$cmake_toolchain_file";
    }

    # cmake init add toolset
    if (${cmake_toolset_name} ne "") {
        # append command
        $cmake_init_cmd = "${cmake_init_cmd} -T$cmake_toolset_name";
    }

    # cmake init add install prefix
    if (${cmake_install_prefix} ne "") {
        # append command
        $cmake_init_cmd = "${cmake_init_cmd} -DCMAKE_INSTALL_PREFIX=$cmake_install_prefix";
    }

    # cmake init project
    system("${cmake_init_cmd}") and die("Init cmake project error\n");

    # cmake build
    system("cmake --build . --config ${cmake_build_type}") and die("Build cmake project error\n");
}

sub install()
{
    if (-d $cmake_work_dir) {
        chdir($cmake_work_dir) or die "change directory '$cmake_work_dir' error";
        system("cmake -P cmake_install.cmake --install .") and die("Install cmake project error\n");
    } else {
        print("No install were found! $cmake_work_dir\n");
    }
}

sub test()
{
    $project_test_dir = "$cmake_work_dir/tests";

    if (-d $project_test_dir) {
        chdir($project_test_dir) or die("change directory '$project_test_dir' error");
        system("ctest .") and die("Test cmake project error\n");
    } else {
        print("No tests were found! $project_test_dir\n");
    }
}

sub clean()
{
    if ( -d $project_build_dir) {
        rmtree($project_build_dir, 0, 0);
    }
}

# Command
$cmd = shift @ARGV;

# Options
while (@ARGV) {
    $a = shift @ARGV;
    if ($a eq "-c") {
        $cmake_toolchain_file = shift @ARGV;

    } elsif ($a eq "-t") {
        $cmake_build_type = shift @ARGV;

    } elsif ($a eq "-p") {
        $CMAKE_SYSTEM_PROCESSOR = shift @ARGV;

    } elsif ($a eq "-T") {
        $cmake_toolset_name = shift @ARGV;

    } elsif ($a eq "--prefix") {
        $cmake_install_prefix = shift @ARGV;

    } elsif ($a eq "-h") {
        help() and exit;

    } else {
        print("Invalid options '$a'\n\n");
        help() and exit;
    }
}

# Init variables
if ($cmake_build_type ne "") {
    $cmake_build_type = "Release";
}
$cmake_work_dir = "$project_build_dir/$^O/${CMAKE_SYSTEM_PROCESSOR}/$cmake_build_type";

# Run
if ($cmd eq "build") {
    build();
} elsif ($cmd eq "test") {
    test();
} elsif ($cmd eq "install") {
    install();
}  elsif ($cmd eq "clean") {
    clean();
} else {
    help() and exit;
}

chdir($project_root_dir)
