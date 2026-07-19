Builder :: struct {
    name                : string = "";
    output_directory    : string = "";
    target              : Operating_System_Tag = OS;
    type                : Build_Type = .STATIC_LIBRARY;
    src_files           : []string = .[];
    extra_arguments     : []string = .[];
    extra_library_files : []string = .[];
    working_directory   : string = "";
    is_successful       : bool = false;
}

Build_Type :: enum {
    STATIC_LIBRARY;
    DYNAMIC_LIBRARY;
    EXECUTABLE;
    OBJ_FILE;
}

build_libs :: (command_options: Command_Options) {
    if (!command_options.build_raygui) {
        return;
    }

    print_dotted_line("", "", "-");
    print("Building Libraries\n");
    print_dotted_line("", "", "-");

    // Build raygui libs
    if (command_options.use_custom_lib_builder) {
        extra_arguments    : []string = .[];
        extra_library_files: []string = .[];
        if OS == .WINDOWS {
            extra_arguments     = .["/DRAYGUI_IMPLEMENTATION", "/I./src/", "/D_USRDLL", "/D_WINDLL", "/DBUILD_LIBTYPE_SHARED", "/LD", "/Feraygui.dll"];
            extra_library_files = .["raylib/lib/windows/raylibdll.lib"];
        } else if OS == .LINUX {
            extra_arguments     = .["-DRAYGUI_IMPLEMENTATION", "-fpic"];
            extra_library_files = .["raylib/lib/linux/raylib.a"];
        } else if OS == .MACOS {
            extra_arguments     = .["-DRAYGUI_IMPLEMENTATION", "-I./src"];
            extra_library_files = .["raylib/lib/macos/raylib.dylib"];
        }

        // Build static raygui lib
        {
            builder: Builder;
            builder.name = "raygui";
            builder.output_directory = String.join("raylib/lib/", get_os_as_string(OS));
            builder.src_files = .["src/raygui.c"];
            builder.type = .STATIC_LIBRARY;
            builder.extra_arguments = extra_arguments;
            builder.is_successful = build_lib(builder);
            print_result("raygui (static)", builder.is_successful);
        }

        // Build dynamic raygui lib
        {
            builder: Builder;
            builder.name = "raygui";
            builder.output_directory = String.join("raylib/lib/", get_os_as_string(OS));
            builder.src_files = .["src/raygui.c"];
            builder.type = .DYNAMIC_LIBRARY;
            builder.extra_arguments = extra_arguments;
            builder.extra_library_files = extra_library_files;
            builder.is_successful = build_lib(builder);
            print_result("raygui (dynamic)", builder.is_successful);
        }
    } else {
        is_successful := false;
        if OS == .WINDOWS {
            // Not working: BuildCpp.build_cpp_dynamic_lib("raylib/lib/windows/raygui", files="src/raygui.c", extra=.["-I./src", "-L./src", "-shared", "-DRAYGUI_IMPLEMENTATION", "-DBUILD_LIBTYPE_SHARED", "-static-libgcc", "-lopengl32", "-lgdi32", "-lwinmm", "-lraylib"]);
            is_successful = BuildCpp.build_cpp_static_lib("raylib/lib/windows/raygui", files="src/raygui.c", extra=.["/I./src/", "/D_USRDLL", "/D_WINDLL", "/DRAYGUI_IMPLEMENTATION", "/DBUILD_LIBTYPE_SHARED", "/LD", "/Feraygui.dll"]);
        } else if OS == .LINUX {
            is_successful = BuildCpp.build_cpp_static_lib("raylib/lib/linux/raygui", files="src/raygui.c", extra=.["-fpic", "-DRAYGUI_IMPLEMENTATION"]);
        } else if OS == .MACOS {
            is_successful = BuildCpp.build_cpp_static_lib("raylib/lib/macos/raygui", files="src/raygui.c", extra=.["-DRAYGUI_IMPLEMENTATION", "-I./src"]);
        }
        print_result("raygui", is_successful);
    }
}


