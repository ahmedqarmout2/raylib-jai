AUDIO_EXAMPLES :: string.[
    "audio_amp_envelope",
    "audio_mixed_processor",
    "audio_module_playing",
    "audio_music_stream",
    "audio_raw_stream",
    "audio_sound_loading",
    "audio_sound_multi",
    "audio_sound_positioning",
    "audio_spectrum_visualizer",
    "audio_stream_callback",
    "audio_stream_effects"
];
CORE_EXAMPLES :: string.[
    "core_2d_camera",
    "core_2d_camera_mouse_zoom",
    "core_2d_camera_platformer",
    "core_2d_camera_split_screen",
    "core_3d_camera_first_person",
    "core_3d_camera_fps",
    "core_3d_camera_free",
    "core_3d_camera_mode",
    "core_3d_camera_split_screen",
    "core_3d_picking",
    "core_automation_events",
    "core_basic_screen_manager",
    "core_basic_window",
    "core_drop_files",
    "core_input_gamepad",
    "core_input_keys",
    "core_input_mouse",
    "core_input_mouse_wheel",
    "core_random_sequence",
    "core_random_values",
    "core_scissor_test",
    "core_smooth_pixelperfect",
    "core_window_flags",
    "core_window_letterbox",
    "core_window_should_close",
    "core_world_screen"
];
MODELS_EXAMPLES :: string.[
    "models_animation_gpu_skinning",
    "models_billboard_rendering",
    "models_bone_socket",
    "models_box_collisions",
    "models_cubicmap_rendering",
    "models_first_person_maze",
    "models_geometric_shapes",
    "models_heightmap_rendering",
    "models_loading",
    "models_loading_gltf",
    "models_loading_m3d",
    "models_loading_vox",
    "models_mesh_generation",
    "models_mesh_picking",
    "models_orthographic_projection",
    "models_point_rendering",
    "models_rlgl_solar_system",
    "models_skybox_rendering",
    "models_textured_cube",
    "models_waving_cubes",
    "models_yaw_pitch_roll"
];
SHADERS_EXAMPLES :: string.[
    "shaders_ascii_rendering",
    "shaders_basic_lighting",
    "shaders_basic_pbr",
    "shaders_custom_uniform",
    "shaders_deferred_rendering",
    "shaders_eratosthenes_sieve",
    "shaders_fog_rendering",
    "shaders_hot_reloading",
    "shaders_hybrid_render",
    "shaders_julia_set",
    "shaders_lightmap_rendering",
    "shaders_mesh_instancing",
    "shaders_model_shader",
    "shaders_multi_sample2d",
    "shaders_palette_switch",
    "shaders_postprocessing",
    "shaders_raymarching_rendering",
    "shaders_shadowmap_rendering",
    "shaders_shapes_textures",
    "shaders_simple_mask",
    "shaders_spotlight_rendering",
    "shaders_texture_outline",
    "shaders_texture_rendering",
    "shaders_texture_tiling",
    "shaders_texture_waves",
    "shaders_vertex_displacement"
];
SHAPES_EXAMPLES :: string.[
    "shapes_basic_shapes",
    "shapes_bouncing_ball",
    "shapes_circle_sector_drawing",
    "shapes_collision_area",
    "shapes_colors_palette",
    "shapes_easings_ball",
    "shapes_easings_box",
    "shapes_easings_rectangles",
    "shapes_following_eyes",
    "shapes_lines_bezier",
    "shapes_logo_raylib",
    "shapes_logo_raylib_anim",
    "shapes_rectangle_scaling",
    "shapes_ring_drawing",
    "shapes_rounded_rectangle_drawing",
    "shapes_splines_drawing",
    "shapes_top_down_lights"
];
TEXT_EXAMPLES :: string.[
    "text_3d_drawing",
    "text_codepoints_loading",
    "text_font_filters",
    "text_font_loading",
    "text_font_sdf",
    "text_font_spritefont",
    "text_format_text",
    "text_input_box",
    "text_rectangle_bounds",
    "text_sprite_fonts",
    "text_unicode_emojis",
    "text_writing_anim"
];
TEXTURES_EXAMPLES :: string.[
    "textures_background_scrolling",
    "textures_blend_modes",
    "textures_bunnymark",
    "textures_fog_of_war",
    "textures_gif_player",
    "textures_image_channel",
    "textures_image_drawing",
    "textures_image_generation",
    "textures_image_kernel",
    "textures_image_loading",
    "textures_image_processing",
    "textures_image_rotate",
    "textures_image_text",
    "textures_logo_raylib",
    "textures_mouse_painting",
    "textures_npatch_drawing",
    "textures_particles_blending",
    "textures_polygon_drawing",
    "textures_raw_data",
    "textures_sprite_animation",
    "textures_sprite_button",
    "textures_sprite_explosion",
    "textures_srcrec_dstrec",
    "textures_textured_curve",
    "textures_tiled_drawing",
    "textures_to_image"
];

