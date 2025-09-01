/*
*********************************************************************************************
*
*   raylib - Advance Game template
*
*   Logo Screen Functions Definitions (Init, Update, Draw, Unload)
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************
*/

//----------------------------------------------------------------------------------
// Module Variables Definition (local)
//----------------------------------------------------------------------------------
sl_framesCounter : s32 = 0;
sl_finishScreen : s32 = 0;

logoPositionX : s32 = 0;
logoPositionY : s32 = 0;

lettersCount : s32 = 0;

topSideRecWidth : s32 = 0;
leftSideRecHeight : s32 = 0;

bottomSideRecWidth : s32 = 0;
rightSideRecHeight : s32 = 0;

sl_state : s32 = 0;              // Logo animation sl_states
alpha := 1.0;         // Useful for fading

//----------------------------------------------------------------------------------
// Logo Screen Functions Definition
//----------------------------------------------------------------------------------

// Logo Screen Initialization logic
InitLogoScreen :: ()
{
    sl_finishScreen = 0;
    sl_framesCounter = 0;
    lettersCount = 0;

    logoPositionX = GetScreenWidth()/2 - 128;
    logoPositionY = GetScreenHeight()/2 - 128;

    topSideRecWidth = 16;
    leftSideRecHeight = 16;
    bottomSideRecWidth = 16;
    rightSideRecHeight = 16;

    sl_state = 0;
    alpha = 1.0;
}

// Logo Screen Update logic
UpdateLogoScreen :: ()
{
    if (sl_state == 0)                 // sl_state 0: Top-left square corner blink logic
    {
        sl_framesCounter += 1;

        if (sl_framesCounter == 80)
        {
            sl_state = 1;
            sl_framesCounter = 0;      // Reset counter... will be used later...
        }
    }
    else if (sl_state == 1)            // sl_state 1: Bars animation logic: top and left
    {
        topSideRecWidth += 8;
        leftSideRecHeight += 8;

        if (topSideRecWidth == 256) sl_state = 2;
    }
    else if (sl_state == 2)            // sl_state 2: Bars animation logic: bottom and right
    {
        bottomSideRecWidth += 8;
        rightSideRecHeight += 8;

        if (bottomSideRecWidth == 256) sl_state = 3;
    }
    else if (sl_state == 3)            // sl_state 3: "raylib" text-write animation logic
    {
        sl_framesCounter += 1;

        if (lettersCount < 10)
        {
            if (sl_framesCounter/12)   // Every 12 frames, one more letter!
            {
                lettersCount += 1;
                sl_framesCounter = 0;
            }
        }
        else    // When all letters have appeared, just fade out everything
        {
            if (sl_framesCounter > 200)
            {
                alpha -= 0.02;

                if (alpha <= 0.0)
                {
                    alpha = 0.0;
                    sl_finishScreen = 1;   // Jump to next screen
                }
            }
        }
    }
}

// Logo Screen Draw logic
DrawLogoScreen :: ()
{
    if (sl_state == 0)         // Draw blinking top-left square corner
    {
        if ((sl_framesCounter/10)%2) DrawRectangle(logoPositionX, logoPositionY, 16, 16, BLACK);
    }
    else if (sl_state == 1)    // Draw bars animation: top and left
    {
        DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK);
        DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK);
    }
    else if (sl_state == 2)    // Draw bars animation: bottom and right
    {
        DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK);
        DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK);

        DrawRectangle(logoPositionX + 240, logoPositionY, 16, rightSideRecHeight, BLACK);
        DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, BLACK);
    }
    else if (sl_state == 3)    // Draw "raylib" text-write animation + "powered by"
    {
        DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, Fade(BLACK, alpha));
        DrawRectangle(logoPositionX, logoPositionY + 16, 16, leftSideRecHeight - 32, Fade(BLACK, alpha));

        DrawRectangle(logoPositionX + 240, logoPositionY + 16, 16, rightSideRecHeight - 32, Fade(BLACK, alpha));
        DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, Fade(BLACK, alpha));

        DrawRectangle(GetScreenWidth()/2 - 112, GetScreenHeight()/2 - 112, 224, 224, Fade(RAYWHITE, alpha));

        DrawText(TextSubtext("raylib", 0, lettersCount), GetScreenWidth()/2 - 44, GetScreenHeight()/2 + 48, 50, Fade(BLACK, alpha));

        if (sl_framesCounter > 20) DrawText("powered by", logoPositionX, logoPositionY - 27, 20, Fade(DARKGRAY, alpha));
    }
}

// Logo Screen Unload logic
UnloadLogoScreen :: ()
{
    // Unload LOGO screen variables here!
}

// Logo Screen should finish?
FinishLogoScreen :: () -> s32
{
    return sl_finishScreen;
}