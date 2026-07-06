#import "raylib";
#import "Basic";
#import "Math";

MONO                          :: 1;
SAMPLE_RATE                   :: 44100;
SAMPLE_RATE_F                 :: 44100.0;
FFT_WINDOW_SIZE               :: 1024;
BUFFER_SIZE                   :: 512;
PER_SAMPLE_BIT_DEPTH          :: 16;
AUDIO_STREAM_RING_BUFFER_SIZE :: (FFT_WINDOW_SIZE*2);
EFFECTIVE_SAMPLE_RATE         :: (SAMPLE_RATE_F*0.5);
WINDOW_TIME                   :: (cast(float64)FFT_WINDOW_SIZE/cast(float64)EFFECTIVE_SAMPLE_RATE);
FFT_HISTORICAL_SMOOTHING_DUR  :: 2.0;
MIN_DECIBELS                  :: (-100.0); // https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/minDecibels
MAX_DECIBELS                  :: (-30.0);  // https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/maxDecibels
INVERSE_DECIBEL_RANGE         :: (1.0/(MAX_DECIBELS - MIN_DECIBELS));
DB_TO_LINEAR_SCALE            :: (20.0/2.302585092994046);
SMOOTHING_TIME_CONSTANT       :: 0.8; // https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/smoothingTimeConstant
TEXTURE_HEIGHT                :: 1;
FFT_ROW                       :: 0;
UNUSED_CHANNEL                :: 0.0;

FFTComplex :: struct { 
    real: float;
    imaginary: float;
};

FFTData :: struct {
    spectrum: [..]FFTComplex;
    workBuffer: [..]FFTComplex;
    prevMagnitudes: [..]float;
    fftHistory: [..][BUFFER_SIZE]float;
    fftHistoryLen: s32;
    historyPos: s32;
    lastFftTime: float64;
    tapbackPos: float;
};

GLSL_VERSION :: 330;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - spectrum visualizer");

    fftImage: Image = GenImageColor(BUFFER_SIZE, TEXTURE_HEIGHT, WHITE);
    fftTexture: Texture2D = LoadTextureFromImage(fftImage);
    bufferA: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);
    iResolution := Vector2.{ cast(float)screenWidth, cast(float)screenHeight };

    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/fft.fs", GLSL_VERSION));

    iResolutionLocation: s32 = GetShaderLocation(shader, "iResolution");
    iChannel0Location: s32 = GetShaderLocation(shader, "iChannel0");
    SetShaderValue(shader, iResolutionLocation, *iResolution, .SHADER_UNIFORM_VEC2);
    SetShaderValueTexture(shader, iChannel0Location, fftTexture);

    InitAudioDevice();
    SetAudioStreamBufferSizeDefault(AUDIO_STREAM_RING_BUFFER_SIZE);

    // WARNING: Memory out-of-bounds on PLATFORM_WEB
    wav: Wave = LoadWave("resources/country.mp3");
    WaveFormat(*wav, SAMPLE_RATE, PER_SAMPLE_BIT_DEPTH, MONO);

    audioStream: AudioStream = LoadAudioStream(SAMPLE_RATE, PER_SAMPLE_BIT_DEPTH, MONO);
    PlayAudioStream(audioStream);

    fftHistoryLen: s32 = cast(s32)ceil(FFT_HISTORICAL_SMOOTHING_DUR/WINDOW_TIME) + 1;

    fft: FFTData;
    array_resize(*fft.spectrum, FFT_WINDOW_SIZE);
    array_resize(*fft.workBuffer, FFT_WINDOW_SIZE);
    array_resize(*fft.prevMagnitudes, BUFFER_SIZE);
    array_resize(*fft.fftHistory, fftHistoryLen);
    fft.fftHistoryLen = fftHistoryLen;
    fft.historyPos = 0;
    fft.lastFftTime = 0.0;
    fft.tapbackPos = 0.01;

    wavCursor: u32 = 0;
    wavPCM16: *s16 = wav.data;

    chunkSamples: [AUDIO_STREAM_RING_BUFFER_SIZE]s16;
    audioSamples: [FFT_WINDOW_SIZE]float;

    SetTargetFPS(60);
    //----------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        while (IsAudioStreamProcessed(audioStream))
        {
            for i: 0..AUDIO_STREAM_RING_BUFFER_SIZE-1
            {
                left: s32 = ifx (wav.channels == 2) then wavPCM16[wavCursor*2 + 0] else wavPCM16[wavCursor];
                right: s32 = ifx (wav.channels == 2) then wavPCM16[wavCursor*2 + 1] else left;
                chunkSamples[i] = cast(s16)((left + right)/2);

                wavCursor += 1;
                if (wavCursor >= wav.frameCount) wavCursor = 0;
            }

            UpdateAudioStream(audioStream, chunkSamples.data, AUDIO_STREAM_RING_BUFFER_SIZE);

            for i: 0..FFT_WINDOW_SIZE-1 audioSamples[i] = (chunkSamples[i*2] + chunkSamples[i*2 + 1])*0.5/32767.0;
        }

        CaptureFrame(*fft, audioSamples);
        RenderFrame(*fft, *fftImage);
        UpdateTexture(fftTexture, fftImage.data);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginShaderMode(shader);
                SetShaderValueTexture(shader, iChannel0Location, fftTexture);
                DrawTextureRec(bufferA.texture,
                    Rectangle.{ 0, 0, cast(float)screenWidth, cast(float)-screenHeight },
                    Vector2.{ 0, 0 }, WHITE);
            EndShaderMode();

        EndDrawing();
        //------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);
    UnloadRenderTexture(bufferA);
    UnloadTexture(fftTexture);
    UnloadImage(fftImage);
    UnloadAudioStream(audioStream);
    UnloadWave(wav);
    CloseAudioDevice();

    array_free(fft.spectrum);
    array_free(fft.workBuffer);
    array_free(fft.prevMagnitudes);
    array_free(fft.fftHistory);

    CloseWindow();        // Close window and OpenGL context
    //----------------------------------------------------------------------------------
}

