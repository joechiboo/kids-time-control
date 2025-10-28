# Kids Time Control - 兒童數位健康控制系統

一個幫助家長管理孩童數位裝置使用時間的完整解決方案，透過正向激勵機制（積分獎勵）取代單純的限制，培養孩子自主管理時間的能力。

## 🎯 專案特色

### 核心功能
- **⏰ 智慧時間管理**
  - 每日使用時間限額控制（預設 120 分鐘）
  - 使用時才進行倒數計時
  - 每天 00:00 自動重設時間額度
  - 時間用完自動鎖定裝置
  - 手動鎖定/解鎖功能（開發者模式）
- **💚 數位健康提醒**
  - 學齡前兒童 3C 使用建議（每日不超過 2 小時）
  - 視覺化提醒卡片設計
- **🔧 開發者模式**
  - 隱藏手勢啟動（標題點 2 次 + 健康卡片點 2 次）
  - 測試控制：手動鎖定/解鎖裝置
  - 防止孩童誤觸測試功能
- **🎮 積分任務系統** - 完成任務賺取積分，培養良好習慣
- **🏆 獎勵商城** - 用積分兌換虛擬/實體獎勵，激發動力
- **📊 數據統計分析** - 視覺化使用報表，掌握孩子使用習慣
- **🔔 即時通知提醒** - 超時警告、任務提醒，保持良好溝通

### 技術亮點
- **跨平台支援** - Android (Accessibility Service) / iOS (Screen Time API)
- **即時同步** - WebSocket 實現多裝置即時狀態同步
- **雙端應用** - Vue.js 家長管理端 + Flutter 孩童互動端
- **安全可靠** - 尊重隱私，不追蹤個人內容

## 🚀 快速開始

### 系統需求
- Node.js 18+
- PostgreSQL 14+
- Redis 6+
- Flutter 3.0+
- Android Studio / Xcode (開發環境)

### 安裝步驟

```bash
# Clone 專案
git clone https://github.com/joechiboo/kids-time-control.git
cd kids-time-control

# 安裝後端依賴
cd backend
npm install
cp .env.example .env  # 設定環境變數
npm run db:migrate     # 執行資料庫遷移
npm run dev           # 啟動開發伺服器

# 安裝前端依賴（家長端）
cd ../frontend-parent
npm install
npm run dev

# 安裝 Flutter App（孩童端）
cd ../mobile-child
flutter pub get
flutter run
```

## 📱 使用場景

### 👨‍👩‍👧‍👦 家長視角
1. **設定規則** - 為每個孩子客製化螢幕時間限制
2. **即時監控** - 查看孩子當前使用狀態與統計
3. **任務管理** - 創建日常任務，設定積分獎勵
4. **獎勵審核** - 管理獎勵商城，審核兌換申請

### 👦👧 孩童視角
1. **時間查看** - 清楚知道剩餘使用時間
2. **完成任務** - 做家事、運動、學習賺積分
3. **兌換獎勵** - 用積分換取想要的獎勵
4. **成就收集** - 解鎖成就徽章，提升等級

## 🛠️ 技術架構

```
┌──────────────────────┬──────────────────────────────┐
│   Vue 家長端 Web     │     Flutter 孩童端 App       │
└──────────┬───────────┴──────────────┬──────────────┘
           ↓                          ↓
┌─────────────────────────────────────────────────────┐
│            Express + Socket.io API                   │
└─────────────────────────────────────────────────────┘
           ↓                          ↓
┌──────────────────────┬──────────────────────────────┐
│    PostgreSQL        │       Redis Cache             │
└──────────────────────┴──────────────────────────────┘
```

## 📈 開發進度

### 階段 1: MVP ✅
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

### 階段 2: 積分系統 🚧
- [ ] 任務管理系統
- [ ] 積分計算邏輯
- [ ] 任務完成驗證

### 階段 3: 獎勵商城 📋
- [ ] 商品管理
- [ ] 兌換流程
- [ ] 虛擬獎勵

### 階段 4: iOS 支援 📋
- [ ] Screen Time API 整合
- [ ] 跨平台同步

## 🤝 貢獻指南

我們歡迎所有形式的貢獻！請查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解詳情。

### 開發流程
1. Fork 專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權

本專案採用 MIT 授權條款 - 查看 [LICENSE](LICENSE) 檔案了解詳情

## 📞 聯絡資訊

- 專案連結: [https://github.com/joechiboo/kids-time-control](https://github.com/joechiboo/kids-time-control)
- 問題回報: [Issues](https://github.com/joechiboo/kids-time-control/issues)

## 🙏 致謝

感謝所有為這個專案貢獻的開發者和使用者的回饋！

---

**打造健康的數位生活，從管理螢幕時間開始** 💚