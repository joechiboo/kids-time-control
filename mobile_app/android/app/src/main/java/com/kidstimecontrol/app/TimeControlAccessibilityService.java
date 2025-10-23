package com.kidstimecontrol.app;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.accessibility.AccessibilityEvent;
import android.widget.Button;
import android.widget.TextView;
import androidx.core.app.NotificationCompat;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

public class TimeControlAccessibilityService extends AccessibilityService {
    private static final String TAG = "TimeControlService";
    private static final String CHANNEL_ID = "time_control_channel";
    private static final int NOTIFICATION_ID = 1001;

    private WindowManager windowManager;
    private View blockingView;
    private boolean isBlocking = false;
    private SharedPreferences prefs;
    private Map<String, Long> appUsageMap = new HashMap<>();
    private String currentApp = "";
    private long currentAppStartTime = 0;
    private Timer usageTimer;
    private Handler mainHandler;

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        prefs = getSharedPreferences("time_control_prefs", Context.MODE_PRIVATE);
        mainHandler = new Handler(Looper.getMainLooper());
        createNotificationChannel();
        startForegroundService();
        startUsageTracking();
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            ComponentName componentName = new ComponentName(
                event.getPackageName().toString(),
                event.getClassName().toString()
            );

            String packageName = componentName.getPackageName();

            // Track app usage
            trackAppUsage(packageName);

            // Check if should block
            if (shouldBlockApp(packageName) && !isBlocking) {
                showBlockingScreen();
            } else if (!shouldBlockApp(packageName) && isBlocking) {
                hideBlockingScreen();
            }

