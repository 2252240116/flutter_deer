import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// isolate与Future.
/// isolate类似线程。但与线程不同，线程有共享内存，isolate并没有，也没有锁的。
/// isolate是处理异步并行多个任务，Future处理异步串行多个任务。
///
/// 比如某个耗时操作，使用async wait并不能解决问题。因为他还是在UI处理耗时操作，只不过优先处理这个任务。会阻塞卡顿页面。
/// 这个时候可以用isolate比较重量级，可减轻UI线程负担。但比较耗时。
class Isolate_Ex {

  ///使用isolate 计算0到 num 数值的总和。
  // void c() async{
  //  await  compute(summ(100));
  // }
  calculation(int n, Function(int result) success) async {
    //创建一个ReceivePort
    final receivePort1 = new ReceivePort();
    //创建isolate
    Isolate isolate = await Isolate.spawn(createIsolate, receivePort1.sendPort);
    receivePort1.listen((message) {
      if (message is SendPort) {
        SendPort sendPort2 = message;
        sendPort2.send(n);
      } else {
        print(message);
        success(message as int);
      }
    });
  }

  //创建isolate必须要的参数
  static void createIsolate(SendPort sendPort1) {
    final receivePort2 = new ReceivePort();
    //绑定
    print("sendPort1发送消息--sendPort2");
    sendPort1.send(receivePort2.sendPort);
    //监听
    receivePort2.listen((message) {
      //获取数据并解析
      print("receivePort2接收到消息--$message");
      if (message is int) {
        num result = summ(message);
        sendPort1.send(result);
      }
    });
  }

  //计算0到 num 数值的总和
  static num summ(int num) {
    int count = 0;
    while (num > 0) {
      count = count + num;
      num--;
    }
    return count;
  }
}
