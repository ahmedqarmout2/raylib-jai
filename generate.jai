Basic  :: #import "Basic";
File   :: #import "File";
String :: #import "String";

String_Builder   :: Basic.String_Builder;
print            :: Basic.print;
print_to_builder :: Basic.print_to_builder;

main :: () {
    generate_bindings("raymath", "raymath");
}

g_line_counter := -1;
g_lines_count  := 0;

generate_bindings :: (input_filename: string, output_filename: string) {
    print("------------------------------------\n");
    print("Generate bindings for: %\n", input_filename);

    input_file := String.join("include/", input_filename, ".h");

    file, success := File.file_open(input_file);
    if !success {
        print("Could not open file: %\n", input_file);
        return;
    }

    length := File.file_length(file);
    buffer := cast(*u8) Basic.alloc(length);

    success = File.file_read(file, buffer, length);
    if !success {
        print("Could not read file: %\n", input_file);
        return;
    }

    builder: String_Builder;
    file_data: string;
    file_data.data  = buffer;
    file_data.count = length;
    file_lines := String.split(file_data, "\n");
    g_lines_count = file_lines.count;

    for file_lines {
        if (!increment_line_counter()) {
            break;
        }

        line := String.trim(file_lines[g_line_counter]);
        print("%\n", line);

        if (line.count == 0) {
            print_to_builder(*builder, "\n");
            continue;
        }

        prefix := "/*";
        if (String.starts_with(line, prefix)) {
            handle_comment_block(file_lines, *builder);
            continue;
        }

        prefix = "//";
        if (String.starts_with(line, prefix)) {
            print_to_builder(*builder, "%\n", line);
            continue;
        }
    }

    Basic.free(buffer);
    File.file_close(*file);

    output_file := String.join("raylib/", output_filename, ".jai");
    File.write_entire_file(output_file, *builder);
    print("------------------------------------\n");
}

increment_line_counter :: () -> bool {
    g_line_counter += 1;
    return g_line_counter < g_lines_count - 1;
}

handle_comment_block :: (file_lines: []string, builder: *String_Builder) {
    suffix :: "*/";
    while (true) {
        line := String.trim(file_lines[g_line_counter]);
        print_to_builder(builder, "%\n", line);
        if (String.ends_with(line, suffix)) {
            return;
        }

        if (!increment_line_counter()) {
            print("EOF while looking for the end of a comment block\n");
            return;
        }
    }
};
