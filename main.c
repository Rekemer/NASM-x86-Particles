#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdint.h>
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

__declspec(dllexport) double mySin(double angle) {
    return sin(angle);
}
__declspec(dllexport) int  printFloat(float number) {
    printf("%f\n",number);
    return 201;
}
__declspec(dllexport) void  printString() {
    printf("Hello\n");
}
__declspec(dllexport) void  printInteger(int a) {
    printf("%i\n",a);
}

float clamp(float x, float upper, float lower)
{
    return MIN(upper, MAX(x, lower));
}
__declspec(dllexport) float random (int x, int y) {
    x*= 12.9898;
    y*= 78.233;
    float sinArgument = x*x + y*y;
    float sinFunc = sin(sinArgument)*43758.5453123;
    int castedSin = floor(sinFunc);
    float res = sinFunc - castedSin;
    res = res*2 - 1;
    res = clamp(-1,1,res);
    //res+=0.4;
    //res = (float)rand() / RAND_MAX * 2.0 - 1.0;
     return res;
}
__declspec(dllexport) uint32_t randomColor(float randomValue)
{
    // Ensure randomValue is in the range [0, 1]
    if (randomValue < 0.0) randomValue = 0.0;
    if (randomValue > 1.0) randomValue = 1.0;

    // Seed the random number generator (call this once at the beginning of your program)
    static int initialized = 0;
    if (!initialized) {
        srand((unsigned int)time(NULL));
        initialized = 1;
    }

    // Generate random offsets for each channel
    float redOffset = ((rand() % 256) - 128) / 255.0f;   // Random number between -0.5 and 0.5
    float greenOffset = ((rand() % 256) - 128) / 255.0f; // Random number between -0.5 and 0.5
    float blueOffset = ((rand() % 256) - 128) / 255.0f;  // Random number between -0.5 and 0.5

    // Modify randomValue with the random offsets
    float red = randomValue + redOffset;
    float green = randomValue + greenOffset;
    float blue = randomValue + blueOffset;

    // Ensure each channel is in the range [0, 1]
    if (red < 0.0) red = 0.0;
    if (red > 1.0) red = 1.0;
    if (green < 0.0) green = 0.0;
    if (green > 1.0) green = 1.0;
    if (blue < 0.0) blue = 0.0;
    if (blue > 1.0) blue = 1.0;

    // Map the modified random values to the RGB color space
    uint8_t redByte = (uint8_t)(red * 255.0f);
    uint8_t greenByte = (uint8_t)(green * 255.0f);
    uint8_t blueByte = (uint8_t)(blue * 255.0f);

    // Create the 32-bit color value
    uint32_t colorValue = (redByte << 16) | (greenByte << 8) | blueByte;
    return colorValue;
}