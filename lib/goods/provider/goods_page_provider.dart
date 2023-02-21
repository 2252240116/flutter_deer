import 'package:flutter/material.dart';

class GoodsPageProvider extends ChangeNotifier {

  /// Tab的下标
  int _index = 0;
  int get index => _index;
  void setIndex(int index) {
    _index = index;
    notifyListeners();
  }

  /// 商品数量
  final List<int> _goodsCountList = [0, 0, 0];
  List<int> get goodsCountList => _goodsCountList;
  void setGoodsCount(int count) {
    _goodsCountList[index] = count;
    notifyListeners();
  }

  /// 选中商品分类下标
  int _sortIndex = 0;
  int get sortIndex => _sortIndex;
  void setSortIndex(int sortIndex) {
    _sortIndex = sortIndex;
    notifyListeners();
  }
}
