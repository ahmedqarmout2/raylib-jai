Basic       :: #import "Basic";
BuildCpp    :: #import "BuildCpp";
Compiler    :: #import "Compiler";
File        :: #import "File";
Hash_Table  :: #import "Hash_Table";
Print_Color :: #import "Print_Color";
Process     :: #import "Process";
String      :: #import "String";
System      :: #import "System";

#if OS == .WINDOWS {
    Windows_Resources :: #import "Windows_Resources";
    Windows           :: #import "Windows";
} else {
    POSIX :: #import "POSIX";
}

#load "src/binding_generator.jai";
#load "src/example_compiler.jai";
#load "src/lib_builder.jai";

String_Builder   :: Basic.String_Builder;
Table            :: Hash_Table.Table;
print            :: Basic.print;
print_to_builder :: Basic.print_to_builder;

Command_Options :: struct {
    print_help                : bool      = false;
    output_unrecognized_code  : bool      = false;
    log_level                 : Log_Level = .NONE;

    build_raygui              : bool = false;
    use_custom_lib_builder    : bool = false;

    compile_audio_examples    : bool = false;
    compile_core_examples     : bool = false;
    compile_models_examples   : bool = false;
    compile_shaders_examples  : bool = false;
    compile_shapes_examples   : bool = false;
    compile_text_examples     : bool = false;
    compile_textures_examples : bool = false;
    compile_games_examples    : bool = false;
    compile_specific_examples : []string = .[];
}

Log :: struct {
    type    : Log_Type = .INFO;
    message : string = "";
}

Log_Type :: enum {
    INFO;
    WARN;
    ERROR;
}

Log_Level :: enum {
    NONE;
    ERROR;
    ALL;
}

DOTTED_LINE_LENGTH :: 80;
OK                 :: "[   OK   ]";
NOT_OK             :: "[ NOT OK ]";

#run generate();

main :: () {
    // generate();
}

generate :: () {
    Basic.set_working_directory(#filepath);

    Compiler.set_build_options_dc(.{ do_output = false });

    command_options := read_command_line_options();

    if (command_options.print_help) {
        print_help_text();
        return;
    }

    generate_bindings(command_options);
    build_libs(command_options);
    compile_examples(command_options);
}

read_command_line_options :: () -> Command_Options {
    options := Compiler.get_build_options();
    args    := options.compile_time_command_line;

    command_options: Command_Options;
    for arg: args {
        if (arg == "-h" || arg == "--help") {
            command_options.print_help = true;
            break;
        }

        if (arg == "-v" || arg == "--verbose") {
            command_options.log_level = .ALL;
            continue;
        }

        if (arg == "--build_raygui") {
            command_options.build_raygui = true;
            continue;
        }

        if (arg == "--use_custom_lib_builder") {
            command_options.use_custom_lib_builder = true;
            continue;
        }

        if (arg == "--compile_all_examples") {
            command_options.compile_audio_examples = true;
            command_options.compile_core_examples = true;
            command_options.compile_models_examples = true;
            command_options.compile_shaders_examples = true;
            command_options.compile_shapes_examples = true;
            command_options.compile_text_examples = true;
            command_options.compile_textures_examples = true;
            command_options.compile_games_examples = true;
            continue;
        }

        if (arg == "--compile_audio_examples") {
            command_options.compile_audio_examples = true;
            continue;
        }

        if (arg == "--compile_core_examples") {
            command_options.compile_core_examples = true;
            continue;
        }

        if (arg == "--compile_models_examples") {
            command_options.compile_models_examples = true;
            continue;
        }

        if (arg == "--compile_shaders_examples") {
            command_options.compile_shaders_examples = true;
            continue;
        }

        if (arg == "--compile_shapes_examples") {
            command_options.compile_shapes_examples = true;
            continue;
        }

        if (arg == "--compile_text_examples") {
            command_options.compile_text_examples = true;
            continue;
        }

        if (arg == "--compile_textures_examples") {
            command_options.compile_textures_examples = true;
            continue;
        }

        if (arg == "--compile_games_examples") {
            command_options.compile_games_examples = true;
            continue;
        }

        if (String.starts_with(arg, "--compile_specific_examples")) {
            pieces := String.split(arg, "=");
            if (pieces.count != 2) {
                print("something is wrong with --compile_specific_examples\n");
            }
            command_options.compile_specific_examples = String.split(pieces[1], ",");
            continue;
        }

        if (String.starts_with(arg, "--log_level")) {
            pieces := String.split(arg, "=");
            if (pieces.count != 2) {
                print("something is wrong with --log_level\n");
            }
            command_options.log_level = .NONE;
            if pieces[1] == {
                case "none";  command_options.log_level = .NONE;
                case "error"; command_options.log_level = .ERROR;
                case "all";   command_options.log_level = .ALL;
                case; {
                    command_options.print_help = true;
                    print("Unknown log_level: '%'.\n", pieces[1]);
                }
            }
            continue;
        }

        command_options.print_help = true;
        print("Unknown argument '%'.\n", arg);
    }
    return command_options;
}

print_help_text :: () {
    print("Usage: jai generate.jai [- <options>]\n");
    print("Options:\n");
    print("    -h, --help                              Print this text\n");
    print("    -v, --verbose                           Display all log messages and compilation output. Equivalent to --log_level=all\n");
    print("        --log_level=(none,error,all)        Set logs verbosity\n");
    print("        --build_raygui                      Build raygui's C files into static lib files\n");
    print("        --compile_all_examples              Compile all examples\n");
    print("        --compile_audio_examples            Compile audio examples\n");
    print("        --compile_core_examples             Compile core examples\n");
    print("        --compile_models_examples           Compile models examples\n");
    print("        --compile_shaders_examples          Compile shaders examples\n");
    print("        --compile_shapes_examples           Compile shapes examples\n");
    print("        --compile_text_examples             Compile text examples\n");
    print("        --compile_textures_examples         Compile textures examples\n");
    print("        --compile_games_examples            Compile games examples\n");
    print("        --compile_specific_examples         Compile a list of comma-separated examples. For example: snake,core_basic_window,text_3d_drawing\n");
}

print_dotted_line :: (prefix: string, suffix: string, repeated_char := ".") {
    dots_count := DOTTED_LINE_LENGTH - prefix.count - suffix.count;
    line := prefix;
    for 0..dots_count-1 {
        line = String.join(line, repeated_char);
    }
    line = String.join(line, suffix);
    print("%\n", line);
}

print_result :: (prefix: string, result: bool) {
    dots_count := DOTTED_LINE_LENGTH - prefix.count - 2 - OK.count; // [prefix][space][dots][space][result]
    line := String.join(prefix, " ");
    for 0..dots_count-1 {
        line = String.join(line, ".");
    }
    line = String.join(line, " ");
    print("%", line);

    Print_Color.print_color("%\n", ifx result then OK else NOT_OK, color=ifx result then .GREEN else .RED);
}

print_logs :: (command_options: Command_Options, logs: []Log) {
    if (command_options.log_level == .NONE) return;

    for log: logs {
        if ((log.type == .INFO || log.type == .WARN) && command_options.log_level != .ALL) continue;

        print_log(log.type, log.message);
    }
}

print_log :: (type: Log_Type, message: string) {
    if type == {
        case .INFO;  Print_Color.print_color("[INFO] ", color=.CYAN);
        case .WARN;  Print_Color.print_color("[WARN] ", color=.YELLOW);
        case .ERROR; Print_Color.print_color("[ERROR] ", color=.RED);
    }
    print("%", message);
}