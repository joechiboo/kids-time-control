package com.kidstimecontrol.app;

import android.accessibilityservice.AccessibilityService;
import android.content.Intent;
import android.view.accessibility.AccessibilityEvent;
import android.util.Log;

public class LockAccessibilityService extends AccessibilityService {
    private static final String TAG = "LockAccessibilityService";
    private static boolean isLocked = false;
    private String currentPackage = "";

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            if (event.getPackageName() != null) {
                String packageName = event.getPackageName().toString();

                // 如果鎖定且用戶切換到其他 APP
                if (isLocked && !packageName.equals("com.kidstimecontrol.app")) {
                    Log.d(TAG, "Device locked, returning to app from: " + packageName);

                    // 立即跳回我們的 APP
                    Intent intent = getPackageManager().getLaunchIntentForPackage("com.kidstimecontrol.app");
                    if (intent != null) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        startActivity(intent);
                    }
                }

                currentPackage = packageName;
            }
        }
    }

    @Override
    public void onInterrupt() {
        Log.d(TAG, "Service interrupted");
    }

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        Log.d(TAG, "Accessibility Service Connected");
    }

    // 設定鎖定狀態的靜態方法
    public static void setLocked(boolean locked) {
        isLocked = locked;
        Log.d(TAG, "Lock status changed: " + locked);
    }

    public static boolean isDeviceLocked() {
        return isLocked;
    }
}
