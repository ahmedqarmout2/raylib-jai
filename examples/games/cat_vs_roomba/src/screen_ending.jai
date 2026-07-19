/*
*********************************************************************************************
*
*   raylib - Advance Game template
*
*   Ending Screen Functions Definitions (Init, Update, Draw, Unload)
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
se_framesCounter: s32 = 0;
se_finishScreen: s32 = 0;

se_scrollPositionX: s32 = 0;

//----------------------------------------------------------------------------------
// Ending Screen Functions Definition
//----------------------------------------------------------------------------------

// Ending Screen Initialization logic
InitEndingScreen :: ()
{
    // TODO: Initialize ENDING screen variables here!
    se_framesCounter = 0;
    se_finishScreen = 0;

    PlayMusicStream(music);
}

// Ending Screen Update logic
UpdateEndingScreen :: ()
{
    se_framesCounter += 1;

    se_scrollPositionX -= 5;
    if (se_scrollPositionX < -GetScreenWidth()) se_scrollPositionX = 0;

    // Press enter or tap to return to TITLE screen
    if (IsKeyPressed(.KEY_ENTER) || IsGestureDetected(.GESTURE_TAP))
    {
        se_finishScreen = 1;
        PlaySound(fxCoin);
    }
}

// Ending Screen Draw logic
DrawEndingScreen :: ()
{
    for i: 0..64*2*2-1
    {
        DrawRectangle(cast(s32)(64*i + se_scrollPositionX), 0, 64, GetScreenHeight(), ifx (i%2 == 0) then GetColor(0xf3726dff) else GetColor(0xffcf6bff));
    }

    if (result == 0) DrawTextEx(font2, "YOU LOOSE...", Vector2.{ 350, 200 }, font2.baseSize*2.0, 2, WHITE);
    else if (result == 1) DrawTextEx(font, "YOU WIN!!!", Vector2.{ 380, 200 }, font.baseSize*2.0, 2, WHITE);

    // Draw score
    DrawTextEx(font, TextFormat("FINAL SCORE: %i", score), Vector2.{ 400, 360 }, font2.baseSize*1.0, 2, WHITE);

    if ((se_framesCounter/30)%2) DrawTextEx(font2, "PRESS ENTER to TITLE", Vector2.{ 340, 550 }, font2.baseSize*1.0, 2, WHITE);
}

// Ending Screen Unload logic
UnloadEndingScreen :: ()
{
    // TODO: Unload ENDING screen variables here!
}

// Ending Screen should finish?
FinishEndingScreen :: () -> s32
{
    return se_finishScreen;
}