#include"stdio.h"
typedef struct 
{
    int number;
} A;
int sum (int a, int b)
{
    return a + b;
}
int a = 2;
int b = 4;
float k = 1;
int main()
{
    a = 4;
    k = (float)a;
    printf("%f",k);
    //sum (a,b);
    //printf("%i",2);
    return 0;
}