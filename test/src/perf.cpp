#include <iostream>
#include <cassert>

#include <JavaScriptCore/config.h>
#include <JavaScriptCore/JavaScript.h>
//#include <JavaScriptCore/JSCInlines.h>
//#include <JavaScriptCore/JSGlobalObject.h>
//#include <JavaScriptCore/JSObject.h>
//#include <JavaScriptCore/JSArray.h>
#include <JavaScriptCore/APICast.h>

using namespace JSC;

static int Add(int a, int b) {
    //std::cout << "a:" << a << ",b:" << b << std::endl;
    return a + b;
}

JSValueRef PublicApiAddCallback(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    (void)function;
    (void)thisObject;
    if (argumentCount != 2) {
        JSStringRef message = JSStringCreateWithUTF8CString("Function Add expects 2 arguments");
        *exception = JSValueMakeString(context, message);
        JSStringRelease(message);
        return JSValueMakeUndefined(context);
    }

    int a = JSValueToNumber(context, arguments[0], exception);
    int b = JSValueToNumber(context, arguments[1], exception);
    int result = Add(a, b);
    return JSValueMakeNumber(context, result);
}

JSValueRef PrintCallback(JSContextRef context, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    (void)function;
    (void)thisObject;
    (void)exception;
    for (size_t i = 0; i < argumentCount; i++) {
        JSStringRef string = JSValueToStringCopy(context, arguments[i], NULL);
        size_t max_size = JSStringGetMaximumUTF8CStringSize(string);
        char* cstring = (char*)malloc(max_size);
        JSStringGetUTF8CString(string, cstring, max_size);
        printf("%s\n", cstring);
        free(cstring);
        JSStringRelease(string);
    }
    return JSValueMakeUndefined(context);
}

JSC_DECLARE_HOST_FUNCTION(PrivateApiAddCallback);

