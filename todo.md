# Kids Time Control - 待辦事項

## 🔥 當前最重要任務

### 螢幕鎖定機制修正（依優先順序測試）

#### 方案 1: Screen Pinning API（優先）
- [ ] 實作 `startLockTask()` 在鎖定時自動固定 App
- [ ] 測試能否防止上滑和切換 App
- ✅ 優點：原生 API、不需額外權限、使用者體驗好
- ⚠️ 缺點：需要使用者同意、可能被解除

#### 方案 2: Accessibility Service 強化（次要）
- [ ] 監控 `TYPE_WINDOW_STATE_CHANGED` 事件
- [ ] 偵測到切換時立即帶回前台
- [ ] 加上全螢幕 FLAG 和防止上滑的 Window Flags
- ✅ 優點：不需使用者額外操作
- ⚠️ 缺點：可能被系統限制、體驗較差

#### 方案 3: Foreground Service + Overlay（備選）
- [ ] 建立 Foreground Service 確保服務不被殺
- [ ] 使用 `TYPE_APPLICATION_OVERLAY` 覆蓋整個畫面
- [ ] 攔截所有觸控和系統手勢
- ✅ 優點：控制力強
- ⚠️ 缺點：需要 SYSTEM_ALERT_WINDOW 權限、可能被拒絕

#### 方案 4: Kiosk Mode (Device Owner)（最後手段）
- [ ] 研究如何設定 Device Owner
- [ ] 實作 `lockTaskMode` 完全鎖定
- ✅ 優點：最徹底的鎖定
- ⚠️ 缺點：需要 factory reset 或 ADB 設定、使用者門檻高

---

## 📋 下一步

1. 完成 POC 測試並確認鎖定機制可行
2. 更新基本文件 (README)
3. 繼續教育導向重構

---

## 📚 長期計畫

詳見 [REFACTORING_PLAN.md](REFACTORING_PLAN.md)
