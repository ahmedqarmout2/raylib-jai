/*
******************************************************************************************
*
*   reasings - raylib easings library, based on Robert Penner library
*
*   Useful easing functions for values animation
*
*   This header uses:
*       #define REASINGS_STATIC_INLINE      // Inlines all functions code, so it runs faster.
*                                           // This requires lots of memory on system.
*   How to use:
*   The four inputs t,b,c,d are defined as follows:
*   t = current time (in any unit measure, but same unit as duration)
*   b = starting value to interpolate
*   c = the total change in value of b that needs to occur
*   d = total time it should take to complete (duration)
*
*   Example:
*
*   int currentTime = 0;
*   int duration = 100;
*   float startPositionX = 0.0;
*   float finalPositionX = 30.0;
*   float currentPositionX = startPositionX;
*
*   while (currentPositionX < finalPositionX)
*   {
*       currentPositionX = EaseSineIn(currentTime, startPositionX, finalPositionX - startPositionX, duration);
*       currentTime++;
*   }
*
*   A port of Robert Penner's easing equations to C (http://robertpenner.com/easing/)
*
*   Robert Penner License
*   ---------------------------------------------------------------------------------
*   Open source under the BSD License.
*
*   Copyright (c) 2001 Robert Penner. All rights reserved.
*
*   Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
*       - Redistributions of source code must retain the above copyright notice,
*         this list of conditions and the following disclaimer.
*       - Redistributions in binary form must reproduce the above copyright notice,
*         this list of conditions and the following disclaimer in the documentation
*         and/or other materials provided with the distribution.
*       - Neither the name of the author nor the names of contributors may be used
*         to endorse or promote products derived from this software without specific
*         prior written permission.
*
*   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
*   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
*   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
*   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
*   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
*   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
*   OF THE POSSIBILITY OF SUCH DAMAGE.
*   ---------------------------------------------------------------------------------
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
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
**********************************************************************************************/

// Linear Easing functions
EaseLinearNone :: (t: float, b: float, c: float, d: float) -> float { return (c*t/d + b); }                            // Ease: Linear
EaseLinearIn :: (t: float, b: float, c: float, d: float) -> float { return (c*t/d + b); }                              // Ease: Linear In
EaseLinearOut :: (t: float, b: float, c: float, d: float) -> float { return (c*t/d + b); }                             // Ease: Linear Out
EaseLinearInOut :: (t: float, b: float, c: float, d: float) -> float { return (c*t/d + b); }                           // Ease: Linear In Out

// Sine Easing functions
EaseSineIn :: (t: float, b: float, c: float, d: float) -> float { return (-c*cos(t/d*(PI/2.0)) + c + b); }            // Ease: Sine In
EaseSineOut :: (t: float, b: float, c: float, d: float) -> float { return (c*sin(t/d*(PI/2.0)) + b); }                // Ease: Sine Out
EaseSineInOut :: (t: float, b: float, c: float, d: float) -> float { return (-c/2.0*(cos(PI*t/d) - 1.0) + b); }      // Ease: Sine In Out

// Circular Easing functions
EaseCircIn :: (t: float, b: float, c: float, d: float) -> float { t /= d; return (-c*(sqrt(1.0 - t*t) - 1.0) + b); } // Ease: Circular In
EaseCircOut :: (t: float, b: float, c: float, d: float) -> float { t = t/d - 1.0; return (c*sqrt(1.0 - t*t) + b); }  // Ease: Circular Out
EaseCircInOut :: (t: float, b: float, c: float, d: float) -> float                                                      // Ease: Circular In Out
{
    t/=d/2.0;
    if (t < 1.0) return (-c/2.0*(sqrt(1.0 - t*t) - 1.0) + b);
    t -= 2.0; return (c/2.0*(sqrt(1.0 - t*t) + 1.0) + b);
}

// Cubic Easing functions
EaseCubicIn :: (t: float, b: float, c: float, d: float) -> float { t /= d; return (c*t*t*t + b); }                      // Ease: Cubic In
EaseCubicOut :: (t: float, b: float, c: float, d: float) -> float { t = t/d - 1.0; return (c*(t*t*t + 1.0) + b); }    // Ease: Cubic Out
EaseCubicInOut :: (t: float, b: float, c: float, d: float) -> float                                                     // Ease: Cubic In Out
{
    t/=d/2.0;
    if (t < 1.0) return (c/2.0*t*t*t + b);
    t -= 2.0; return (c/2.0*(t*t*t + 2.0) + b);
}

// Quadratic Easing functions
EaseQuadIn :: (t: float, b: float, c: float, d: float) -> float { t /= d; return (c*t*t + b); }                         // Ease: Quadratic In
EaseQuadOut :: (t: float, b: float, c: float, d: float) -> float { t /= d; return (-c*t*(t - 2.0) + b); }              // Ease: Quadratic Out
EaseQuadInOut :: (t: float, b: float, c: float, d: float) -> float                                                      // Ease: Quadratic In Out
{
    t/=d/2;
    if (t < 1) return (((c/2)*(t*t)) + b);
    return (-c/2.0*(((t - 1.0)*(t - 3.0)) - 1.0) + b);
}