int main() {
    JSContextGroupRef group = JSContextGroupCreate();
    VM& vm = *toJS(group);
    JSGlobalContextRef context = JSGlobalContextCreateInGroup(group, NULL);

    JSC::JSGlobalObject* globalObject = toJS(context);
    JSLockHolder locker(vm);
    Identifier identifier = Identifier::fromString(vm, "PrivateApiAdd"_s);
    globalObject->putDirect(vm, identifier, JSFunction::create(vm, globalObject, 2, "PrivateApiAdd"_s, PrivateApiAddCallback, ImplementationVisibility::Public), static_cast<unsigned>(PropertyAttribute::DontEnum));
    JSStringRef functionName = JSStringCreateWithUTF8CString("PublicApiAdd");
    JSObjectRef functionObject = JSObjectMakeFunctionWithCallback(context, functionName, PublicApiAddCallback);
    JSObjectSetProperty(context, JSContextGetGlobalObject(context), functionName, functionObject, kJSPropertyAttributeNone, NULL);
    JSStringRelease(functionName);
    functionName = JSStringCreateWithUTF8CString("print");
    functionObject = JSObjectMakeFunctionWithCallback(context, functionName, PrintCallback);
    JSObjectSetProperty(context, JSContextGetGlobalObject(context), functionName, functionObject, kJSPropertyAttributeNone, NULL);
    
    JSStringRef code = JSStringCreateWithUTF8CString(R"delimiter(
        print(`PublicApiAdd(1, 2)=${PublicApiAdd(1, 2)}`);
        print(`PrivateApiAdd(1, 2)=${PrivateApiAdd(1, 2)}`);
        const LOOP = 1000 * 1000 * 100;
        
        var start = Date.now();
        for(var i = 0; i < LOOP; ++i) {
            PublicApiAdd(1, 2)
        }
        print(`public elapsed = ${Date.now() - start}`);
        
        var start = Date.now();
        for(var i = 0; i < LOOP; ++i) {
            PrivateApiAdd(1, 2)
        }
        print(`private elapsed = ${Date.now() - start}`);
        
        function JsAdd(a, b) {
            print(`a=${a}, b=${b}`);
            return a + b;
        }
        )delimiter");
    JSStringRef file = JSStringCreateWithUTF8CString("");
    JSValueRef exception = nullptr;
    JSValueRef value = JSEvaluateScript(context, code, 0, file, 1, &exception);
    
    if (!exception) {
        JSStringRelease(functionName);
        functionName = JSStringCreateWithUTF8CString("JsAdd");
        JSValueRef function = JSObjectGetProperty(context, JSContextGetGlobalObject(context), functionName, NULL);
        
        { // call by public api
            JSValueRef args[2];
            args[0] = JSValueMakeNumber(context, 1); // a
            args[1] = JSValueMakeNumber(context, 2); // b

            JSValueRef exception = NULL;
            value = JSObjectCallAsFunction(context, (JSObjectRef)function, NULL, 2, args, &exception);
            if (!exception) {
                double sum = JSValueToNumber(context, value, NULL);
                printf("Result(public): %f\n", sum);
            }
        }
        
        if (!exception) { // private api
            JSC::JSValue funcValue = toJS(function);
            auto callData = JSC::getCallData(funcValue);
            if (UNLIKELY(callData.type == JSC::CallData::Type::None)) {
                fprintf(stderr, "callData.type == JSC::CallData::Type::None\n");
                return 0;
            }
            
            //JSObject* jsThisObject = globalObject->globalThis();
            JSC::MarkedArgumentBuffer args;
            //args.ensureCapacity(2);
            args.append(JSC::JSValue(1));
            //RETURN_IF_EXCEPTION(scope, { });
            args.append(JSC::JSValue(2));
            if (UNLIKELY(args.hasOverflowed())) {
                fprintf(stderr, "args.hasOverflowed()\n");
                return 0;
            }
            //RETURN_IF_EXCEPTION(scope, { });
            
            auto scope = DECLARE_THROW_SCOPE(vm);
            //JSValue jsResult = profiledCall(globalObject, ProfilingReason::API, funcValue, callData, jsThisObject, args);
            JSValue jsResult = call(globalObject, funcValue, callData, jsUndefined(), args);
            //RETURN_IF_EXCEPTION(scope, { });
            if (UNLIKELY(scope.exception())) {
                exception = toRef(globalObject, scope.exception()->value());
                scope.clearException();
            } else if (jsResult.isNumber()) {
                double sum = jsResult.asNumber();
                printf("Result(private): %f\n", sum);
            }
        }
    }
    
    if (exception) {
        assert(JSValueIsString(context, exception));
        JSStringRef exceptionString = JSValueToStringCopy(context, exception, NULL);
        size_t max_size = JSStringGetMaximumUTF8CStringSize(exceptionString);
        char* exceptionCString = (char*)malloc(max_size);
        JSStringGetUTF8CString(exceptionString, exceptionCString, max_size);
        printf("JavaScript exception: %s\n", exceptionCString);
        free(exceptionCString);
        JSStringRelease(exceptionString);
    }
    
    JSStringRelease(functionName);
    JSStringRelease(code);
    JSStringRelease(file);
    
    JSGlobalContextRelease(context);
    (void)value;

    return 0;
}

JSC_DEFINE_HOST_FUNCTION(PrivateApiAddCallback, (JSC::JSGlobalObject* globalObject, JSC::CallFrame* callFrame))
{
    JSC::VM& vm = globalObject->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);
    
    if (callFrame->argumentCount() != 2) {
        throwException(globalObject, scope, createError(globalObject, "Function Add expects 2 arguments"_s));
        return JSC::JSValue::encode(JSC::jsUndefined());
    }

    int a = callFrame->uncheckedArgument(0).toInt32(globalObject);
    int b = callFrame->uncheckedArgument(1).toInt32(globalObject);
    int result = Add(a, b);
    return JSC::JSValue::encode(JSC::JSValue(result));
}