            // Send usage update to Flutter
            sendUsageUpdate(packageName);
        }
    }

    private void trackAppUsage(String packageName) {
        long currentTime = System.currentTimeMillis();

        // Save previous app usage time
        if (!currentApp.isEmpty() && currentAppStartTime > 0) {
            long usageTime = currentTime - currentAppStartTime;
            long totalUsage = appUsageMap.getOrDefault(currentApp, 0L);
            appUsageMap.put(currentApp, totalUsage + usageTime);
        }

        // Start tracking new app
        currentApp = packageName;
        currentAppStartTime = currentTime;
    }

    private boolean shouldBlockApp(String packageName) {
        // Check if device is locked (time limit reached)
        boolean isDeviceLocked = prefs.getBoolean("device_locked", false);
        if (isDeviceLocked) {
            // Allow only system apps and our app
            return !isSystemApp(packageName) && !packageName.equals(getPackageName());
        }

        // Check daily time limit
        long dailyLimitMinutes = prefs.getLong("daily_limit_minutes", 120); // Default 2 hours
        long todayUsageMinutes = getTodayUsageMinutes();
        if (todayUsageMinutes >= dailyLimitMinutes) {
            return true;
        }

        // Check blocked time periods
        if (isInBlockedPeriod()) {
            return true;
        }

        // Check app category limits
        String appCategory = getAppCategory(packageName);
        long categoryLimitMinutes = prefs.getLong("limit_" + appCategory, -1);
        if (categoryLimitMinutes > 0) {
            long categoryUsageMinutes = getCategoryUsageMinutes(appCategory);
            if (categoryUsageMinutes >= categoryLimitMinutes) {
                return true;
            }
        }

        return false;
    }

    private void showBlockingScreen() {
        if (isBlocking) return;

        mainHandler.post(() -> {
            try {
                // Inflate blocking view
                LayoutInflater inflater = LayoutInflater.from(this);
                blockingView = inflater.inflate(R.layout.blocking_screen, null);

                // Setup view content
                TextView messageText = blockingView.findViewById(R.id.message_text);
                messageText.setText("時間到囉！\n該休息一下了");

                Button requestButton = blockingView.findViewById(R.id.request_more_time);
                requestButton.setOnClickListener(v -> requestMoreTime());

                // Setup window parameters
                WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                    WindowManager.LayoutParams.MATCH_PARENT,
                    WindowManager.LayoutParams.MATCH_PARENT,
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                        WindowManager.LayoutParams.TYPE_PHONE,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL |
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                    PixelFormat.TRANSLUCENT
                );

                params.gravity = Gravity.CENTER;

                // Add view to window
                windowManager.addView(blockingView, params);
                isBlocking = true;

                // Notify Flutter app
                sendBlockingStatus(true);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void hideBlockingScreen() {
        if (!isBlocking || blockingView == null) return;

        mainHandler.post(() -> {
            try {
                windowManager.removeView(blockingView);
                blockingView = null;
                isBlocking = false;

                // Notify Flutter app
                sendBlockingStatus(false);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void requestMoreTime() {
        // Send request to parent through Flutter app
        Intent intent = new Intent("com.kidstimecontrol.REQUEST_MORE_TIME");
        sendBroadcast(intent);
    }

    private void sendUsageUpdate(String packageName) {
        Intent intent = new Intent("com.kidstimecontrol.USAGE_UPDATE");
        intent.putExtra("package_name", packageName);
        intent.putExtra("timestamp", System.currentTimeMillis());
        sendBroadcast(intent);
    }

    private void sendBlockingStatus(boolean isBlocking) {
        Intent intent = new Intent("com.kidstimecontrol.BLOCKING_STATUS");
        intent.putExtra("is_blocking", isBlocking);
        sendBroadcast(intent);
    }

    private boolean isSystemApp(String packageName) {
        try {
            PackageManager pm = getPackageManager();
            return (pm.getApplicationInfo(packageName, 0).flags &
                    android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    private long getTodayUsageMinutes() {
        long totalMillis = 0;
        for (Long usage : appUsageMap.values()) {
            totalMillis += usage;
        }
        return totalMillis / 60000; // Convert to minutes
    }

    private boolean isInBlockedPeriod() {
        // Check if current time is in blocked period
        // This would check against stored time rules
        return false; // Placeholder
    }

    private String getAppCategory(String packageName) {
        // Categorize apps (game, social, education, etc.)
        // This would use a predefined mapping or API
        if (packageName.contains("game")) return "game";
        if (packageName.contains("youtube") || packageName.contains("netflix")) return "video";
        if (packageName.contains("facebook") || packageName.contains("instagram")) return "social";
        return "other";
    }

    private long getCategoryUsageMinutes(String category) {
        // Calculate total usage for a category
        long totalMillis = 0;
        for (Map.Entry<String, Long> entry : appUsageMap.entrySet()) {
            if (getAppCategory(entry.getKey()).equals(category)) {
                totalMillis += entry.getValue();
            }
        }
        return totalMillis / 60000;
    }

    private void startUsageTracking() {
        usageTimer = new Timer();
        usageTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                // Send periodic usage updates
                mainHandler.post(() -> {
                    if (!currentApp.isEmpty()) {
                        long usage = getTodayUsageMinutes();
                        Intent intent = new Intent("com.kidstimecontrol.USAGE_STATS");
                        intent.putExtra("total_minutes", usage);
                        sendBroadcast(intent);
                    }
                });
            }
        }, 0, 60000); // Update every minute
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Time Control Service",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Monitoring app usage time");
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void startForegroundService() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0,
            notificationIntent, PendingIntent.FLAG_IMMUTABLE);

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("時間控制服務運行中")
            .setContentText("正在監控應用程式使用時間")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .build();

        startForeground(NOTIFICATION_ID, notification);
    }

    @Override
    public void onInterrupt() {
        // Service interrupted
        if (usageTimer != null) {
            usageTimer.cancel();
        }
        hideBlockingScreen();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (usageTimer != null) {
            usageTimer.cancel();
        }
        hideBlockingScreen();
    }

    @Override
    protected void onServiceConnected() {
        AccessibilityServiceInfo info = getServiceInfo();
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED;
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS;
        setServiceInfo(info);
    }
}