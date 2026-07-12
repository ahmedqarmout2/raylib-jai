build_extra_libs :: (command_options: Command_Options) {
    print_dotted_line("", "", "-");
    print("Building Libraries\n");
    print_dotted_line("", "", "-");

    // Build raygui libs
    {
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