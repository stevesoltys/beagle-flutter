import 'dart:convert';
import 'dart:ffi';

import 'package:beagle/src/bridge_impl/test.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/quickjs/ffi.dart';

class IsolateJsWrapper extends JavascriptRuntime {

  final isolateQjs = IsolateTest(stackSize: 1024 * 1024);// IsolateQjs(stackSize: 1024 * 1024);

  @override
  JsEvalResult callFunction(Pointer<NativeType> fn, Pointer<NativeType> obj) {
    throw UnimplementedError();
  }

  @override
  T? convertValue<T>(JsEvalResult jsValue) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  JsEvalResult evaluate(String code) {
    throw UnimplementedError();
  }

  @override
  Future<JsEvalResult> evaluateAsync(String code) async {
    final result = await isolateQjs.evaluate(code);

    return JsEvalResult(result.toString(), result, isError: false, isPromise: false //strResult == '[object Promise]',
    );
  }

  @override
  int executePendingJob() {
    return 0;
  }

  @override
  String getEngineInstanceId() {
    return this.hashCode.toString();
  }

  @override
  void initChannelFunctions() {
  }

  @override
  String jsonStringify(JsEvalResult jsValue) {
    throw UnimplementedError();
  }

  @override
  bool setupBridge(String channelName, void Function(dynamic args) fn) {
    isolateQjs.setupBridge(channelName, fn);
    return true;
  }
}
