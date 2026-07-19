/*
*******************************************************************************************
*
*   CAT VS ROOMBA [GLOBAL GAME JAM 2019]
*
*   Ah! Home, sweet home! Time for some automatic cleaning...
*   if the worst enemy of Roomba allows it... be careful with Cat!
*
*   This game has been created using raylib 2.0 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2019 Ramon Santamaria (@raysan5)
*
*******************************************************************************************
*/

#import "raylib";

#import "Basic";
#import "File";
#import "Math";
#import "String";

#load "screen_ending.jai";
#load "screen_gameplay.jai";
#load "screen_logo.jai";
#load "screen_title.jai";

//----------------------------------------------------------------------------------
// Shared Variables Definition (global)
//----------------------------------------------------------------------------------
GameScreen :: enum {
    LOGO;
    TITLE;
    OPTIONS;
    GAMEPLAY;
    ENDING;
};

currentScreen: GameScreen = .LOGO;
font   : Font;
font2  : Font;
music  : Music;
fxCoin : Sound;
score  : s32 = 0;
result : s32 = -1;      // 0-Loose, 1-Win

//----------------------------------------------------------------------------------
// Module Variables Definition (local)
//----------------------------------------------------------------------------------
screenWidth : s32 : 1280;

TILE_VIEWER_MODE :: false;
#if TILE_VIEWER_MODE screenHeight : s32 : 1080; else screenHeight : s32 : 720;

// Required variables to manage screen transitions (fade-in, fade-out)
transAlpha   := 0.0;
onTransition := false;
transFadeOut := false;
transFromScreen : GameScreen = .LOGO;
transToScreen   : GameScreen = .LOGO;

main :: () {
    set_working_directory(#filepath);

    // Initialization (Note windowTitle is unused on Android)
    //---------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "CAT VS ROOMBA [GGJ19]");

    // Global data loading (assets that must be available in all screens, i.e. fonts)
    InitAudioDevice();

    font   = LoadFont("resources/star.fnt");
    font2  = LoadFont("resources/star2.fnt");
    music  = LoadMusicStream("resources/cat_mouse.mod");
    fxCoin = LoadSound("resources/coin.wav");

    SetMusicVolume(music, 1.0);
    PlayMusicStream(music);

    // Setup and Init first screen
    currentScreen = .LOGO;
    InitLogoScreen();

    SetTargetFPS(60);   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        UpdateDrawFrame();
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    // Unload current screen data before closing
    if currentScreen == {
        case .LOGO    ; UnloadLogoScreen();
        case .TITLE   ; UnloadTitleScreen();
        case .GAMEPLAY; UnloadGameplayScreen();
        case .ENDING  ; UnloadEndingScreen();
    }

    // Unload all global loaded data (i.e. fonts) here!
    UnloadFont(font);
    UnloadFont(font2);
    UnloadMusicStream(music);
    UnloadSound(fxCoin);

    CloseAudioDevice();     // Close audio context

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}


//----------------------------------------------------------------------------------
// Module Functions Definition (local)
//----------------------------------------------------------------------------------
// Change to screen, no transition
ChangeToScreen :: (screen: GameScreen)
{
    // Unload current screen
    if currentScreen == {
        case .LOGO; UnloadLogoScreen();
        case .TITLE; UnloadTitleScreen();
        case .GAMEPLAY; UnloadGameplayScreen();
        case .ENDING; UnloadEndingScreen();
    }

    // Init next screen
    if screen == {
        case .LOGO; InitLogoScreen();
        case .TITLE; InitTitleScreen();
        case .GAMEPLAY; InitGameplayScreen();
        case .ENDING; InitEndingScreen();
    }

    currentScreen = screen;
}

// Request transition to next screen
TransitionToScreen :: (screen: GameScreen)
{
    onTransition = true;
    transFadeOut = false;
    transFromScreen = currentScreen;
    transToScreen = screen;
    transAlpha = 0.0;
}

// Update transition effect
UpdateTransition :: ()
{
    if (!transFadeOut)
    {
        transAlpha += 0.02;

        // NOTE: Due to float internal representation, condition jumps on 1.0f instead of 1.05f
        // For that reason we compare against 1.01f, to avoid last frame loading stop
        if (transAlpha > 1.01)
        {
            transAlpha = 1.0;

            // Unload current screen
            if transFromScreen == {
                case .LOGO; UnloadLogoScreen();
                case .TITLE; UnloadTitleScreen();
                case .GAMEPLAY; UnloadGameplayScreen();
                case .ENDING; UnloadEndingScreen();
            }

            // Load next screen
            if transToScreen == {
                case .LOGO; InitLogoScreen();
                case .TITLE; InitTitleScreen();
                case .GAMEPLAY; InitGameplayScreen();
                case .ENDING; InitEndingScreen();
            }

            currentScreen = transToScreen;

            // Activate fade out effect to next loaded screen
            transFadeOut = true;
        }
    }
    else  // Transition fade out logic
    {
        transAlpha -= 0.02;

        if (transAlpha < -0.01)
        {
            transAlpha = 0.0;
            transFadeOut = false;
            onTransition = false;
            transFromScreen = -1;
            transToScreen = -1;
        }
    }
}

// Draw transition effect (full-screen rectangle)
DrawTransition :: ()
{
    DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(BLACK, transAlpha));
}

// Update and draw game frame
UpdateDrawFrame :: ()
{
    // Update
    //----------------------------------------------------------------------------------
    UpdateMusicStream(music);       // NOTE: Music keeps playing between screens

    if (!onTransition)
    {
        if currentScreen == {
            case .LOGO;
            {
                UpdateLogoScreen();

                if (FinishLogoScreen()) TransitionToScreen(.TITLE);

            }
            case .TITLE;
            {
                UpdateTitleScreen();

                if (FinishTitleScreen() == 1) TransitionToScreen(.OPTIONS);
                else if (FinishTitleScreen() == 2) TransitionToScreen(.GAMEPLAY);

            }
            case .GAMEPLAY;
            {
                UpdateGameplayScreen();

                if (FinishGameplayScreen() == 1) TransitionToScreen(.ENDING);
                //else if (FinishGameplayScreen() == 2) TransitionToScreen(TITLE);

            }
            case .ENDING;
            {
                UpdateEndingScreen();

                if (FinishEndingScreen() == 1) TransitionToScreen(.TITLE);

            }
        }
    }
    else UpdateTransition();    // Update transition (fade-in, fade-out)
    //----------------------------------------------------------------------------------

    // Draw
    //----------------------------------------------------------------------------------
    BeginDrawing();

        ClearBackground(RAYWHITE);

        if currentScreen == {
            case .LOGO; DrawLogoScreen();
            case .TITLE; DrawTitleScreen();
            case .GAMEPLAY; DrawGameplayScreen();
            case .ENDING; DrawEndingScreen();
        }

        // Draw full screen rectangle in front of everything
        if (onTransition) DrawTransition();

    EndDrawing();
    //----------------------------------------------------------------------------------
}
