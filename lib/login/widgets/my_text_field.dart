import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/widgets/load_image.dart';
import 'package:flutter_deer/widgets/my_button.dart';
import 'package:flutter_gen/gen_l10n/deer_localizations.dart';

/// 登录模块的输入框封装
class MyTextField extends StatefulWidget {
  const MyTextField(
      {super.key,
      required this.controller,
      this.maxLength = 16,
      this.autoFocus = false,
      this.keyboardType = TextInputType.text,
      this.hintText = '',
      this.focusNode,
      this.isInputPwd = false,
      this.getVCode,
      this.keyName});

  final TextEditingController controller;
  final int maxLength;
  final bool autoFocus;
  final TextInputType keyboardType;
  final String hintText;
  final FocusNode? focusNode;
  final bool isInputPwd;
  final Future<bool> Function()? getVCode;

  /// 用于集成测试寻找widget
  final String? keyName;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isShowPwd = false;
  bool _isShowDelete = false;
  bool _clickable = true;

  /// 倒计时秒数
  final int _second = 30;

  /// 当前秒数
  late int _currentSecond;
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    /// 获取初始化值
    _isShowDelete = widget.controller.text.isNotEmpty;

    /// 监听输入改变
    widget.controller.addListener(isEmpty);
    super.initState();
  }

  void isEmpty() {
    final bool isNotEmpty = widget.controller.text.isNotEmpty;

    /// 状态不一样在刷新，避免重复不必要的setState
    if (isNotEmpty != _isShowDelete) {
      setState(() {
        _isShowDelete = isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.controller.removeListener(isEmpty);
    super.dispose();
  }

  Future<dynamic> _getVCode() async {
    final bool isSuccess = await widget.getVCode!();
    if (isSuccess) {
      setState(() {
        _currentSecond = _second;
        _clickable = false;
      });
      _subscription = Stream.periodic(const Duration(seconds: 1), (int i) => i)
          .take(_second)
          .listen((int i) {
        setState(() {
          _currentSecond = _second - i - 1;
          _clickable = _currentSecond < 1;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool isDark = themeData.brightness == Brightness.dark;
    ///复杂布局多个widget，可以用方法去获取，也可以用这种自定义内部widget，可读性高
    Widget textField = TextField(
      //控制TextField是否占有当前键盘的焦点，交互通过句柄handle
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      //是否密文
      obscureText: widget.isInputPwd && !_isShowPwd,
      //是否自动获取焦点
      autofocus: widget.autoFocus,
      //编辑框控制器
      controller: widget.controller,
      //回车按钮
      textInputAction: TextInputAction.done,
      //键盘输入类型
      keyboardType: widget.keyboardType,
      //指定输入格式
      inputFormatters: (widget.keyboardType == TextInputType.number ||
              widget.keyboardType == TextInputType.phone)
          ? [FilteringTextInputFormatter.allow(RegExp('[0-9]'))]
          : [FilteringTextInputFormatter.deny(RegExp('[\u4e00-\u9fa5]'))],//'[\u4e00-\u9fa5]'表示中文
      //控制Textfield的外观
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        hintText: widget.hintText,
        counterText: '',
        //去掉下划线
        border: InputBorder.none
        //自定义下划线
        // focusedBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(
        //     color: themeData.primaryColor,
        //     width: 0.8,
        //   ),
        // ),
        // enabledBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(
        //     color: Theme.of(context).dividerTheme.color!,
        //     width: 0.8,
        //   ),
        // ),
      ),
    );

    /// 个别Android机型（华为、vivo）的密码安全键盘不弹出问题（已知小米正常），临时修复方法：https://github.com/flutter/flutter/issues/68571 (issues/61446)
    /// 怀疑是安全键盘与三方输入法之间的切换冲突问题。
    if (Device.isAndroid) {
      textField = Listener(
        onPointerDown: (e) =>
            FocusScope.of(context).requestFocus(widget.focusNode),
        child: textField,
      );
    }

    Widget? clearButton;

    if (_isShowDelete) {
      //Semantics语义widget
      clearButton = Semantics(
        label: '清空',
        hint: '清空输入框',
        child: GestureDetector(
          child: LoadAssetImage(
            'login/qyg_shop_icon_delete',
            key: Key('${widget.keyName}_delete'),
            width: 18.0,
            height: 40.0,
          ),
          onTap: () => widget.controller.text = '',
        ),
      );
    }

    late Widget pwdVisible;
    if (widget.isInputPwd) {
      pwdVisible = Semantics(
        label: '密码可见开关',
        hint: '密码是否可见',
        child: GestureDetector(
          child: LoadAssetImage(
            _isShowPwd
                ? 'login/qyg_shop_icon_display'
                : 'login/qyg_shop_icon_hide',
            key: Key('${widget.keyName}_showPwd'),
            width: 18.0,
            height: 40.0,
          ),
          onTap: () {
            setState(() {
              _isShowPwd = !_isShowPwd;
            });
          },
        ),
      );
    }

    //late 变量 用时才初始化
    late Widget getVCodeButton;
    if (widget.getVCode != null) {
      getVCodeButton = MyButton(
        key: const Key('getVerificationCode'),
        onPressed: _clickable ? _getVCode : null,
        fontSize: Dimens.font_sp12,
        text: _clickable
            ? DeerLocalizations.of(context)!.getVerificationCode
            : '（$_currentSecond s）',
        textColor: themeData.primaryColor,
        disabledTextColor: isDark ? Colours.dark_text : Colors.white,
        backgroundColor: Colors.transparent,
        disabledBackgroundColor:
            isDark ? Colours.dark_text_gray : Colours.text_gray_c,
        radius: 1.0,
        minHeight: 26.0,
        minWidth: 76.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        side: BorderSide(
          color: _clickable ? themeData.primaryColor : Colors.transparent,
          width: 0.8,
        ),
      );
    }

    ///这里用Stack其实不合理
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        textField,
        Row(
          //主轴尺寸：默认MainAxisSize.max 最大，MainAxisSize.min最小
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            /// _isShowDelete参数动态变化，为了不破坏树结构使用Visibility，false时放一个空Widget。
            /// 对于其他参数，为初始配置参数，基本可以确定树结构，就不做空Widget处理。
            // Visibility(
            //   visible: _isShowDelete,
            //   child: clearButton ?? Gaps.empty,
            // ),
            if(_isShowDelete) clearButton ?? Gaps.empty,
            if (widget.isInputPwd) Gaps.hGap15,
            if (widget.isInputPwd) pwdVisible,
            if (widget.getVCode != null) Gaps.hGap15,
            if (widget.getVCode != null) getVCodeButton,
          ],
        )
      ],
    );
  }
}
