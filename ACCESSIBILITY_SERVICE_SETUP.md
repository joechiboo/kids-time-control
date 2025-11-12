# 無障礙服務設定指南

## 什麼是無障礙服務？

無障礙服務（Accessibility Service）是 Android 提供的系統功能，原本是為了協助視障或行動不便的使用者。Kids Time Control 使用這個服務來：

- **監控 App 使用狀態**：偵測小孩是否切換到其他 App
- **自動鎖定功能**：時間到時自動將小孩帶回 App
- **防止繞過機制**：確保時間控制有效執行

---

## 為什麼需要啟用？

如果不啟用無障礙服務：
- ❌ 無法偵測小孩切換到其他 App
- ❌ 鎖定功能會被輕易繞過
- ❌ 時間控制形同虛設

啟用後：
- ✅ App 可以知道小孩正在使用哪個 App
- ✅ 鎖定時可以自動將 App 帶回前台
- ✅ 防止小孩繞過時間限制

---

## 啟用步驟（圖文教學）

### 方法 1：從 App 內直接開啟（推薦）

1. **開啟 Kids Time Control App**

2. **啟用開發者模式**
   - 快速點擊「你好！」文字 **2 次**
   - 快速點擊「數位健康提醒」卡片（紫藍色）**2 次**
   - 必須在 3 秒內完成
   - 看到提示「開發者模式已開啟」

3. **查看無障礙服務狀態**
   - 往下滑到「測試控制」區塊
   - 查看「無障礙服務」顯示：
     - ✅ **已啟用**：可以直接測試
     - ❌ **未啟用**：繼續下一步

4. **開啟無障礙設定**
   - 點擊「開啟無障礙設定」按鈕
   - 手機會自動跳轉到設定頁面

5. **啟用服務**
   - 在無障礙設定中找到：
     - 「**Kids Time Control**」
     - 或「**Lock Accessibility Service**」
   - 點擊進入
   - 打開開關（從關閉變成開啟）

6. **確認警告訊息**
   - 系統會顯示警告：
     > 「此 App 將能夠：
     > - 觀察您的動作
     > - 擷取您的內容
     > - 查看您螢幕上的內容」
   - 這是正常的，點「**確定**」或「**允許**」

7. **返回 App 確認**
   - 按返回鍵回到 Kids Time Control
   - 確認顯示「✅ 已啟用」

### 方法 2：從手機設定手動開啟

如果方法 1 無法使用：

1. **開啟手機設定**
2. **找到無障礙設定**
   - 可能的路徑：
     - 設定 > 無障礙
     - 設定 > 輔助功能
     - 設定 > 協助工具
     - Settings > Accessibility
3. **找到已安裝的服務**
   - 往下滑找到「已下載的服務」或「已安裝的服務」
4. **啟用 Kids Time Control**
   - 找到「Kids Time Control」或「Lock Accessibility Service」
   - 打開開關
   - 確認警告訊息

---

## 常見問題

### Q: 找不到無障礙服務選項？

**解決方式：**
1. 確認 App 已正確安裝
2. 重新安裝 App
3. 重啟手機後再試一次

### Q: 打開開關後自動關閉？

**可能原因：**
1. App 的服務設定有誤
2. 系統權限不足

**解決方式：**
1. 檢查 Logcat 錯誤訊息
2. 確認 `AndroidManifest.xml` 中有正確設定
3. 重新編譯並安裝 App

### Q: 系統警告很嚇人，真的要開啟嗎？

**說明：**
- Android 對所有無障礙服務都會顯示這個警告
- 這是 Google 的安全機制
- Kids Time Control 只會監控 App 切換，不會竊取個人資料
- 原始碼是開放的，可以自行檢視

### Q: 無障礙服務會耗電嗎？

**說明：**
- 會有輕微的電池消耗
- 因為需要持續監控系統狀態
- 但消耗非常小，通常不會明顯影響電池續航

### Q: 可以只在鎖定時才啟用嗎？

**說明：**
- 理論上可以，但技術上比較複雜
- 目前的實作是一直保持啟用
- 只有在真正鎖定時才會執行攔截動作

---

## 檢查無障礙服務是否正常運作

### 透過 App 檢查

1. 開啟開發者模式
2. 查看「無障礙服務」狀態
   - ✅ **已啟用**：服務正常運作
   - ❌ **未啟用**：需要重新啟用

### 透過系統檢查

1. 開啟手機設定 > 無障礙
2. 找到 Kids Time Control
3. 確認開關是**開啟**狀態

### 透過 Logcat 檢查（進階）

如果手機連接電腦並執行 `flutter run`：

1. 查看終端輸出
2. 搜尋 `LockAccessibilityService`
3. 確認有以下訊息：
   ```
   I/LockAccessibilityService: Service connected
   ```

---

## 如何關閉無障礙服務

如果不再使用 Kids Time Control：

1. 開啟手機設定 > 無障礙
2. 找到 Kids Time Control
3. 關閉開關
4. 或直接解除安裝 App（會自動移除服務）

---

## 隱私與安全性

### Kids Time Control 會收集什麼資料？

- ✅ **會記錄**：使用時間、鎖定狀態
- ❌ **不會記錄**：螢幕內容、鍵盤輸入、個人訊息

### 資料會傳送到哪裡？

- 所有資料都儲存在**本機手機**
- 不會上傳到雲端
- 不會傳送給第三方

### 如何驗證？

- 專案原始碼完全開放
- 可在 GitHub 上查看所有程式碼
- 歡迎自行檢視或請專業人士協助審查

---

## 技術細節（開發者）

### 服務宣告位置

- 檔案：`mobile_app/android/app/src/main/AndroidManifest.xml`
- 服務類別：`LockAccessibilityService.java`

### 權限說明

```xml
<service
    android:name=".LockAccessibilityService"
    android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>
</service>
```

### 監控事件

- `TYPE_WINDOW_STATE_CHANGED`：視窗狀態改變
- `TYPE_WINDOW_CONTENT_CHANGED`：視窗內容改變

### 相關文件

- [Android Accessibility Service 官方文件](https://developer.android.com/reference/android/accessibilityservice/AccessibilityService)
- [DEVELOPER_MODE.md](DEVELOPER_MODE.md) - 開發者模式啟用指南
- [SCREEN_LOCK_TEST.md](SCREEN_LOCK_TEST.md) - 螢幕鎖定測試流程

---

**最後更新**：2025-11-11