// Cooley–Tukey FFT https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm#Data_reordering,_bit_reversal,_and_in-place_algorithms
CooleyTukeyFFTSlow :: (spectrum: []FFTComplex, n: s32)
{
    j: s32 = 0;
    for i: 1..n - 2
    {
        bit: s32 = n >> 1;
        while (j >= bit)
        {
            j -= bit;
            bit >>= 1;
        }
        j += bit;
        if (i < j)
        {
            temp: FFTComplex = spectrum[i];
            spectrum[i] = spectrum[j];
            spectrum[j] = temp;
        }
    }

    len: s32 = 2;
    while (len <= n)
    {
        defer len <<= 1;

        angle: float = -2.0*PI/len;
        twiddleUnit := FFTComplex.{ cos(angle), sin(angle) };
        
        i: s32 = 0;
        while (i < n)
        {
            defer i += len;

            twiddleCurrent := FFTComplex.{ 1.0, 0.0 };
            
            j: s32 = 0;
            while (j < len/2)
            {
                defer j += 1;

                even: FFTComplex = spectrum[i + j];
                odd: FFTComplex = spectrum[i + j + len/2];
                twiddledOdd: FFTComplex = FFTComplex.{
                    odd.real*twiddleCurrent.real - odd.imaginary*twiddleCurrent.imaginary,
                    odd.real*twiddleCurrent.imaginary + odd.imaginary*twiddleCurrent.real
                };

                spectrum[i + j].real = even.real + twiddledOdd.real;
                spectrum[i + j].imaginary = even.imaginary + twiddledOdd.imaginary;
                spectrum[i + j + len/2].real = even.real - twiddledOdd.real;
                spectrum[i + j + len/2].imaginary = even.imaginary - twiddledOdd.imaginary;

                twiddleRealNext: float = twiddleCurrent.real*twiddleUnit.real - twiddleCurrent.imaginary*twiddleUnit.imaginary;
                twiddleCurrent.imaginary = twiddleCurrent.real*twiddleUnit.imaginary + twiddleCurrent.imaginary*twiddleUnit.real;
                twiddleCurrent.real = twiddleRealNext;
            }
        }
    }
}

CaptureFrame :: (fftData: *FFTData, audioSamples: []float)
{
    for i: 0..FFT_WINDOW_SIZE-1
    {
        x: float = (2.0*PI*i)/(FFT_WINDOW_SIZE - 1.0);
        blackmanWeight: float = 0.42 - 0.5*cos(x) + 0.08*cos(2.0*x); // https://en.wikipedia.org/wiki/Window_function#Blackman_window
        fftData.workBuffer[i].real = audioSamples[i]*blackmanWeight;
        fftData.workBuffer[i].imaginary = 0.0;
    }

    CooleyTukeyFFTSlow(fftData.workBuffer, FFT_WINDOW_SIZE);
    memcpy(fftData.spectrum.data, fftData.workBuffer.data, FFT_WINDOW_SIZE);

    smoothedSpectrum: [BUFFER_SIZE]float;

    for bin: 0..BUFFER_SIZE-1
    {
        re: float = fftData.workBuffer[bin].real;
        im: float = fftData.workBuffer[bin].imaginary;
        linearMagnitude: float = sqrt(re*re + im*im)/FFT_WINDOW_SIZE;

        smoothedMagnitude: float = SMOOTHING_TIME_CONSTANT*fftData.prevMagnitudes[bin] + (1.0 - SMOOTHING_TIME_CONSTANT)*linearMagnitude;
        fftData.prevMagnitudes[bin] = smoothedMagnitude;

        db: float = cast(float)(log(max(smoothedMagnitude, 10^-40))*DB_TO_LINEAR_SCALE);
        normalized: float = (db - MIN_DECIBELS)*INVERSE_DECIBEL_RANGE;
        smoothedSpectrum[bin] = Clamp(normalized, 0.0, 1.0);
    }

    fftData.lastFftTime = GetTime();
    memcpy(fftData.fftHistory[fftData.historyPos].data, smoothedSpectrum.data, size_of(float) * smoothedSpectrum.count);
    fftData.historyPos = (fftData.historyPos + 1)%fftData.fftHistoryLen;
}

RenderFrame :: (fftData: *FFTData, fftImage: *Image)
{
    framesSinceTapback: float = floor(cast(float)(fftData.tapbackPos/WINDOW_TIME));
    framesSinceTapback = Clamp(framesSinceTapback, 0.0, cast(float)(fftData.fftHistoryLen - 1));

    historyPosition: s32 = (fftData.historyPos - 1 - cast(s32)framesSinceTapback)%fftData.fftHistoryLen;
    if (historyPosition < 0) historyPosition += fftData.fftHistoryLen;

    amplitude: [BUFFER_SIZE]float = fftData.fftHistory[historyPosition];
    bin: s32 = 0;
    while (bin < BUFFER_SIZE) {
        defer bin += 1;

        ImageDrawPixel(fftImage, bin, FFT_ROW, ColorFromNormalized(Vector4.{ amplitude[bin], UNUSED_CHANNEL, UNUSED_CHANNEL, UNUSED_CHANNEL }));
    }
}