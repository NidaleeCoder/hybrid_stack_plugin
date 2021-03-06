import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hybrid_stack_plugin/router.dart';

typedef HSWidgetBuilder = Widget Function(BuildContext context, Map args);

class HybridStackPlugin {
  static HybridStackPlugin init({@required GlobalKey<NavigatorState> key}) {
    if (_singleton == null) {
      _singleton = HybridStackPlugin._internal();
    }
    HSRouter.init(key: key);
    return _singleton;
  }

  static pushNativePage(String pageId, Map args) async {
    var result = await instance._channel
        .invokeMethod('pushNativePage', {'pageId': pageId, 'args': args});
    return result;
  }

  static addRoute(String id, HSWidgetBuilder builder) {
    HSRouter.instance.addRoute(id, builder);
  }

  //called after runApp, only useful for Android
  static startInitRoute() {
    instance._channel.invokeMethod("startInitRoute");
  }

  static HybridStackPlugin _singleton;
  static HybridStackPlugin get instance {
    if (_singleton == null) {
      throw Exception('must call HybridStackPlugin.init(key) first');
    }
    return _singleton;
  }

  MethodChannel _channel;
  HybridStackPlugin._internal() {
    this._channel = const MethodChannel('hybrid_stack_plugin');
    _setupChannelHandler();
  }

  _popFlutterActivity(Map args) {
    _channel.invokeMethod("popFlutterActivity", args);
  }

  void _setupChannelHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      /// method name
      String methodName = call.method;
      switch (methodName) {
        case "pushFlutterPage":
          {
            Map args = call.arguments;
            var ret = await HSRouter.instance
                .push(pageId: args['pageId'], args: args['args']);
            print("push result: $ret");
            _popFlutterActivity({'data': ret});
            return ret;
          }
        //not used
        case "requestUpdateTheme":
          {
            // 请求更新主题色到 native 端，这里使用了一个测试接口，以后要注意
//          var preTheme = SystemChrome.latestStyle;
//          if (preTheme != null) {
//            SystemChannels.platform.invokeMethod("SystemChrome.setSystemUIOverlayStyle", _toMap(preTheme));
//          }
            break;
          }
        case "popFlutterPage":
          {
            /// 重写 onBackPressed
            if (HSRouter.instance.canPop()) {
              HSRouter.instance.doPop();
              return true;
            }
            HSRouter.instance.doPop();
            return false; //能pop返回true,否则返回false
          }
      }
    });
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
