# raylib-jai bindings

[Raylib](https://www.raylib.com/) is a minimal gamedev library for C and this repository has a script for automatically generating Jai bindings from `raylib.h`, `raymath.h`, `rcamera.h`, `rlgl.h` and `raygui.h`.

> Tested with Jai version: beta 0.2.017

> Raylib version: 5.5

> Raygui version: 4.5-dev
 
There are also examples--direct Jai ports of the [raylib examples](https://www.raylib.com/examples.html).

<a href="examples/core/core_3d_camera_first_person.jai"><img src="doc/screenshots/core_3d_camera_first_person.png" style="max-width: 400px;"></a>
<a href="examples/models/models_heightmap.jai"><img src="doc/screenshots/models_heightmap.png" style="max-width: 400px;"></a>
<a href="examples/shaders/shaders_custom_uniform.jai"><img src="doc/screenshots/shaders_custom_uniform.png" style="max-width: 400px;"></a>
<a href="examples/shaders/shaders_texture_waves.jai"><img src="doc/screenshots/shaders_texture_waves.png" style="max-width: 400px;"></a>
<a href="examples/shapes/shapes_collision_area.jai"><img src="doc/screenshots/shapes_collision_area.png" style="max-width: 400px;"></a>
<a href="examples/shapes/shapes_colors_palette.jai"><img src="doc/screenshots/shapes_colors_palette.png" style="max-width: 400px;"></a>
<a href="examples/shapes/shapes_draw_ring.jai"><img src="doc/screenshots/shapes_draw_ring.png" style="max-width: 400px;"></a>
<a href="examples/shapes/shapes_splines_drawing.jai"><img src="doc/screenshots/shapes_splines_drawing.png" style="max-width: 400px;"></a>
<a href="examples/textures_bunnymark.jai"><img src="doc/screenshots/textures_bunnymark.png" style="max-width: 400px;"></a>

There are more than shown here ported in the [examples/](examples) folder.


## Minimal example
Copy raylib directory into your libs directory. For example:
```
my_game/

.... libs/

.... .... raylib

.... main.jai
```

```
// main.jai
#import "raylib";

main :: () {
    InitWindow(800, 450, "raylib example");
    defer CloseWindow();

    while !WindowShouldClose() {
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);
        DrawText("raylib + jai", 190, 200, 20, LIGHTGRAY);
    }
}
```

> Compile using (on Windows): jai -import_dir .\libs .\main.jai


## Building the examples

Run `compile_examples.bat` with `jai` on your PATH.

Run the example `.exe` files from the `examples/` directory.


## Features

* Windows, linux and macos support

* Raygui support

* Some functions which take enum arguments (like `SetConfigFlags` for example) have their argument types changed from C's `int` (or Jai's `s32`) to the actual enum type. Consequently, you can call them like `SetConfigFlags(.FLAG_FULLSCREEN_MODE);`

* An additional set of macros lets you change any of the Begin/End function call pairs (like `BeginMode3D(camera)` and `EndMode3D()`) into an equivalent `PushMode3D(camera)` which will insert an automatic `defer EndXXX()` call into the scope for you.


## Regenerating the bindings

> Compile and run: generate.jai

For example (on Windows):

> jai .\generate.jai

> .\generate.exe
