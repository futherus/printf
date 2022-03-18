#include <stdio.h>
//#include <stdarg.h>

extern "C" void _printf_stdcall(const char* fmt, ...);

#define TEST(ID, FMT, ...)                      \
        printf("Test #%d\n", ID);               \
        printf(FMT, ##__VA_ARGS__);             \
        _printf_stdcall(FMT, ##__VA_ARGS__)     \
        
int main()
{
        TEST(1, "Hey\n");
        //_printf_stdcall("Hey");
        return 0;
}
