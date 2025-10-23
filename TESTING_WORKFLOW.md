# Kids Time Control - 測試流程文件

## 🎯 測試目標

驗證「時間到自動鎖定螢幕」這個核心功能是否正常運作。

---

## 📋 前置準備檢查清單

### 開發環境
- [x] Node.js 已安裝
- [x] Flutter SDK 已安裝 (位置: `C:\Flutter\flutter\bin`)
- [ ] Android Studio 已安裝（選用，如需使用模擬器）
- [x] VS Code + Flutter 擴充套件

### 測試裝置
- [ ] Android 實體手機（已開啟 USB 偵錯）
- [ ] 或 Android 模擬器

### 環境變數
- [ ] `C:\Flutter\flutter\bin` 已加入 PATH

---

## 🚀 完整測試流程

### 步驟 1: 啟動後端服務

```bash
# 進入後端目錄
cd backend

# 確認依賴已安裝
npm install

# 啟動開發伺服器
npm run dev
```

**預期結果**：
- 終端機顯示: `Server running on port 3000`
- 可訪問: http://localhost:3000/health

**檢查點**：
```bash
# 測試 API 是否運作
curl http://localhost:3000/api/health
# 應該返回: {"status":"ok","timestamp":"..."}
```

---

### 步驟 2: 準備 Android 手機

#### 2.1 開啟開發者模式
1. 進入手機「設定」
2. 找到「關於手機」
3. 連續點擊「版本號碼」7 次
4. 出現「您已成為開發人員」訊息

#### 2.2 開啟 USB 偵錯
1. 返回「設定」
2. 進入「開發者選項」
3. 開啟「USB 偵錯」
4. 用 USB 線連接電腦
5. 手機會彈出「允許 USB 偵錯」提示，點選「允許」

#### 2.3 驗證裝置連接
```bash
# 使用 PowerShell 執行
C:\Flutter\flutter\bin\flutter.bat devices
```

**預期結果**：
應該看到您的手機出現在列表中，例如：
```
Found 2 connected devices:
  SM G973F (mobile) • 1234567890 • android-arm64 • Android 11 (API 30)
  Chrome (web)      • chrome     • web-javascript • Google Chrome
```

---

### 步驟 3: 安裝 Flutter App

```bash
# 進入 Flutter 專案目錄
cd mobile_app

# 安裝依賴
C:\Flutter\flutter\bin\flutter.bat pub get

# 安裝到連接的 Android 手機
C:\Flutter\flutter\bin\flutter.bat run
```

**編譯時間**：首次編譯約需 3-5 分鐘

**預期結果**：
- App 自動安裝到手機
- App 自動啟動並顯示主畫面

**常見錯誤處理**：
- 如果出現 Gradle 錯誤：等待自動下載完成
- 如果連接中斷：檢查 USB 連接，重新執行 `flutter run`

---

### 步驟 4: 授予必要權限（重要！）

#### 4.1 啟用 Accessibility Service
這是最關鍵的步驟！

1. 開啟手機「設定」
2. 搜尋「協助工具」或「無障礙」(Accessibility)
3. 下拉找到「已下載的服務」或「已安裝的服務」
4. 找到「Kids Time Control」
5. **點擊進入並開啟開關**
6. 閱讀權限說明後，點選「允許」

**驗證方式**：
- 返回 App，應該會顯示「服務已啟用」
- 如果未啟用，App 會提示您前往設定

#### 4.2 授予懸浮視窗權限
1. 進入「設定」> 「應用程式」> 「Kids Time Control」
2. 點選「進階」或「其他權限」
3. 找到「顯示在其他應用程式上方」
4. 開啟權限

#### 4.3 授予通知權限
- App 首次啟動時會自動請求
- 點選「允許」

#### 4.4 電池優化設定（防止被系統清理）
1. 「設定」> 「電池」> 「電池優化」
2. 找到「Kids Time Control」
3. 選擇「不要優化」

---

### 步驟 5: 測試基本功能

#### 測試 A：時間限制功能

**設定短時間方便測試**：

1. 在 App 主畫面
2. （目前版本）手動修改 SharedPreferences 或程式碼設定限制為 3 分鐘
3. 或等待完整設定介面開發完成

