AUDIO_EXAMPLES          :: string.[
    "audio_amp_envelope"
];
CORE_EXAMPLES           :: string.[
    "core_2d_camera_mouse_zoom"
];
MODELS_EXAMPLES         :: string.[
    "models_animation_gpu_skinning"
];
SHADERS_EXAMPLES        :: string.[
    "shaders_ascii_rendering"
];
SHAPES_EXAMPLES         :: string.[
    "shapes_basic_shapes"
];
TEXT_EXAMPLES           :: string.[
    "text_3d_drawing"
];
TEXTURES_EXAMPLES       :: string.[
    "textures_background_scrolling"
];

// Even values are names
// Odd values are entry points
GAMES :: string.[
    "cat_vs_roomba",  "games/cat_vs_roomba/src/cat_vs_roomba.jai",
    "snake",          "games/classics/src/snake.jai",
    "space_invaders", "games/classics/src/space_invaders.jai"
];

compile_examples :: (command_options: Command_Options) {
    print_dotted_line("", "", "-");
    print("Compiling Examples\n");
    print_dotted_line("", "", "-");
    compile_examples := command_options.compile_audio_examples ||
        command_options.compile_core_examples ||
        command_options.compile_models_examples ||
        command_options.compile_shaders_examples ||
        command_options.compile_shapes_examples ||
        command_options.compile_text_examples ||
        command_options.compile_textures_examples;
    if (compile_examples) {
        if (command_options.compile_audio_examples)    for AUDIO_EXAMPLES    compile_file(command_options, "[AUDIO]",    "examples/audio",    it);
        if (command_options.compile_core_examples)     for CORE_EXAMPLES     compile_file(command_options, "[CORE]",     "examples/core",     it);
        if (command_options.compile_models_examples)   for MODELS_EXAMPLES   compile_file(command_options, "[MODELS]",   "examples/models",   it);
        if (command_options.compile_shaders_examples)  for SHADERS_EXAMPLES  compile_file(command_options, "[SHADERS]",  "examples/shaders",  it);
        if (command_options.compile_shapes_examples)   for SHAPES_EXAMPLES   compile_file(command_options, "[SHAPES]",   "examples/shapes",   it);
        if (command_options.compile_text_examples)     for TEXT_EXAMPLES     compile_file(command_options, "[TEXT]",     "examples/text",     it);
        if (command_options.compile_textures_examples) for TEXTURES_EXAMPLES compile_file(command_options, "[TEXTURES]", "examples/textures", it);
    } else {
        // Compile some examples to make sure the bindings were generated correctly
        if (command_options.build_raygui) {
            compile_file(command_options, "[AUDIO]", "examples/audio", "audio_amp_envelope");
        }
        compile_file(command_options, "[CORE]", "examples/core", "core_basic_window");
    }
}

compile_file :: (command_options: Command_Options, output_prefix: string, file_path: string, file_name: string) {
    jai_exec_path := System.get_path_of_running_executable();

    result, output, error := Process.run_command(jai_exec_path, String.join(file_path, "/", file_name, ".jai"), "-import_dir", String.join(#filepath, "/.."), capture_and_return_output = true);

    print_result(String.join(output_prefix, " ", file_name), result.exit_code == 0);
    if (command_options.is_verbose) {
        print("%", error);
        print("%", output);
    }
}