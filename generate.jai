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

        line := file_lines[g_line_counter];

        clean_line := String.trim(line);
        if (clean_line.count == 0) {
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

        prefix = "typedef struct";
        if (String.starts_with(line, prefix)) {
            handle_struct(file_lines, *builder);
            continue;
        }

        // Print unrecognized lines
        // print("%\n", line);
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
}

handle_struct :: (file_lines: []string, builder: *String_Builder) {
    definition_line       := file_lines[g_line_counter];
    definition_line_parts := String.split(definition_line, " ");
    if (definition_line_parts.count < 4) {
        print("--Unexpected struct definition--\n");
        print("%\n", definition_line);
        print("--Expected: typedef struct <NAME> { --\n");
        return;
    }

    struct_name := definition_line_parts[2];
    struct_end  := String.join("} ", struct_name, ";");

    print_to_builder(builder, "% :: {\n", struct_name);
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a struct\n");
            return;
        }

        line := file_lines[g_line_counter];
        if (String.starts_with(line, struct_end)) {
            print_to_builder(builder, "}\n");
            return;
        }

        line_parts := String.split(line, ";");
        if (line_parts.count != 2) {
            print("Unexpected struct data formart\n");
        }

        comment := line_parts[1];

        code_part := String.split(String.trim(line_parts[0]), " ");
        old_type  := code_part[0];
        new_type  := convert_type(old_type);

        // Indentation for formating
        print_to_builder(builder, "    ");

        // Array prefix
        if (code_part.count == 2) {
            value := code_part[1];

            // Check if this is an array value
            right_bracket_idx := String.find_index_from_right(value, "]");
            left_bracket_idx  := String.find_index_from_right(value, "[");

            if (right_bracket_idx >= 0 && left_bracket_idx >= 0) {
                array_prefix := String.slice(value, left_bracket_idx, right_bracket_idx - left_bracket_idx + 1);
                
                // Adjust the new type to inlcude array part
                new_type = String.join(array_prefix, new_type);
                
                // Adjust the value to remove array part
                value = String.slice(value, 0, left_bracket_idx);
            }
            print_to_builder(builder, "%", value);
        } else {
            // We could have a list of names with one type. For example: float m0, m4, m8, m12;
            for i: 1..code_part.count-1 {
                print_to_builder(builder, "%", code_part[i]);
            }
        }

        print_to_builder(builder, ": %; %\n", new_type, comment);
    }
}

convert_type :: (type: string) -> string {
    if type == {
        case "const char";     return "u8";
        case "unsigned short"; return "u16";
        case "unsigned int";   return "u32";
        case "unsigned char";  return "u8";
        case "char";           return "s8";
        case "long";           return "s32";
        case "double";         return "float64";
        case "int";            return "s32";
        case "Matrix";         return "Matrix4";
    }
    return type;
}
