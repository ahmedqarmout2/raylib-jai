/*
*********************************************************************************************
*
*   raylib - Advance Game template
*
*   Title Screen Functions Definitions (Init, Update, Draw, Unload)
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applist_cations, and to alter it and redistribute it freely, subject to the following restrictions:
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
st_framesCounter : s32 = 0;
st_finishScreen : s32 = 0;
st_state : s32 = 0;

st_scrollPositionX : s32 = 0;

st_catPosX : s32 = 0;
st_roombaPosX : s32 = 0;

vsAlpha := 0.0;
vsScale := 0.0;

st_cat: Texture2D;
vs: Texture2D;
st_roomba: Texture2D;

//----------------------------------------------------------------------------------
// Title Screen Functions Definition
//----------------------------------------------------------------------------------

// Title Screen Initialization logic
InitTitleScreen :: ()
{
    // TODO: Initialize TITLE screen variables here!
    st_framesCounter = 0;
    st_finishScreen = 0;

    st_cat = LoadTexture("resources/title_cat.png");
    vs = LoadTexture("resources/title_vs.png");
    st_roomba = LoadTexture("resources/title_roomba.png");

    st_state = 0;
    st_catPosX = 1760;
    st_roombaPosX = -700;
    st_scrollPositionX = 0;

    vsAlpha = 0.0;
    vsScale = 10.0;

    PlayMusicStream(music);
}

// Title Screen Update logic
UpdateTitleScreen :: ()
{
    st_scrollPositionX -= 5;
    if (st_scrollPositionX < -GetScreenWidth()) st_scrollPositionX = 0;

    if (st_state == 0)
    {
        st_catPosX -= 4;
        st_roombaPosX += 3;

        if (st_catPosX < (GetScreenWidth()/2 - st_cat.width/2)) st_catPosX = (GetScreenWidth()/2 - st_cat.width/2);
        if (st_roombaPosX > (GetScreenWidth()/2 - st_roomba.width/2)) st_roombaPosX = (GetScreenWidth()/2 - st_roomba.width/2);

        if ((st_catPosX == (GetScreenWidth()/2 - st_cat.width/2)) && (st_roombaPosX == (GetScreenWidth()/2 - st_roomba.width/2)))
        {
            st_state = 1;
            st_framesCounter = 0;
        }
    }
    else if (st_state == 1)
    {
        st_framesCounter += 1;

        vsScale -= 0.1;
        vsAlpha += 0.01;

        if (vsScale < 1.0) vsScale = 1.0;
        if (vsAlpha > 1.0) vsAlpha = 1.0;

        if (st_framesCounter > 160)
        {
            st_state = 2;
            st_framesCounter = 0;
        }
    }
    else if (st_state == 2) st_framesCounter += 1;

    // Press enter or tap to change to GAMEPLAY screen
    if (IsKeyPressed(.KEY_ENTER) || IsGestureDetected(.GESTURE_TAP))
    {
        //st_finishScreen = 1;   // OPTIONS
        st_finishScreen = 2;   // GAMEPLAY
        PlaySound(fxCoin);
    }
}

// Title Screen Draw logic
DrawTitleScreen :: ()
{
    for i: 0..64*2*2-1
    {
        DrawRectangle(64*cast(s32)i + st_scrollPositionX, 0, 64, GetScreenHeight(), ifx (i%2 == 0) then GetColor(0xf3726dff) else GetColor(0xffcf6bff));
    }

    DrawTexture(st_cat, st_catPosX, 80, WHITE);
    DrawTexture(st_roomba, st_roombaPosX, 320, WHITE);

    if (st_state > 0)
    {
        DrawTexturePro(vs, Rectangle.{ 0, 0, 1.0 * vs.width, 1.0 * vs.height }, Rectangle.{ 1.0 *  GetScreenWidth()/2, 300, vs.width*vsScale, vs.height*vsScale }, Vector2.{ vs.width/2*vsScale, vs.height/2*vsScale }, 0.0, Fade(WHITE, vsAlpha));
    }

    if ((st_state == 2) && ((st_framesCounter/30)%2)) DrawTextEx(font2, "PRESS ENTER to START", Vector2.{ 340, 550 }, 1.0 * font2.baseSize, 2, WHITE);
}

// Title Screen Unload logic
UnloadTitleScreen :: ()
{
    UnloadTexture(st_cat);
    UnloadTexture(vs);
    UnloadTexture(st_roomba);
}

// Title Screen should finish?
FinishTitleScreen :: () -> s32
{
    return st_finishScreen;
}