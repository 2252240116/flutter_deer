package com.weilu.deer;

import android.graphics.Color;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

/**
 * @author weilu
 */
public class MainActivity extends FlutterActivity {

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    ///添加通道  纯flutter项目这样添加  像Plugin就是引入到yaml文件中
    flutterEngine.getPlugins().add(new InstallAPKPlugin(this));
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    /// 设置状态栏透明，导航栏沉浸。
//    getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
    getWindow().setStatusBarColor(Color.TRANSPARENT);
  }
}
