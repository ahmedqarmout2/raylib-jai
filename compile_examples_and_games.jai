Basic          :: #import "Basic";
BuildCpp       :: #import "BuildCpp";
Compiler       :: #import "Compiler";
File           :: #import "File";
File_Utilities :: #import "File_Utilities";
Hash_Table     :: #import "Hash_Table";
Print_Color    :: #import "Print_Color";
Process        :: #import "Process";
String         :: #import "String";
System         :: #import "System";

print       :: Basic.print;
print_color :: Print_Color.print_color;

EXAMPLES :: string.[
    "examples/audio",
    "examples/core",
    "examples/models",
    "examples/shaders",
    "examples/shapes",
    "examples/text",
    "examples/textures"
];

GAMES :: string.[
    "games/cat_vs_roomba/src/cat_vs_roomba.jai",
    "games/classics/src/snake.jai",
    "games/classics/src/space_invaders.jai"
];

LINE_LENGTH   :: 80;
OK            :: "[   OK   ]";
NOT_OK        :: "[ NOT OK ]";

g_verbose := false;

#run compile();

main :: () {
    // compile();
}

compile :: () {
    Compiler.set_build_options_dc(.{ do_output = false });

    print_help, specific_files := read_build_options();

    if (print_help) {
        print_help_text();
        return;
    }

    // Specify a list of files to compile using the "-f"/"-file" option. This is useful when working on a single example/game
    if (specific_files.count > 0) {
        for specific_files {
            if String.ends_with(it, ".jai") {
                compile_file(it);
            }
        }
        return;
    }

    // Compile all examples by iterating over all the directories under "example'
    for EXAMPLES {
        files := File_Utilities.file_list(it);
        for file: files {
            if String.ends_with(file, ".jai") {
                compile_file(file);
            }
        }
    }

    // Compile all games by iterating over their entry points
    for GAMES {
        compile_file(it);
    }
}

read_build_options :: () -> (bool, []string) {
    options := Compiler.get_build_options();
    args    := options.compile_time_command_line;

    specific_files : []string;
    print_help     := false;

    for i: 0..args.count-1 {
        arg := args[i];

        if (arg == "-h" || arg == "--help") {
             return true, specific_files;
        }

        if (arg == "-v" || arg == "--verbose") {
             g_verbose = true;
             continue;
        }

        if (arg == "-f" || arg == "--file") {
            i = i + 1;
            if (i <= args.count-1) {
                specific_files = String.split(args[i], ",");
            }
            continue;
        }

        print_help = true;
        print("Unknown argument '%'.\n", arg);
    }
    return print_help, specific_files;
}

compile_file :: (entry_point: string) {
    jai_exec := System.get_path_of_running_executable();

    result, output, error := Process.run_command(jai_exec, entry_point, "-import_dir", #filepath, capture_and_return_output = true);

    print_header(entry_point, result.exit_code == 0);

    if (g_verbose) {
        print("%", error);
        print("%", output);
    }
}

print_header :: (file_name: string, result: bool) {
    dots_count := LINE_LENGTH - file_name.count - 2 - OK.count;
    header := file_name;
    header = String.join(header, " ");
    for 0..dots_count-1 {
        header = String.join(header, ".");
    }
    header = String.join(header, " ");
    print("%", header);

    print_color("%\n", ifx result then OK else NOT_OK, color=ifx result then .GREEN else .RED);
}

print_help_text :: () {
    print("Usage: jai compile_examples_and_games.jai [- <options>]\n");
    print("Options:\n");
    print("    -f, --file <string>    Compile a comma-separated list of files\n");
    print("    -v, --verbose          Display the compilation output\n");
    print("    -h, --help             Print this text\n");
}
