extern "C" void _printf_stdcall(const char* fmt, ...);

int main()
{
        //_printf_stdcall("Hey");
        _printf_stdcall("%c %s %s %x! %c %c %c\n" "%x %d\n",
                     'I', "love", "nice", 3802, 'a', 'b', 'c', 11, 123);
        _printf_stdcall("%c %s %s %x! %c %c %c\n" "%x %d\n",
                             'I', "love", "nice", 3802, 'a', 'b', 'c', 11, 123);

        return 0;
}
