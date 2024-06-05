#include <iostream>
#include <JavaScriptCore/JavaScript.h>

int main() {
    JSGlobalContextRef context = JSGlobalContextCreate(0);
    JSValueRef exception;
    JSStringRef code = JSStringCreateWithUTF8CString("function helloWorld() { return 1+1; } helloWorld();");
    JSStringRef file = JSStringCreateWithUTF8CString("");
    JSValueRef  value = JSEvaluateScript(context, code, /* thisObject*/ 0, file, 1, &exception);
    bool assert = JSValueIsNumber(context, value);
    int number = (int)JSValueToNumber(context, value, NULL);
    printf("Value: %d\n", number);
}