// Even values are names
// Odd values are entry points
GAMES :: string.[
    "cat_vs_roomba",  "games/cat_vs_roomba/src",
    "snake",          "games/classics/src",
    "space_invaders", "games/classics/src"
];

compile_examples :: (command_options: Command_Options) {
    compile_examples := command_options.compile_audio_examples ||
        command_options.compile_core_examples ||
        command_options.compile_models_examples ||
        command_options.compile_shaders_examples ||
        command_options.compile_shapes_examples ||
        command_options.compile_text_examples ||
        command_options.compile_textures_examples ||
        command_options.compile_specific_examples.count > 0;

    compile_games := command_options.compile_all_games ||
        command_options.compile_specific_games.count > 0;

    if (!compile_examples && compile_games) {
        return;
    }

    print_dotted_line("", "", "-");
    print("Compiling Examples\n");
    print_dotted_line("", "", "-");

    // Compile some examples to make sure the bindings were generated correctly
    if (!compile_examples) {
        if (command_options.build_raygui) {
            compile_file(command_options, "[AUDIO]", "examples/audio", "audio_amp_envelope");
        }
        compile_file(command_options, "[CORE]", "examples/core", "core_basic_window");
        return;
    }

    if (command_options.compile_specific_examples.count > 0) {
        for specific_example: command_options.compile_specific_examples {
            for e: AUDIO_EXAMPLES    if specific_example == e compile_file(command_options, "[AUDIO]",    "examples/audio",    e);
            for e: CORE_EXAMPLES     if specific_example == e compile_file(command_options, "[CORE]",     "examples/core",     e);
            for e: MODELS_EXAMPLES   if specific_example == e compile_file(command_options, "[MODELS]",   "examples/models",   e);
            for e: SHADERS_EXAMPLES  if specific_example == e compile_file(command_options, "[SHADERS]",  "examples/shaders",  e);
            for e: SHAPES_EXAMPLES   if specific_example == e compile_file(command_options, "[SHAPES]",   "examples/shapes",   e);
            for e: TEXT_EXAMPLES     if specific_example == e compile_file(command_options, "[TEXT]",     "examples/text",     e);
            for e: TEXTURES_EXAMPLES if specific_example == e compile_file(command_options, "[TEXTURES]", "examples/textures", e);
        }
        return;
    }

    if (command_options.compile_audio_examples)    for AUDIO_EXAMPLES    compile_file(command_options, "[AUDIO]",    "examples/audio",    it);
    if (command_options.compile_core_examples)     for CORE_EXAMPLES     compile_file(command_options, "[CORE]",     "examples/core",     it);
    if (command_options.compile_models_examples)   for MODELS_EXAMPLES   compile_file(command_options, "[MODELS]",   "examples/models",   it);
    if (command_options.compile_shaders_examples)  for SHADERS_EXAMPLES  compile_file(command_options, "[SHADERS]",  "examples/shaders",  it);
    if (command_options.compile_shapes_examples)   for SHAPES_EXAMPLES   compile_file(command_options, "[SHAPES]",   "examples/shapes",   it);
    if (command_options.compile_text_examples)     for TEXT_EXAMPLES     compile_file(command_options, "[TEXT]",     "examples/text",     it);
    if (command_options.compile_textures_examples) for TEXTURES_EXAMPLES compile_file(command_options, "[TEXTURES]", "examples/textures", it);
}

compile_games :: (command_options: Command_Options) {
    compile_games := command_options.compile_all_games ||
        command_options.compile_specific_games.count > 0;
    if (!compile_games) {
        return;
    }

    print_dotted_line("", "", "-");
    print("Compiling Games\n");
    print_dotted_line("", "", "-");

    if (command_options.compile_specific_games.count > 0) {
        for specific_example: command_options.compile_specific_games {
            for i: 0..GAMES.count-1 {
                defer i += 1;

                if specific_example == GAMES[i] compile_file(command_options, "", GAMES[i + 1], GAMES[i]);
            }
        }
        return;
    }

    for GAMES {
        defer it_index += 1;

        compile_file(command_options, "", GAMES[it_index + 1], GAMES[it_index]);
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