// A simplified version of BuildCpp.build_cpp
build_lib :: (builder: Builder) -> bool {
    arguments: [..] string;

    output_filename: string;
    if builder.target == .WINDOWS {
        vc_path     : string;
        linker_path : string;
        kit_root    : string;

        #if OS != .WINDOWS {
            // compiler_report("Unable to find Visual Studio; can't compile.\n", loc);
            return false; // Visual studio is not available in non-windows OS.
        } else {
            vc_path, linker_path = Windows_Resources.find_visual_studio_in_a_ridiculous_garbage_way();

            kit_root = Windows_Resources.find_windows_kit_root();
            if !kit_root {
                //compiler_report("Unable to find Windows Kit root; can't compile.\n", loc);
                return false;
            }
        }

        if #complete builder.type == {
            case .STATIC_LIBRARY;
                output_filename = Basic.tprint("%/%.lib", builder.output_directory, builder.name);
            case .DYNAMIC_LIBRARY;
                output_filename = Basic.tprint("%/%.dll", builder.output_directory, builder.name);
            case .EXECUTABLE;
                output_filename = Basic.tprint("%/%.exe", builder.output_directory, builder.name);
            case .OBJ_FILE;
                output_filename = Basic.tprint("%/%.obj", builder.output_directory, builder.name);
        }
        String.path_overwrite_separators(output_filename, #char "\\");

        linker := String.join(linker_path, "\\", "cl.exe");
        Basic.array_add(*arguments, linker);
        Basic.array_add(*arguments, "/nologo");

        // Include directories:
        vc_include_path := String.join(vc_path, "\\..\\..\\include");
        kit_root_include := String.replace(kit_root, "Lib", "Include");
        Basic.array_add(*arguments,
            String.tprint("/I%", vc_include_path),
            String.tprint("/I%\\um", kit_root_include),
            String.tprint("/I%\\ucrt", kit_root_include),
            String.tprint("/I%\\shared", kit_root_include),
        );

        // Definitions:
        Basic.array_add(*arguments, "/DWIN32");

        // Compiler options:
        Basic.array_add(*arguments,
            "/O2",                      // Maximize speed.
            "/Oi",                      // Enable intrinsics.
        );
        Basic.array_add(*arguments, "/W3");
        Basic.array_add(*arguments,
            "-diagnostics:caret",
            "-diagnostics:column"
        );

        Basic.array_add(*arguments, .. builder.extra_arguments);

        // Add src_files:
        objs: [..] string;
        for builder.src_files {
            src := String.copy_temporary_string(it);
            String.path_overwrite_separators(src);
            Basic.array_add(*arguments, src);

            Basic.array_add(*objs, String.tprint("%.obj", String.path_strip_extension(String.path_filename(it))));
        }

        // Make sure to cleanup the resulting obj files.
        defer {
            if builder.type != .OBJ_FILE {
                for objs File.file_delete(it);
            }

            if builder.type == .DYNAMIC_LIBRARY {
                File.file_delete(String.tprint("%.exp", builder.name));
                File.file_delete(String.tprint("%.lib", builder.name));
            }
        }

        if builder.type == .STATIC_LIBRARY || builder.type == .OBJ_FILE {
             Basic.array_add(*arguments, "/c");        // Compile without linking.
        } else {
             Basic.array_add(*arguments, "/link");

            // Linker options:
            if builder.type == .DYNAMIC_LIBRARY {
                 Basic.array_add(*arguments, "/DLL");
            }
            Basic.array_add(*arguments,
                "/MACHINE:AMD64",
                String.tprint("/OUT:%", output_filename),
                String.tprint("/libpath:%", vc_path),
                String.tprint("/libpath:%\\um\\x64", kit_root),
                String.tprint("/libpath:%\\ucrt\\x64", kit_root),
                "/INCREMENTAL:NO",
            );
        }

        Basic.array_add(*arguments, .. builder.extra_library_files);

        //log("%", get_quoted_command_string(arguments));
        result, output_string, error_string := Process.run_command(..arguments, capture_and_return_output = true, print_captured_output = true, working_directory = builder.working_directory);

        if result.exit_code {
            //compiler_report(tprint("Compiler failed with exit code '%'.\n", result.exit_code), loc);
            return false;
        }

        if builder.type == .STATIC_LIBRARY {
            // Create library:
            Basic.array_reset(*arguments);

            librarian := String.join(linker_path, "\\lib.exe");

            Basic.array_add(*arguments, librarian, "/nologo");
            Basic.array_add(*arguments, ..objs);
            Basic.array_add(*arguments, String.tprint("/OUT:%", output_filename));

            //log("%", get_quoted_command_string(arguments));
            result, output_string, error_string := Process.run_command(..arguments, capture_and_return_output = true, print_captured_output = true, working_directory = builder.working_directory);

            if result.exit_code {
                //compiler_report(tprint("Librarian failed with exit code '%'.\n", result.exit_code), loc);
                return false;
            }
            return true;
        }
    } else {
        if #complete builder.type == {
            case .STATIC_LIBRARY;
                output_filename = String.tprint("%/%.a", builder.output_directory, builder.name);
            case .OBJ_FILE;
                output_filename = String.tprint("%/%.o", builder.output_directory, builder.name);
            case .DYNAMIC_LIBRARY;
                if builder.target == {
                    case .IOS;     #through;
                    case .MACOS;   output_filename = String.tprint("%/%.dylib", builder.output_directory, builder.name);

                    case .LINUX;   #through;
                    case .ANDROID; output_filename = String.tprint("%/%.so", builder.output_directory, builder.name);

                    case; //assert(false);
                }
            case .EXECUTABLE;
                output_filename = String.copy_temporary_string(String.tprint("%/%", builder.output_directory, builder.name));
        }

        #if OS == .WINDOWS {
            String.path_overwrite_separators(output_filename, #char "\\");
        }


        is_cpp_project := false;
        for builder.src_files {
            if String.ends_with(it, ".cpp") {
                is_cpp_project = true; // Use c++ compiler, so we link the required c++ runtime libraries by default.
                break;
            }
        }

        compiler := "";
        ar       := "ar";
        if is_cpp_project {
            // @Cleanup: Could be simplified to the following, but that currently triggers a compiler bug. -rluba, 2024-01-23
            // compiler = ifx to_string(getenv("CXX")) else "clang++";
            compiler = to_string(get_env("CXX"));
            if !compiler compiler ="clang++";
        } else {
            compiler = to_string(get_env("CC"));
            if !compiler compiler ="clang";
        }

        Basic.array_add(*arguments, compiler);
        Basic.array_add(*arguments, "-O3");
        Basic.array_add(*arguments, .. builder.extra_arguments);

        if builder.type == .STATIC_LIBRARY || builder.type == .OBJ_FILE {
            Basic.array_add(*arguments, "-c");
        } else {
            if builder.type == .DYNAMIC_LIBRARY {
                Basic.array_add(*arguments, "-shared", "-fpic");
            }

            if builder.target == .MACOS {
                if builder.type == {
                    case .DYNAMIC_LIBRARY;
                        Basic.array_add(*arguments, "-install_name", String.tprint("@rpath/%", output_filename));
                    case .EXECUTABLE;
                        Basic.array_add(*arguments, "-rpath", "@loader_path");
                }
            }

            Basic.array_add(*arguments, "-o", output_filename);
        }

        // Add files:
        objs: [..] string;
        for builder.src_files {
            src := String.copy_temporary_string(it);
            String.path_overwrite_separators(src);
            Basic.array_add(*arguments, src);

            Basic.array_add(*objs, String.tprint("%.o", String.path_basename(it)));
        }

        // Make sure to cleanup the resulting obj files.
        defer {
            if builder.type != .OBJ_FILE {
                for objs File.file_delete(it);
            }
        }

        Basic.array_add(*arguments, .. builder.extra_library_files);

        //log("%", get_quoted_command_string(arguments));
        result, output_string, error_string := Process.run_command(..arguments, capture_and_return_output = true, print_captured_output = true, working_directory = builder.working_directory);

        if result.exit_code {
            //compiler_report(tprint("Compiler failed with exit code '%'.\n", result.exit_code), loc);
            return false;
        }

        if builder.type == .STATIC_LIBRARY {
            File.file_delete(output_filename); // ar only adds/updates the archive, but does not delete files from it.

            // Create library:
            Basic.array_reset(*arguments);
            Basic.array_add(*arguments,
                ar,
                ifx builder.target == .WASM then "-rcs" else "-rc",   // replace or insert files into the archive, do not warn if archive needs to be created. (+s for WASM to create an archive index)
                output_filename,
            );

            Basic.array_add(*arguments, ..objs);

            // Run archiver command:
            //log("%", get_quoted_command_string(arguments));
            result, output_string, error_string := Process.run_command(..arguments, capture_and_return_output = true, print_captured_output = true, working_directory = builder.working_directory);

            if result.exit_code {
                //compiler_report(tprint("Archive command failed with exit code '%'.\n", result.exit_code), loc);
                return false;
            }
        }
    }

    return true;
}

get_os_as_string :: (target_os: Operating_System_Tag) -> string {
    if target_os == {
        case .WINDOWS;
            return "windows";
        case .LINUX;
            return "linux";
        case .MACOS;
            return "macos";
    }
    return "unknown";
}

get_env :: (e: *u8) -> *u8 {
    #if OS == .WINDOWS {
        return Windows.getenv(e);
    } else {
        return POSIX.getenv(e);
    }
}