# Kids Time Control - 待辦事項

## 🎯 重大方向調整

專案已從「獎勵機制」轉向「教育導向」，詳見 [REFACTORING_PLAN.md](REFACTORING_PLAN.md)

**核心理念改變**：
- ❌ 移除：積分、任務、獎勵商城（遊戲化元素）
- ✅ 新增：教育內容、替代活動、親子對話工具
- ✅ 強調：建立常規、自然後果、培養內在動機、環境設計

---

## 📅 重構進度追蹤

### 階段 1：文檔與核心概念（1 週）
- [x] 更新 `.specify/memory/specification.md`
- [x] 建立 `FACEBOOK_POST.md`（教育理念說明）
- [x] 建立 `REFACTORING_PLAN.md`（完整重構計畫）
- [ ] 更新 `README.md`
- [ ] 撰寫 `EDUCATION_PHILOSOPHY.md`（教育理念與科學依據）
- [ ] 更新 `USER_GUIDE.md`
- [ ] 建立教育內容資料庫（Markdown 格式）
- [ ] 建立替代活動資料庫（Markdown 格式）

### 階段 2：後端 API 重構（2 週）
- [ ] 備份現有資料庫
- [ ] 刪除 tasks/points/rewards 相關 API 和模型
- [ ] 執行資料庫遷移
- [ ] 實作教育內容 API
- [ ] 實作替代活動 API
- [ ] 實作自然後果邏輯
- [ ] 實作規則討論 API
- [ ] 實作家庭活動 API
- [ ] 實作報告 API（週報、月報）

### 階段 3：行動端 UI 重構（2 週）
- [ ] 刪除任務/獎勵相關畫面
- [ ] 重新設計 `home_screen.dart`（移除積分、任務）
- [ ] 調整 `quick_stats.dart`（改為進步趨勢）
- [ ] 實作友善鎖定畫面
- [ ] 實作替代活動瀏覽
- [ ] 實作使用歷史（正向回饋）
- [ ] 實作教育內容畫面
- [ ] 更新所有文字為友善語氣

### 階段 4：家長端 Web 重構（2 週）
- [ ] 刪除任務管理和獎勵商城頁面
- [ ] 調整儀表板（移除積分、加入教育建議）
- [ ] 實作教育資源中心
- [ ] 實作家庭活動功能
- [ ] 實作報告功能（週報、月報）
- [ ] 實作家長自我追蹤
- [ ] 實作規則討論工具

### 階段 5：測試與優化（1 週）
- [ ] 端到端測試
- [ ] 語氣測試（確保友善、非懲罰）
- [ ] 家長訪談測試
- [ ] 效能優化
- [ ] Bug 修復

---

## 🔧 開發環境設置

### Flutter 環境（已完成）
- [x] Flutter SDK 安裝到 `C:\tools\flutter\bin` (v3.27.1)
- [x] 環境變數已更新
- [x] 刪除專案中異常的 `C:tools` 目錄

### 待安裝（Android 開發）
- [ ] 安裝 Android Studio
  - 下載：https://developer.android.com/studio
  - 安裝 Android SDK 元件
  - 執行 `flutter doctor --android-licenses`

### 待安裝（Windows 開發）
- [ ] 安裝 Visual Studio C++ 元件
  - MSVC v142 - VS 2019 C++ x64/x86 build tools
  - C++ CMake tools for Windows
  - Windows 10 SDK

---

## ✅ 已完成項目

### 核心功能（MVP）
- [x] 基礎認證系統
- [x] 家庭成員管理
- [x] 時間限制與倒數計時
  - [x] 每日 120 分鐘額度
  - [x] 使用時才倒數
  - [x] 每天 00:00 自動重設
  - [x] 手動鎖定/解鎖功能
- [x] 數位健康提醒
- [x] 開發者模式
  - [x] 隱藏手勢啟動（標題點 2 次 + 健康卡片點 2 次）
  - [x] 測試控制區塊
- [x] Flutter 孩童端 UI
- [x] Android 實機測試

### Android 無障礙服務
- [x] 防止上滑關掉的機制
  - [x] MainActivity 中加入 onPause 攔截
  - [x] 鎖定時自動將 app 帶回前台
  - [x] 攔截返回鍵防止關閉
- [x] 修正無障礙服務偵測
  - [x] 移除 packageNames 限制
  - [x] 可監控所有應用程式切換
- [x] 移除「解鎖裝置測試」按鈕

### UI/UX
- [x] Icon 設定（參考 `mobile_app/ICON_SETUP.md`）
- [x] 家長模式修正（給 10 分鐘後正確恢復並解鎖）

---

## 🐛 已知問題

### Android 鎖定機制
- ⚠️ 右滑可以擋、上滑擋不了
- ⚠️ 還是可以切換到別的 App（沒有完全鎖定效果）
- 💡 考慮使用 Android 數位健康內建功能

---

## 📝 重要提醒

### 環境變數
- **Flutter 路徑**：`C:\tools\flutter\bin`
- **環境變數更新後**：需完全重新開啟 VSCode/終端才會生效
- **檢查開發環境**：使用 `flutter doctor -v` 查看詳細狀態

### 開發原則（新）
根據新的教育理念，開發時需注意：
1. **語氣**：友善、溫暖、正向（避免懲罰性文字）
2. **視覺**：柔和配色、圓潤圖示（避免警告標誌）
3. **功能**：引導而非控制、教育而非限制

---

## 📚 相關文件

- [REFACTORING_PLAN.md](REFACTORING_PLAN.md) - 完整重構計畫（8週）
- [FACEBOOK_POST.md](FACEBOOK_POST.md) - 專案理念說明
- [.specify/memory/specification.md](.specify/memory/specification.md) - 產品規格
- [TESTING_WORKFLOW.md](TESTING_WORKFLOW.md) - 測試流程
- [mobile_app/ICON_SETUP.md](mobile_app/ICON_SETUP.md) - Icon 設定

---

**最後更新**：2025-10-23
**當前階段**：階段 1 - 文檔與核心概念
**下一步**：完成文檔更新，準備教育內容資料庫
