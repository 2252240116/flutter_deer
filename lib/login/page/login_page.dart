import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/login/widgets/my_text_field.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/routers/fluro_navigator.dart';
import 'package:flutter_deer/store/store_router.dart';
import 'package:flutter_deer/util/change_notifier_manage.dart';
import 'package:flutter_deer/util/other_utils.dart';
import 'package:flutter_deer/widgets/my_app_bar.dart';
import 'package:flutter_deer/widgets/my_button.dart';
import 'package:flutter_deer/widgets/my_scroll_view.dart';
import 'package:flutter_gen/gen_l10n/deer_localizations.dart';
import 'package:sp_util/sp_util.dart';

import '../login_router.dart';

/// design/1注册登录/index.html
class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  ///0.创建一个State.
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ChangeNotifierMixin<LoginPage> {
  //定义一个controller
  final TextEditingController _nameController = TextEditingController();//TextField控制器 父类是ChangeNotifier
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();//TextField焦点 父类也是是ChangeNotifier
  final FocusNode _nodeText2 = FocusNode();
  bool _clickable = false;

  @override
  Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
    //VoidCallBack类型的数组
    final List<VoidCallback> callbacks = [_verify];
    // final List<VoidCallback> callbacks = <VoidCallback>[_verify];
    //Map<ChangeNotifier,callBacks>
    return <ChangeNotifier, List<VoidCallback>?>{
      _nameController: callbacks,
      _passwordController: callbacks,
      _nodeText1: null,
      _nodeText2: null,
    };
  }


  ///1.初始化state
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 500), () {
      //initState 此时State与BuildContext产生关联，但context并未形成，可以通过Future.delayed方法获取context
      context;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// 显示状态栏和导航栏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    });
    _nameController.text = SpUtil.getString(Constant.phone).nullSafe;

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        debugPrint(msg);
      } else if (msg == AppLifecycleState.inactive.toString()) {

      } else if (msg == AppLifecycleState.paused.toString()) {

      } else if (msg == AppLifecycleState.detached.toString()) {

      }
      debugPrint('管理生命周期：$msg');
      return "";
    });
  }

  ///2.initState之后 State对象 依赖关系发生变化。父类树的节点发生变化会调用，值变化不会
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  ///3.State被暂时移除Widget时。相当于android的onPause
  @override
  void deactivate() {
    super.deactivate();
  }
  ///4.Widget销毁时
  @override
  void dispose() {
    super.dispose();
  }
  ///Widget状态发生变化。setState-->build 会通知子类调用这个方法
  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _verify() {
    final String name = _nameController.text;//获取TextField值
    final String password = _passwordController.text;//获取TextField值
    bool clickable = true;
    if (name.isEmpty || name.length < 11) {
      clickable = false;
    }
    if (password.isEmpty || password.length < 6) {
      clickable = false;
    }

    /// 状态不一样再刷新，避免不必要的setState
    if (clickable != _clickable) {
      setState(() {
        _clickable = clickable;
      });
    }
  }

  void _login() {
    SpUtil.putString(Constant.phone, _nameController.text);
    NavigatorUtils.push(context, StoreRouter.auditPage);
  }

  ///构建一个Widget setState{}更新build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        // title: 'title',
        // centerTitle: "center",
        isBack: false,
        actionName: DeerLocalizations.of(context)!.verificationCodeLogin,
        onPressed: () {
          ///验证码登录
          NavigatorUtils.push(context, LoginRouter.smsLoginPage);
        },
      ),
      body: MyScrollView(
        keyboardConfig: Utils.getKeyboardActionsConfig(context, <FocusNode>[_nodeText1, _nodeText2]),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
        children: _buildBody,
      ),
    );
  }

  List<Widget> get _buildBody => <Widget>[
    Text(
      DeerLocalizations.of(context)!.passwordLogin,
      style: TextStyles.textBold26,
    ),
    Gaps.vGap16,
    MyTextField(
      key: const Key('phone'),
      focusNode: _nodeText1,
      controller: _nameController,
      maxLength: 11,
      keyboardType: TextInputType.phone,
      hintText: DeerLocalizations.of(context)!.inputUsernameHint,
    ),
    Gaps.vGap8,
    MyTextField(
      key: const Key('password'),
      keyName: 'password',
      focusNode: _nodeText2,
      isInputPwd: true,
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      hintText: DeerLocalizations.of(context)!.inputPasswordHint,
    ),
    Gaps.vGap24,
    MyButton(
      key: const Key('login'),
      backgroundColor: Colors.black,
      disabledBackgroundColor: Colors.grey,
      radius: 24,
      //Button通过控制onPressed为null 则不可点击
      onPressed: _clickable ? _login : null,
      text: DeerLocalizations.of(context)!.login,
    ),
    ///忘记密码
    Container(
      height: 40.0,
      ///alignment 摆放Container的位置
      alignment: Alignment.centerRight,
      child: GestureDetector(
        child: Text(
          DeerLocalizations.of(context)!.forgotPasswordLink,
          key: const Key('forgotPassword'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onTap: () => NavigatorUtils.push(context, LoginRouter.resetPasswordPage),
      ),
    ),
    Gaps.vGap16,
    Container(
      alignment: Alignment.center,
      child: GestureDetector(
        child: Text(
          DeerLocalizations.of(context)!.noAccountRegisterLink,
          key: const Key('noAccountRegister'),
          style: TextStyle(
            color: Theme.of(context).primaryColor
          ),
        ),
        onTap: () => NavigatorUtils.push(context, LoginRouter.registerPage),
      )
    )
  ];
}
