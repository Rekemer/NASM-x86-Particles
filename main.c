#include"stdio.h"
#include <math.h>

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
__declspec(dllexport) float random (int x, int y) {
    x*= 12.9898;
    y*= 78.233;
    float sinArgument = x*x + y*y;
    float sinFunc = sin(sinArgument)*43758.5453123;
    int castedSin = floor(sinFunc);
    float res = sinFunc - castedSin;
    res = res*2 - 1;
    res+=0.4;
    return res;
}
