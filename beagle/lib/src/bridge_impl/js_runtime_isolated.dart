import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/javascriptcore/jscore_runtime.dart';

typedef dynamic _Decode(Map obj);

List<_Decode> _decoders = [
  _decodeJSError
];

JSError? _decodeJSError(Map obj) {
  if (obj.containsKey(#jsError)) return JSError(obj[#jsError], obj[#jsErrorStack]);
  return null;
}

dynamic _encodeData(dynamic data, {Map<dynamic, dynamic>? cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is Pointer) return null;
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_encodeData(data[i], cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_encodeData(entry.key, cache: cache)] = _encodeData(entry.value, cache: cache);
    }
    return ret;
  }
  if (data is Future) {
    final futurePort = ReceivePort();
    data.then((value) {
      futurePort.first.then((port) {
        futurePort.close();
        (port as SendPort).send(_encodeData(value));
      });
    }, onError: (e) {
      futurePort.first.then((port) {
        futurePort.close();
        (port as SendPort).send({#error: _encodeData(e)});
      });
    });
    return {
      #jsFuturePort: futurePort.sendPort,
    };
  }
  return data;
}

dynamic _decodeData(dynamic data, {Map<dynamic, dynamic>? cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_decodeData(data[i], cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    for (final decoder in _decoders) {
      final decodeObj = decoder(data);
      if (decodeObj != null) return decodeObj;
    }
    if (data.containsKey(#jsFuturePort)) {
      SendPort port = data[#jsFuturePort];
      final futurePort = ReceivePort();
      port.send(futurePort.sendPort);
      final futureCompleter = Completer();
      futureCompleter.future.catchError((e) {});
      futurePort.first.then((value) {
        futurePort.close();
        if (value is Map && value.containsKey(#error)) {
          futureCompleter.completeError(_decodeData(value[#error]));
        } else {
          futureCompleter.complete(_decodeData(value));
        }
      });
      return futureCompleter.future;
    }
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_decodeData(entry.key, cache: cache)] = _decodeData(entry.value, cache: cache);
    }
    return ret;
  }
  return data;
}

void _runJsIsolate(Map spawnMessage) async {
  SendPort sendPort = spawnMessage[#port];
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);
  final javascriptCore = JavascriptCoreRuntime();

  port.listen((msg) async {
    var data;
    SendPort? msgPort = msg[#port];
    try {
      switch (msg[#type]) {
        case #evaluate:
          data = javascriptCore.evaluate(msg[#command]).stringResult;
          break;
        case #setupBridge:
          final channelName = msg[#channelName];

          javascriptCore.setupBridge(channelName, (args) {
            sendPort.send({#type: #channelMessage, #channel: channelName, #message: args});
          });
          break;
        case #close:
          data = false;
          javascriptCore.dispose();
          port.close();
          data = true;
          break;
      }
      if (msgPort != null) msgPort.send(_encodeData(data));
    } catch (e) {
      if (msgPort != null) {
        msgPort.send({
          #error: _encodeData(e),
        });
      }
    }
  });
  javascriptCore.executePendingJob();
}

class JsRuntimeIsolated {
  Future<SendPort>? _sendPort;

  /// Max stack size for quickjs.
  final int? stackSize;

  final Map<String, Function(dynamic args)> channels = {};

  /// Quickjs engine runing on isolate thread.
  ///
  /// Pass handlers to implement js-dart interaction and resolving modules. The `methodHandler` is
  /// used in isolate, so **the handler function must be a top-level function or a static method**.
  JsRuntimeIsolated({this.stackSize});

  _ensureEngine() {
    if (_sendPort != null) return;
    ReceivePort port = ReceivePort();
    Isolate.spawn(
      _runJsIsolate,
      {
        #port: port.sendPort,
        #stackSize: stackSize,
      },
      errorsAreFatal: true,
    );
    final completer = Completer<SendPort>();
    port.listen((msg) async {
      if (msg is SendPort && !completer.isCompleted) {
        completer.complete(msg);
        return;
      }
      switch (msg[#type]) {
        case #channelMessage:
          final channel = msg[#channel];
          final message = msg[#message];

          await channels[channel]?.call(message);
          break;
      }
    }, onDone: () {
      close();
      if (!completer.isCompleted) completer.completeError(JSError('isolate close'));
    });
    _sendPort = completer.future;
  }

  /// Free Runtime and close isolate thread that can be recreate when evaluate again.
  close() {
    final sendPort = _sendPort;
    _sendPort = null;
    if (sendPort == null) return;
    final ret = sendPort.then((sendPort) async {
      final closePort = ReceivePort();
      sendPort.send({
        #type: #close,
        #port: closePort.sendPort,
      });
      final result = await closePort.first;
      closePort.close();
      if (result is Map && result.containsKey(#error)) throw _decodeData(result[#error]);
      return _decodeData(result);
    });
    return ret;
  }

  /// Evaluate js script.
  Future<dynamic> evaluate(
    String command, {
    String? name,
    int? evalFlags,
  }) async {
    _ensureEngine();
    final evaluatePort = ReceivePort();
    final sendPort = await _sendPort!;
    sendPort.send({
      #type: #evaluate,
      #command: command,
      #name: name,
      #flag: evalFlags,
      #port: evaluatePort.sendPort,
    });
    final result = await evaluatePort.first;
    evaluatePort.close();
    if (result is Map && result.containsKey(#error)) throw _decodeData(result[#error]);
    return _decodeData(result);
  }

  /// Evaluate js script.
  Future<bool> setupBridge(String channelName, Future<void> Function(dynamic args) fn) async {
    if (channels.keys.contains(channelName)) return false;
    channels[channelName] = fn;

    _ensureEngine();
    final sendPort = await _sendPort!;

    sendPort.send({#type: #setupBridge, #channelName: channelName});

    return true;
  }
}