// Exponential Easing functions
EaseExpoIn :: (t: float, b: float, c: float, d: float) -> float { return ifx (t == 0.0) then b else (c*pow(2.0, 10.0*(t/d - 1.0)) + b); }       // Ease: Exponential In
EaseExpoOut :: (t: float, b: float, c: float, d: float) -> float { return ifx (t == d) then (b + c) else (c*(-pow(2.0, -10.0*t/d) + 1.0) + b); } // Ease: Exponential Out
EaseExpoInOut :: (t: float, b: float, c: float, d: float) -> float                                                                         // Ease: Exponential In Out
{
    if (t == 0.0) return b;
    if (t == d) return (b + c);
    t/=d/2.0;
    if (t < 1.0) return (c/2.0*pow(2.0, 10.0*(t - 1.0)) + b);

    return (c/2.0*(-pow(2.0, -10.0*(t - 1.0)) + 2.0) + b);
}

// Back Easing functions
EaseBackIn :: (t: float, b: float, c: float, d: float) -> float // Ease: Back In
{
    s: float = 1.70158;
    t/=d;
    postFix: float = t;
    return (c*(postFix)*t*((s + 1.0)*t - s) + b);
}

EaseBackOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Back Out
{
    s: float = 1.70158;
    t = t/d - 1.0;
    return (c*(t*t*((s + 1.0)*t + s) + 1.0) + b);
}

EaseBackInOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Back In Out
{
    s: float = 1.70158;
    t/=d/2.0;
    if (t < 1.0)
    {
        s *= 1.525;
        return (c/2.0*(t*t*((s + 1.0)*t - s)) + b);
    }

    t-=2.0;
    postFix: float = t;
    s *= 1.525;
    return (c/2.0*((postFix)*t*((s + 1.0)*t + s) + 2.0) + b);
}

// Bounce Easing functions
EaseBounceOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Bounce Out
{
    t/=d;
    if (t < (1.0/2.75))
    {
        return (c*(7.5625*t*t) + b);
    }
    else if (t < (2.0/2.75))
    {
        t-=(1.5/2.75);
        postFix: float = t;
        return (c*(7.5625*(postFix)*t + 0.75) + b);
    }
    else if (t < (2.5/2.75))
    {
        t-=(2.25/2.75);
        postFix: float = t;
        return (c*(7.5625*(postFix)*t + 0.9375) + b);
    }
    else
    {
        t-=(2.625/2.75);
        postFix: float = t;
        return (c*(7.5625*(postFix)*t + 0.984375) + b);
    }
}

EaseBounceIn :: (t: float, b: float, c: float, d: float) -> float { return (c - EaseBounceOut(d - t, 0.0, c, d) + b); } // Ease: Bounce In
EaseBounceInOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Bounce In Out
{
    if (t < d/2.0) return (EaseBounceIn(t*2.0, 0.0, c, d)*0.5 + b);
    else return (EaseBounceOut(t*2.0 - d, 0.0, c, d)*0.5 + c*0.5 + b);
}

// Elastic Easing functions
EaseElasticIn :: (t: float, b: float, c: float, d: float) -> float // Ease: Elastic In
{
    if (t == 0.0) return b;
    t/=d;
    if (t == 1.0) return (b + c);

    p: float = d*0.3;
    a: float = c;
    s: float = p/4.0;
    t-=1.0;
    postFix: float = a*pow(2.0, 10.0*t);

    return (-(postFix*sin((t*d-s)*(2.0*PI)/p )) + b);
}

EaseElasticOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Elastic Out
{
    if (t == 0.0) return b;

    t/=d;
    if (t == 1.0) return (b + c);

    p: float = d*0.3;
    a: float = c;
    s: float = p/4.0;

    return (a*pow(2.0,-10.0*t)*sin((t*d-s)*(2.0*PI)/p) + c + b);
}

EaseElasticInOut :: (t: float, b: float, c: float, d: float) -> float // Ease: Elastic In Out
{
    if (t == 0.0) return b;
    t/=d/2.0;
    if (t == 2.0) return (b + c);

    p: float = d*(0.3*1.5);
    a: float = c;
    s: float = p/4.0;

    if (t < 1.0)
    {
        t-=1.0;
        postFix: float = a*pow(2.0, 10.0*t);
        return -0.5*(postFix*sin((t*d-s)*(2.0*PI)/p)) + b;
    }

    t-=1.0;
    postFix: float = a*pow(2.0, -10.0*t);

    return (postFix*sin((t*d-s)*(2.0*PI)/p)*0.5 + c + b);
}
