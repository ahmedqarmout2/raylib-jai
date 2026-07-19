#if OS == .WINDOWS {
    user32  :: #library,system,link_always "user32";
    gdi32   :: #library,system,link_always "gdi32";
    shell32 :: #library,system,link_always "shell32";
    winmm   :: #library,system,link_always "winmm";

    raylib_native :: #library,no_dll "lib/windows/raylib";
    raygui_native :: #library,no_dll "lib/windows/raygui";
}

#if OS == .LINUX {
    libm :: #library,system,link_always "libm";
    x11  :: #library,system,link_always "X11";

    raylib_native :: #library,no_dll "lib/linux/raylib";
    raygui_native :: #library,no_dll "lib/linux/raygui";
}

#if OS == .MACOS {
    cocoa :: #library,system,link_always "Cocoa";
    iOKit :: #library,system,link_always "IOKit";

    raylib_native :: #library,no_dll "lib/macos/raylib";
    raygui_native :: #library,no_dll "lib/macos/raygui";
}

#import "Basic";
#import "Math";

#load "raylib.jai";
#load "raymath.jai";
#load "rlgl.jai";
#load "rcamera.jai";
#load "raygui.jai";
#load "reasings.jai";

// Additional functionality
#load "extra.jai";