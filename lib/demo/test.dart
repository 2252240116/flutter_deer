import "dart:async";

class Test {
  futureTest() {
    Future(() => {print("1111111")})
        .then((value) => {print("222222")})
        .then((value) => print("3333333"))
        .whenComplete(() => print("结束"));
  }

  foo() async {
    ///开启一个微任务
    scheduleMicrotask(() {});

    ///开启一个Event loop
    Timer.run(() {});

    final r = Runes("文字");

    print('foo E');
    String value = await fun();

    ///上面的await阻塞了下面这句话
    print('foo X $value');
  }

  /// 异步函数
  Future<String> fun() async {
    ///但这里是同步代码
    print('fun');
    return 'fun';
  }

  main() {
    print('main E');
    foo();
    Future.value(333).then((a) => print(a));
    print("main X");
  }

  ///执行结果
//main E
//foo E
//fun
//main X
//foo X fun
//333
}
