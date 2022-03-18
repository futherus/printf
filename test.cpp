#include <stdio.h>

extern "C" void _printf_stdcall(const char* fmt, ...);

#define TEST(ID, FMT, ...)                      \
        printf("Test #%d\n"                     \
               "Expctd: !<", (ID));             \
        printf(FMT, ##__VA_ARGS__);             \
        printf(">!\n"                           \
               "Output: !<");                   \
        _printf_stdcall(FMT, ##__VA_ARGS__);    \
        printf(">!\n");                         \

int main()
{
        setvbuf(stdout, nullptr, _IONBF, 0);
        TEST(1, "First test");

        TEST(2, "%c love %x", 'I', 3802);

        TEST(3, "%c%d%%%s", 'Q', 123, "String");

        TEST(4, "1%s2%s3%s4%s5%s6%s7%s8%s9%s10%s11%s",
                "First", "Second", "Third",
                "Fourth", "Fifth", "Sixth", 
                "Seventh", "Eighth", "Nineth",
                 "Tenth", "Eleventh");
                
        return 0;
}