**測試步驟**：
1. 記錄當前時間
2. 開啟其他 App（如 Chrome、遊戲）
3. 使用 3 分鐘
4. 觀察是否出現鎖定畫面

**預期結果**：
- 時間到達時，螢幕上會覆蓋一個全螢幕鎖定畫面
- 畫面顯示「時間到囉！該休息一下了」
- 有「申請延長時間」按鈕
- 無法返回或使用其他 App

#### 測試 B：使用時間追蹤

1. 開啟 App 查看「今日統計」
2. 使用不同 App 一段時間
3. 返回 App 確認使用時間是否更新

**預期結果**：
- 使用時間每分鐘更新
- 圓形計時器正確顯示剩餘時間
- 統計卡片顯示分類使用時間

#### 測試 C：鎖定畫面功能

**測試鎖定畫面是否無法繞過**：

1. 觸發鎖定後
2. 嘗試按 Home 鍵
3. 嘗試按返回鍵
4. 嘗試開啟其他 App

**預期結果**：
- 每次開啟其他 App 時，鎖定畫面會立即再次出現
- 只有 Kids Time Control App 本身和系統 App 可以使用

#### 測試 D：申請延長時間

1. 在鎖定畫面點擊「申請延長時間」
2. 查看 App 是否發送申請

**預期結果**：
- 顯示「已向家長發送申請」訊息
- （未來）家長端收到通知

---

### 步驟 6: WebSocket 即時通訊測試（進階）

#### 測試即時鎖定

**準備**：
1. 確保後端服務運行中
2. 確保手機和電腦在同一網路

**測試步驟**：
1. 使用 Postman 或瀏覽器開發者工具
2. 連接 WebSocket: `ws://localhost:3000`
3. 發送鎖定指令:
```json
{
  "event": "device:lock",
  "data": {
    "childId": "test-child-id",
    "reason": "Parent locked"
  }
}
```

**預期結果**：
- 手機立即顯示鎖定畫面
- 無需等待時間到達

---

## 🐛 常見問題排查

### Q1: Accessibility Service 無法啟用

**症狀**：在設定中找不到 Kids Time Control 服務

**解決方案**：
1. 確認 App 已完整安裝
2. 重新安裝 App
3. 重啟手機
4. 檢查 `AndroidManifest.xml` 中的服務註冊是否正確

**驗證命令**：
```bash
# 檢查服務是否註冊
adb shell dumpsys accessibility | grep -i kids
```

### Q2: 鎖定畫面不出現

**可能原因**：
- Accessibility Service 未啟用
- 懸浮視窗權限未授予
- 服務被系統終止

**除錯步驟**：
```bash
# 查看 Android 日誌
adb logcat | grep -i "TimeControl"

# 檢查 Flutter 日誌
C:\Flutter\flutter\bin\flutter.bat logs
```

**檢查點**：
1. App 設定中確認所有權限已授予
2. 檢查電池優化是否已關閉
3. 重新啟用 Accessibility Service

### Q3: 時間統計不準確

**可能原因**：
- 背景服務被清理
- 系統限制 Accessibility Service

**解決方案**：
1. 關閉省電模式
2. 將 App 加入電池優化白名單
3. 某些手機廠商（如小米、華為）需要額外設定自啟動權限

### Q4: WebSocket 連接失敗

**症狀**：App 無法連接後端

**檢查清單**：
- [ ] 後端服務是否運行（`http://localhost:3000/health`）
- [ ] 手機和電腦是否在同一網路
- [ ] 防火牆是否阻擋端口 3000
- [ ] App 中的 server_url 是否設定為電腦的區域網路 IP

**取得電腦 IP**：
```bash
# Windows
ipconfig
# 查找 IPv4 位址，例如 192.168.1.100
```

**修改 App 連接位址**：
在 App 中設定：`http://192.168.1.100:3000`

### Q5: App 閃退

**除錯方式**：
```bash
# 即時查看崩潰日誌
adb logcat | grep -E "AndroidRuntime|Flutter"
```

**常見錯誤**：
- NullPointerException：檢查 SharedPreferences 初始化
- SecurityException：檢查權限是否授予
- WindowManager.BadTokenException：檢查懸浮視窗權限

