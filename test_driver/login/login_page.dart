
import 'package:flutter/material.dart';
import 'package:flutter_deer/login/page/login_page.dart';
import 'package:flutter_deer/main.dart';
import 'package:flutter_driver/driver_extension.dart';

/// 运行 flutter drive --target=test_driver/login/login_page.dart
/// 会走对应的login_page_test测试工具类
void main() {
  enableFlutterDriverExtension();
  runApp(MyApp(home: const LoginPage()));
}
