import 'dart:async';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/demo/demo_page.dart';
import 'package:flutter_deer/login/login_router.dart';
import 'package:flutter_deer/res/constant.dart';
import 'package:flutter_deer/routers/fluro_navigator.dart';
import 'package:flutter_deer/util/app_navigator.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/util/image_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/widgets/fractionally_aligned_sized_box.dart';
import 'package:flutter_deer/widgets/load_image.dart';
import 'package:flutter_swiper_null_safety_flutter3/flutter_swiper_null_safety_flutter3.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sp_util/sp_util.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _status = 0;
  final List<String> _guideList = ['app_start_1', 'app_start_2', 'app_start_3'];
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    //    构造函数
    //     initState
    //     didChangeDependencies
    //     build
    //     addPostFrameCallback 页面最后一帧渲染完成。只调用一次  相当于android里的onWindowFoucusChanged
    //     (组件状态改变)didUpdateWidget
    //     deactivate
    //     dispose

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// 两种初始化方案，另一种见 main.dart
      /// 两种方法各有优劣
      await SpUtil.getInstance();
      await Device.initDeviceInfo();
      if (SpUtil.getBool(Constant.keyGuide, defValue: true)!) {

        /// 预先缓存图片，避免直接使用时因为首次加载造成闪动
        void precacheImages(String image) {
          // 预先缓存图片
          precacheImage(ImageUtils.getAssetImage(image, format: ImageFormat.webp), context);
        }
        _guideList.forEach(precacheImages);
        ///相当于
        // _guideList.forEach((e)=>precacheImages(e));
        // for (var e in _guideList) {
        //   precacheImages(e);
        // }
      }
      _initSplash();
    });
    /// 设置桌面端窗口大小
    if (Device.isDesktop) {
      DesktopWindow.setWindowSize(const Size(400, 800));
    }
    if (Device.isAndroid) {
      const QuickActions quickActions = QuickActions();
      quickActions.initialize((String shortcutType) async {
        if (shortcutType == 'demo') {
          AppNavigator.pushReplacement(context, const DemoPage());
          _subscription?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _initGuide() {
    setState(() {
      _status = 1;
    });
  }

  void _initSplash() {
    //Stream.value(1)发送一个数据 delay延时
    _subscription = Stream.value(1).delay(const Duration(milliseconds: 1500)).listen((_) {
      if (SpUtil.getBool(Constant.keyGuide, defValue: true)! || Constant.isDriverTest) {
        SpUtil.putBool(Constant.keyGuide, false);
        _initGuide();
      } else {
        _goLogin();
      }
    });
  }

  void _goLogin() {
    NavigatorUtils.push(context, LoginRouter.loginPage, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.backgroundColor,
      child: _status == 0 ?
      //闪屏页
      const FractionallySizedBox(
        alignment: Alignment.bottomCenter,//FractionallySizeBox所在父布局的位置 默认Alignment.center
        heightFactor: 0.4,//按照FractionallySizedBox的宽高比例
        widthFactor: 0.3,
        child: LoadAssetImage('logo',fit: BoxFit.contain,)//宽高有一个填满contain，相当于FitCenter
      ) :
      //引导页
      Swiper(
        key: const Key('swiper'),
        itemCount: _guideList.length,
        loop: false,
        itemBuilder: (_, index) {
          return LoadAssetImage(
            _guideList[index],
            key: Key(_guideList[index]),
            fit: BoxFit.cover,//相当于ScaleType的CENTER_CROP 按比例缩放 超过裁剪
            width: double.infinity,//相当于match_parent，填满
            height: double.infinity,
            format: ImageFormat.webp,
          );
        },
        onTap: (index) {
          if (index == _guideList.length - 1) {
            _goLogin();
          }
        },
      )
    );
  }
}
