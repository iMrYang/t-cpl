#!/usr/bin/perl

use strict;
use Cwd 'abs_path';
use File::Basename;
use File::Path;
use Getopt::Long;

# read-only config
my $cmake_source_dir = dirname(dirname(abs_path($0)));
my $cmake_work_dir = $cmake_source_dir . "/build";
my $cmake_toolchain_dir = "$cmake_source_dir/CMake/Toolchains";
my $cmd = "";
# user config
my $cmake_system_processor = "";
my $cmake_build_type = "Release";
my $cmake_toolset_name = "";
my $cmake_toolchain_file = "";
my $cmake_install_prefix = "";

# parse command line arguments
$cmd = shift @ARGV;
GetOptions(
    "p:s" => \$cmake_system_processor,
    "t:s" => \$cmake_build_type,
    "toolset:s" => \$cmake_toolset_name,
    "toolchain:s" => \$cmake_toolchain_file,
    "prefix:s" => \$cmake_install_prefix,
    "h:s" => \$cmd,
    "help:s" => \$cmd
);

# platform init params
if ("$^O" eq "MSWin32") {
    # windows

    # init system processor
    if ("$cmake_system_processor" eq "") {
        $cmake_system_processor = (log(~0 +1)/log(2) eq 64) ? "x86_64" : "x86";
    }
}

# function: build
sub build {
    # cmake init
    if (! -d $cmake_work_dir) {
        mkpath($cmake_work_dir);
    }
    if ("$cmake_build_type" eq "") {
        die("Error: cmake build type is null.");
    }
    my $cmake_init_project_cmd = "cmake ${cmake_source_dir} -DCMAKE_BUILD_TYPE=$cmake_build_type";

    # platform specific
    if ("$^O" eq "MSWin32") {
        # windows

        # add platform
        if ("$cmake_system_processor" eq "") {
            die("Error: cmake system processor is null.");

        } elsif ("$cmake_system_processor" eq "x86_64") {
            # x64
            $cmake_init_project_cmd .= " -A x64";

        } elsif ("$cmake_system_processor" eq "x86") {
            # x86
            $cmake_init_project_cmd .= " -A Win32";

        } else {
            # arm
            $cmake_init_project_cmd .= " -A ARM";
        }

        # add toolset
        if ("$cmake_toolset_name" ne "") {
            $cmake_init_project_cmd .= " -T ${cmake_toolset_name}";
        }

        # set windows toolchain
        if ($cmake_toolchain_file eq "") {
            $cmake_toolchain_file = "$cmake_toolchain_dir/Windows_$cmake_system_processor.cmake";
        }

    } elsif ("$^O" eq "linux") {
        # linux

        # if set sysmtem processor and toolchain is null, use build-in toolchain
        if (("$cmake_system_processor" ne "") && $cmake_toolchain_file eq "") {
            $cmake_toolchain_file = "$cmake_toolchain_dir/Linux_x86.cmake";
        }

    } else {
        print("Warning: unknown system: $^O\n");
    }

    # cross compile
    if ($cmake_toolchain_file ne "") {
        # check toolchain exist
        if (! -f $cmake_toolchain_file) {
            die("Error: toolchain file not exist: $cmake_toolchain_file\n");
        }
        # add toolchain file
        $cmake_init_project_cmd .= " -DCMAKE_TOOLCHAIN_FILE=$cmake_toolchain_file";
    }

    # install prefix
    if ($cmake_install_prefix ne "") {
        $cmake_init_project_cmd .= " -DCMAKE_INSTALL_PREFIX=$cmake_install_prefix";
    }

    # cmake init project
    chdir($cmake_work_dir) and system("$cmake_init_project_cmd") and die("Error: cmake init project failed.");

    # cmake build project
    chdir($cmake_work_dir) and system("cmake --build . --config $cmake_build_type") and die("Error: cmake build project failed.");
}

# function
sub test {
    # cmake test project
    system("ctest --test-dir $cmake_work_dir/tests") and die("Error: cmake test project failed.");
}

# function: clean
sub clean {
    # clean build directory
    if (-d $cmake_work_dir) {
        rmtree($cmake_work_dir);
    }
}

# function: install
sub install {
    # install
    system("cmake --install $cmake_work_dir") and die("Error: cmake install failed.");
}

# function: help
sub help {
    print("\n");
    print("Usage: $0 [Command] [Options]\n");
    print("\n");
    print("Command:\n");
    print("    build            - Build project\n");
    print("    test             - Test project\n");
    print("    install          - Install project\n");
    print("    clean            - Clean build project\n");
    print("    help             - Display help and exit\n");
    print("\n");
    print("Options:\n");
    print("    -p               - Target build arch [x86|x86_64|..] (default: $cmake_system_processor)\n");
    print("    -t               - Target build type[Release|Debug] (default: ${cmake_build_type})\n");
    print("        --toolchain  - CMake cross compile toolchains file (default: ${cmake_toolchain_file})\n");
    print("        --toolset    - Specify toolset name(ex: VS2017 set 'v141_xp' to support WinXP) (default: ${cmake_toolset_name})\n");
    print("    -p, --prefix     - Install directory(default: ${cmake_install_prefix})\n");
    print("    -h, --help       - Display help and exit\n");
    print("\n");
    exit(0);
}

# command
if ("$cmd" eq "build") {
    build();
} elsif ("$cmd" eq "test") {
    test();
} elsif ("$cmd" eq "install") {
    install();
} elsif ("$cmd" eq "clean") {
    clean();
} elsif ("$cmd" eq "help") {
    help();
} else {
    help();
}