---

## 📊 測試結果記錄表

複製以下表格記錄測試結果：

```markdown
## 測試日期：____/____/____
## 測試人員：__________
## 手機型號：__________
## Android 版本：__________

| 測試項目 | 預期結果 | 實際結果 | 通過/失敗 | 備註 |
|---------|---------|---------|----------|------|
| 後端服務啟動 | 顯示 port 3000 | | ☐ Pass ☐ Fail | |
| Flutter 裝置偵測 | 顯示手機 | | ☐ Pass ☐ Fail | |
| App 安裝 | 成功安裝 | | ☐ Pass ☐ Fail | |
| Accessibility 啟用 | 服務運行 | | ☐ Pass ☐ Fail | |
| 懸浮視窗權限 | 已授予 | | ☐ Pass ☐ Fail | |
| 時間限制功能 | 時間到鎖定 | | ☐ Pass ☐ Fail | |
| 鎖定畫面顯示 | 全螢幕覆蓋 | | ☐ Pass ☐ Fail | |
| 無法繞過鎖定 | 其他 App 被阻擋 | | ☐ Pass ☐ Fail | |
| 使用時間統計 | 準確追蹤 | | ☐ Pass ☐ Fail | |
| 申請延長時間 | 顯示申請訊息 | | ☐ Pass ☐ Fail | |
| WebSocket 連接 | 成功連接 | | ☐ Pass ☐ Fail | |
| 即時鎖定指令 | 立即鎖定 | | ☐ Pass ☐ Fail | |
```

---

## 🎬 快速測試腳本（進階使用者）

建立 `test.sh` 腳本快速執行測試：

```bash
#!/bin/bash
echo "🚀 Kids Time Control 自動化測試腳本"
echo ""

# 1. 檢查後端
echo "📡 檢查後端服務..."
curl -s http://localhost:3000/health && echo "✅ 後端正常" || echo "❌ 後端未運行"
echo ""

# 2. 檢查 Flutter 裝置
echo "📱 檢查連接裝置..."
C:\Flutter\flutter\bin\flutter.bat devices
echo ""

# 3. 安裝並運行 App
echo "🔧 安裝 App..."
cd mobile_app
C:\Flutter\flutter\bin\flutter.bat install
echo ""

# 4. 顯示日誌
echo "📋 開始監控日誌..."
C:\Flutter\flutter\bin\flutter.bat logs
```

---

## 📱 iOS 測試流程（iPhone 7）

### 注意事項
iOS 的限制較多，需要不同的測試方法。

### 前置準備
- [ ] macOS 或 Windows + iTunes
- [ ] Apple 開發者帳號（免費帳號可用於測試）
- [ ] Xcode 命令列工具

### 基礎測試步驟

1. **連接 iPhone 7**
```bash
# 檢查裝置
C:\Flutter\flutter\bin\flutter.bat devices
```

2. **安裝 App**
```bash
cd mobile_app
C:\Flutter\flutter\bin\flutter.bat run -d <device-id>
```

3. **信任開發者證書**
   - 設定 > 一般 > VPN 與裝置管理
   - 點選開發者憑證
   - 點選「信任」

### 限制說明
- iOS 無法使用 Accessibility Service
- 需要使用 Screen Time API（需要家庭共享設定）
- 完整功能需要 iOS 14.0+

---

## 🔄 下次測試準備

每次測試前檢查：

1. **程式碼更新**
```bash
git pull
cd backend && npm install
cd mobile_app && C:\Flutter\flutter\bin\flutter.bat pub get
```

2. **清理舊資料**
```bash
# 清除 App 資料（在手機上）
# 設定 > 應用程式 > Kids Time Control > 儲存空間 > 清除資料
```

3. **重新安裝**
```bash
cd mobile_app
C:\Flutter\flutter\bin\flutter.bat clean
C:\Flutter\flutter\bin\flutter.bat run
```

---

## 📞 需要協助？

如果遇到問題：

1. 查看本文件的「常見問題排查」章節
2. 檢查日誌檔案
3. 記錄錯誤訊息和螢幕截圖
4. 提供測試環境資訊（手機型號、Android 版本等）

---

**祝測試順利！🎉**

最後更新：2025-10-23