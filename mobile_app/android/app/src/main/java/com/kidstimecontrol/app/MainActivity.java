package com.kidstimecontrol.app;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import androidx.annotation.NonNull;
import android.view.WindowManager;
import android.app.ActivityManager;
import android.content.Intent;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.kidstimecontrol.app/lock";
    private static boolean isLocked = false;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "setLocked":
                        boolean locked = call.argument("locked");
                        isLocked = locked;
                        LockAccessibilityService.setLocked(locked);
                        updateLockState(locked);
                        result.success(null);
                        break;

                    case "isAccessibilityEnabled":
                        boolean enabled = AccessibilityHelper.isAccessibilityServiceEnabled(this);
                        result.success(enabled);
                        break;

                    case "openAccessibilitySettings":
                        AccessibilityHelper.openAccessibilitySettings(this);
                        result.success(null);
                        break;

                    default:
                        result.notImplemented();
                        break;
                }
            });
    }

    private void updateLockState(boolean locked) {
        if (locked) {
            // 防止顯示在最近使用的應用列表
            setShowWhenLocked(true);
            setTurnScreenOn(true);

            // 防止螢幕關閉
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else {
            setShowWhenLocked(false);
            setTurnScreenOn(false);
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        // 當鎖定時，如果應用進入後台，立即將其帶回前台
        if (isLocked) {
            Intent intent = new Intent(this, MainActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            startActivity(intent);
        }
    }

    @Override
    public void onBackPressed() {
        // 當鎖定時，攔截返回鍵
        if (isLocked) {
            // 不做任何事，防止關閉應用
            return;
        }
        super.onBackPressed();
    }
}
