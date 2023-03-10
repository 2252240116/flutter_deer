import 'package:flutter/widgets.dart';

/// @weilu https://github.com/simplezhli/flutter_deer
/// 
/// 便于管理ChangeNotifier，不用重复写模板代码。（ChangeNotifier添加监听和移除监听的代码）
/// 之前：
/// ```dart
/// class TestPageState extends State<TestPage> {
///   final TextEditingController _controller = TextEditingController();
///   final FocusNode _nodeText = FocusNode();
///   
///   @override
///   void initState() {
///     _controller.addListener(callback);
///     super.initState();
///   }
///
///   @override
///   void dispose() {
///     _controller.removeListener(callback);
///     _controller.dispose();
///     _nodeText.dispose();
///     super.dispose();
///   }
/// }
/// ```
/// 使用示例：
/// ```dart
/// class TestPageState extends State<TestPage> with ChangeNotifierMixin<TestPage> {
///   final TextEditingController _controller = TextEditingController();
///   final FocusNode _nodeText = FocusNode();
///
///   @override
///   Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
///     return {
///       _controller: [callback],
///       _nodeText: null,
///     };
///   }
/// }
/// ```
///  mixin是在无需继承父类的情况下为父类添加功能
///  on限定词
mixin ChangeNotifierMixin<T extends StatefulWidget> on State<T> {

  Map<ChangeNotifier?, List<VoidCallback>?>? _map;

  Map<ChangeNotifier?, List<VoidCallback>?>? changeNotifier();
  
  @override
  void initState() {
    _map = changeNotifier();//方法赋值给map,具体在widget页面里返回
    /// 遍历数据，如果callbacks不为空则添加监听
    _map?.forEach((changeNotifier, callbacks) { 
      if (callbacks != null && callbacks.isNotEmpty) {

        void addListener(VoidCallback callback) {
          //给textfiled添加监听
          changeNotifier?.addListener(callback);
        }

        callbacks.forEach(addListener);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _map?.forEach((changeNotifier, callbacks) {
      if (callbacks != null && callbacks.isNotEmpty) {
        void removeListener(VoidCallback callback) {
          changeNotifier?.removeListener(callback);
        }

        callbacks.forEach(removeListener);
      }
      changeNotifier?.dispose();
    });
    super.dispose();
  }
}
