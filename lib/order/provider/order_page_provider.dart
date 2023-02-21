import 'package:flutter/material.dart';


///ChangeNotifier数据监听器  给状态管理provider
class OrderPageProvider extends ChangeNotifier {

  /// Tab的下标
  int _index = 0;
  int get index => _index;
  
  // void refresh() {
  //   notifyListeners();
  // }
  
  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

}
