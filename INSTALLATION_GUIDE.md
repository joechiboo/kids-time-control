# Kids Time Control - 安裝與測試指南

## 📱 Android 測試步驟

### 1. 環境準備

#### 必要軟體
- Node.js 18+
- Android Studio
- Flutter SDK 3.0+
- PostgreSQL 14+ (可選，測試可先跳過)

### 2. 後端服務啟動

```bash
# 進入後端目錄
cd backend

# 安裝依賴
npm install

# 複製環境設定檔
cp .env.example .env

# 編輯 .env 檔案，設定必要參數
# 如果只是測試，可以先使用預設值

# 啟動開發伺服器
npm run dev
```

伺服器會在 http://localhost:3000 啟動

### 3. Android App 安裝

#### 方式一：使用 Flutter CLI (推薦)

```bash
# 進入 Flutter 專案目錄
cd mobile_app

# 取得依賴套件
flutter pub get

# 連接您的 Android 手機（需開啟開發者模式和 USB 偵錯）

# 確認裝置已連接
flutter devices

# 安裝並執行 App
flutter run
```

#### 方式二：使用 Android Studio

1. 開啟 Android Studio
2. 選擇 "Open" 並選擇 `mobile_app` 資料夾
3. 等待 Gradle 同步完成
4. 連接 Android 手機或啟動模擬器
5. 點擊 Run 按鈕

### 4. 啟用 Accessibility Service

**重要：這是核心功能，必須手動啟用**

1. 安裝 App 後，開啟手機的「設定」
2. 進入「協助工具」或「無障礙」(Accessibility)
3. 找到「Kids Time Control」
4. 開啟服務開關
5. 確認權限提示

### 5. 授予必要權限

App 首次啟動時會要求以下權限：

1. **懸浮視窗權限** (Display over other apps)
   - 用於顯示鎖定畫面
   - 設定 > 應用程式 > Kids Time Control > 進階 > 顯示在其他應用程式上方

2. **通知權限**
   - 用於發送時間提醒

3. **背景執行權限**
   - 確保 App 不被系統清理

### 6. 基本功能測試

#### 測試時間限制
1. 在 App 中設定每日使用時間為 5 分鐘（方便測試）
2. 開啟其他 App 使用
3. 等待 5 分鐘後，應該會看到鎖定畫面

#### 測試即時鎖定
1. 開啟 App
2. 點擊「立即鎖定」按鈕
3. 裝置應該立即顯示鎖定畫面

#### 測試解鎖
1. 在鎖定狀態下
2. 點擊「申請延長時間」
3. （目前需要手動在 App 中批准）

## 🍎 iOS 測試步驟（iPhone 7）

### 注意事項
iOS 的限制較多，需要使用 Screen Time API 和家庭共享功能。完整功能需要：
- iOS 14.0+
- 開發者帳號
- 家庭共享設定

### 基礎設定
1. 確保 iPhone 7 已更新至支援的 iOS 版本
2. 在「設定」>「螢幕使用時間」中啟用
3. 設定為「兒童帳號」（如果要測試家長控制）

### 目前限制
- iOS 版本的完整功能還在開發中
- 可以先使用內建的 Screen Time 配合 App 做基礎測試

## 🐛 常見問題

### Q1: Accessibility Service 無法啟用
**解決方案：**
1. 確認 App 已正確安裝
2. 重啟手機
3. 檢查是否有其他 Accessibility 服務衝突

### Q2: 鎖定畫面不出現
**解決方案：**
1. 檢查懸浮視窗權限是否已授予
2. 確認 Accessibility Service 是否運行中
3. 查看 App 內的服務狀態

### Q3: 時間統計不準確
**解決方案：**
1. 確保 App 有背景執行權限
2. 關閉省電模式
3. 將 App 加入電池優化白名單

### Q4: 無法連接到後端服務
**解決方案：**
1. 確認後端服務已啟動
2. 檢查手機和電腦在同一網路
3. 在 App 設定中修改伺服器地址為電腦的區域網路 IP

## 📊 測試檢查清單

- [ ] 後端服務正常啟動
- [ ] Android App 成功安裝
- [ ] Accessibility Service 已啟用
- [ ] 懸浮視窗權限已授予
- [ ] 時間限制功能正常
- [ ] 鎖定畫面正確顯示
- [ ] 申請延長時間功能正常
- [ ] 使用時間統計準確
- [ ] WebSocket 連接正常
- [ ] 通知功能正常

## 💡 開發建議

1. **測試環境**：建議使用實體 Android 手機測試，模擬器可能無法完整測試 Accessibility 功能

2. **除錯方式**：
   ```bash
   # 查看 Flutter 日誌
   flutter logs

   # 查看 Android 系統日誌
   adb logcat | grep -i kids
   ```

3. **快速重置**：如需重置測試狀態，可以：
   - 清除 App 資料
   - 重新啟用 Accessibility Service

## 📞 需要協助？

如果遇到問題，請提供以下資訊：
- Android 版本
- 手機型號
- 錯誤訊息截圖
- Flutter 和 Android 日誌

---

**Happy Testing! 🚀**