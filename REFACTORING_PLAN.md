# 專案重構計畫 - 從獎勵機制到教育導向

## 📋 概述

根據新的教育理念（建立常規、自然後果、培養內在動機、環境設計），本專案需要進行重大調整，移除所有遊戲化元素，轉向教育導向的數位健康工具。

## 🎯 核心理念轉變

### 舊理念（需移除）
- ❌ 用積分獎勵激勵孩子
- ❌ 完成任務賺積分
- ❌ 積分兌換獎勵
- ❌ 遊戲化機制（徽章、等級、排行榜）

### 新理念（需實作）
- ✅ 建立日常常規（固定額度，不因表現變動）
- ✅ 自然後果法（超時扣明天額度）
- ✅ 培養內在動機（親子共同制定規則）
- ✅ 環境設計（家長以身作則，全家無螢幕時間）

---

## 📁 需要調整的檔案

### 1. 文檔類（Documentation）

#### 需要更新
- [x] `.specify/memory/specification.md` - ✅ 已完成重寫
- [x] `FACEBOOK_POST.md` - ✅ 已完成
- [ ] `README.md` - 移除積分/任務/獎勵相關內容
- [ ] `USER_GUIDE.md` - 更新使用指南
- [ ] `CHANGES_SUMMARY.md` - 記錄此次重大變更

#### 需要新增
- [ ] `EDUCATION_PHILOSOPHY.md` - 說明教育理念和科學依據
- [ ] `PARENT_GUIDE.md` - 親子對話技巧指南
- [ ] `ALTERNATIVE_ACTIVITIES.md` - 替代活動資料庫

### 2. 後端（Backend）

#### 資料模型需調整
```
backend/src/models/
├── User.js                 ✅ 保留（需微調）
├── Family.js               ✅ 保留
├── TimeRule.js             🔄 需大幅調整
├── UsageRecord.js          ✅ 保留
├── Task.js                 ❌ 刪除（不再需要）
├── Point.js                ❌ 刪除（不再需要）
├── Reward.js               ❌ 刪除（不再需要）
└── 需新增：
    ├── EducationContent.js      ✅ 新增（教育內容）
    ├── AlternativeActivity.js   ✅ 新增（替代活動）
    ├── FamilyActivity.js        ✅ 新增（家庭活動記錄）
    └── RuleAgreement.js         ✅ 新增（規則討論記錄）
```

#### API 路由需調整
```
backend/src/routes/
├── auth.js                 ✅ 保留
├── family.js               ✅ 保留
├── timeControl.js          🔄 需調整（加入自然後果邏輯）
├── usage.js                ✅ 保留（加入統計功能）
├── tasks.js                ❌ 刪除
├── points.js               ❌ 刪除
├── rewards.js              ❌ 刪除
└── 需新增：
    ├── education.js             ✅ 新增（教育內容 API）
    ├── alternatives.js          ✅ 新增（替代活動 API）
    ├── familyActivities.js      ✅ 新增（家庭活動 API）
    ├── reports.js               ✅ 新增（週報、月報）
    └── agreements.js            ✅ 新增（規則討論 API）
```

#### 資料庫遷移
```sql
-- 需要刪除的表
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS point_transactions;
DROP TABLE IF EXISTS rewards;
DROP TABLE IF EXISTS reward_redemptions;

-- 需要調整的表
ALTER TABLE time_rules
  DROP COLUMN points_per_hour,
  ADD COLUMN natural_consequences BOOLEAN DEFAULT true,
  ADD COLUMN overtime_carryover BOOLEAN DEFAULT true;

-- 需要新增的表
CREATE TABLE education_contents (...);
CREATE TABLE alternative_activities (...);
CREATE TABLE family_activities (...);
CREATE TABLE rule_agreements (...);
CREATE TABLE daily_usage_summary (...);
```

### 3. 前端 - 家長端（Frontend Parent - Vue.js）

#### 頁面需調整
```
frontend-parent/src/views/
├── Dashboard.vue           🔄 調整（移除積分相關，加入教育內容）
├── Rules.vue               🔄 大幅調整（加入親子討論工具）
├── Statistics.vue          🔄 調整（正向回饋導向）
├── TaskManagement.vue      ❌ 刪除
├── RewardShop.vue          ❌ 刪除
└── 需新增：
    ├── EducationHub.vue        ✅ 教育資源中心
    ├── FamilyActivities.vue    ✅ 家庭活動記錄
    ├── ParentTracking.vue      ✅ 家長自我追蹤
    ├── Reports.vue             ✅ 週報/月報
    └── RuleDiscussion.vue      ✅ 規則討論工具
```

#### 元件需調整
```
frontend-parent/src/components/
├── TimeChart.vue           ✅ 保留（改為正向回饋導向）
├── TaskList.vue            ❌ 刪除
├── PointsDisplay.vue       ❌ 刪除
├── RewardCard.vue          ❌ 刪除
└── 需新增：
    ├── EducationCard.vue       ✅ 教育內容卡片
    ├── TrendChart.vue          ✅ 趨勢圖表（強調進步）
    ├── ActivitySuggestion.vue  ✅ 活動建議卡片
    ├── DialogueGuide.vue       ✅ 對話引導工具
    └── FamilyTimeline.vue      ✅ 家庭時光時間軸
```

### 4. 行動端 - 孩童端（Mobile App - Flutter）

#### 畫面需調整
```
mobile_app/lib/screens/
├── home_screen.dart        🔄 大幅調整
│   現況：顯示任務、積分、獎勵
│   調整：顯示剩餘時間、使用建議、替代活動
│
├── parent_dashboard.dart   ✅ 保留
├── task_screen.dart        ❌ 刪除（整個畫面）
├── reward_shop.dart        ❌ 刪除（整個畫面）
└── 需新增：
    ├── usage_history.dart      ✅ 使用歷史（正向回饋）
    ├── activity_screen.dart    ✅ 替代活動瀏覽
    ├── progress_screen.dart    ✅ 進步追蹤
    └── education_screen.dart   ✅ 為什麼要限制？
```

#### Widget 需調整
```
mobile_app/lib/widgets/
├── circular_timer.dart     ✅ 保留（現有的很好）
├── quick_stats.dart        🔄 調整
│   現況：顯示遊戲、影片、學習時間
│   調整：顯示本週表現、連續未超時天數、進步趨勢
│
├── task_card.dart          ❌ 刪除
├── points_display.dart     ❌ 刪除
├── reward_card.dart        ❌ 刪除
└── 需新增：
    ├── friendly_reminder.dart  ✅ 友善提醒卡片
    ├── activity_card.dart      ✅ 替代活動卡片
    ├── progress_badge.dart     ✅ 進步徽章（非遊戲化）
    └── health_tip.dart         ✅ 健康小知識
```

#### 服務層需調整
```
mobile_app/lib/services/
├── time_control_service.dart  🔄 調整
│   - 加入自然後果計算
│   - 移除積分相關邏輯
│
├── socket_service.dart        ✅ 保留
├── task_service.dart          ❌ 刪除
└── 需新增：
    ├── education_service.dart     ✅ 教育內容服務
    ├── activity_service.dart      ✅ 替代活動服務
    └── report_service.dart        ✅ 報告生成服務
```

#### 資料模型需調整
```
mobile_app/lib/models/
├── time_rule.dart          🔄 調整（移除積分相關）
├── task.dart               ❌ 刪除
├── point.dart              ❌ 刪除
├── reward.dart             ❌ 刪除
└── 需新增：
    ├── education_content.dart     ✅ 教育內容模型
    ├── alternative_activity.dart  ✅ 替代活動模型
    ├── daily_summary.dart         ✅ 每日摘要模型
    └── family_activity.dart       ✅ 家庭活動模型
```

### 5. Android 原生層

#### 需調整
```
mobile_app/android/app/src/main/java/com/kidstimecontrol/app/
├── MainActivity.java                    ✅ 保留
├── AccessibilityHelper.java             ✅ 保留
├── LockAccessibilityService.java        🔄 調整
│   - 改善鎖定畫面 UI
│   - 顯示友善訊息
│   - 提供替代活動建議
│
└── 需新增：
    └── FriendlyLockScreen.java          ✅ 友善鎖定畫面
```

---

## 🗂️ 調整優先順序與時程

### 階段 1：文檔與核心概念（1 週）
**目標**：確立新方向，更新所有文檔

- [x] 更新 specification.md - ✅ 已完成
- [ ] 更新 README.md
- [ ] 撰寫 EDUCATION_PHILOSOPHY.md
- [ ] 更新 USER_GUIDE.md
- [ ] 建立教育內容資料庫（Markdown 格式）
- [ ] 建立替代活動資料庫（Markdown 格式）

**交付物**：
- 所有文檔與新理念一致
- 教育內容和替代活動資料準備好

---

### 階段 2：後端 API 重構（2 週）

#### Week 1：移除舊功能
- [ ] 備份現有資料庫
- [ ] 刪除 tasks/points/rewards 相關 API
- [ ] 刪除相關資料模型
- [ ] 執行資料庫遷移（刪除表）
- [ ] 測試既有功能（時間控制、認證）

#### Week 2：新增新功能
- [ ] 實作教育內容 API
  - [ ] GET /api/education/why-limit
  - [ ] GET /api/education/guidelines
  - [ ] GET /api/education/discussion
- [ ] 實作替代活動 API
  - [ ] GET /api/education/alternatives
  - [ ] GET /api/education/alternatives/:ageGroup
- [ ] 實作自然後果邏輯
  - [ ] 超時計算
  - [ ] 隔日額度調整
  - [ ] 每日摘要生成
- [ ] 實作規則討論 API
  - [ ] POST /api/rules/:childId/agreement
  - [ ] GET /api/rules/:childId/history
- [ ] 實作報告 API
  - [ ] GET /api/reports/weekly/:childId
  - [ ] GET /api/reports/monthly/:childId

**交付物**：
- 後端 API 完全符合新規格
- 所有舊的遊戲化 API 已移除
- 新的教育導向 API 可用

---

### 階段 3：行動端 UI 重構（2 週）

#### Week 1：移除與調整
- [ ] 刪除 task/reward 相關畫面
- [ ] 調整 home_screen.dart
  - [ ] 移除任務、積分顯示
  - [ ] 改為顯示：剩餘時間、使用建議、替代活動
- [ ] 調整 quick_stats.dart
  - [ ] 移除遊戲/影片分類統計
  - [ ] 改為：本週表現、連續未超時、進步趨勢
- [ ] 更新 time_control_service.dart
  - [ ] 加入自然後果邏輯
  - [ ] 移除積分計算

#### Week 2：新增功能
- [ ] 實作友善鎖定畫面
  - [ ] 溫暖的文字訊息
  - [ ] 替代活動建議列表
  - [ ] 明天額度提示
- [ ] 實作替代活動瀏覽
  - [ ] 依年齡分類
  - [ ] 圖文並茂
  - [ ] 可收藏喜歡的活動
- [ ] 實作使用歷史畫面
  - [ ] 趨勢圖表
  - [ ] 正向回饋文字
  - [ ] 連續未超時天數
- [ ] 實作教育內容畫面
  - [ ] 為什麼要限制？
  - [ ] 健康小知識
  - [ ] 專業建議來源

**交付物**：
- 行動端 UI 完全符合新理念
- 友善、教育導向的視覺呈現
- 無任何遊戲化元素

---

### 階段 4：家長端 Web 重構（2 週）

#### Week 1：核心功能調整
- [ ] 刪除任務管理頁面
- [ ] 刪除獎勵商城頁面
- [ ] 調整儀表板
  - [ ] 移除積分相關
  - [ ] 加入教育建議卡片
  - [ ] 加入家庭整體統計
- [ ] 調整規則設定頁面
  - [ ] 加入親子討論記錄
  - [ ] 視覺化規則呈現
  - [ ] 規則試行期設定

#### Week 2：新增功能
- [ ] 教育資源中心
  - [ ] 瀏覽教育內容
  - [ ] 親子對話技巧
  - [ ] 專業建議資源
- [ ] 家庭活動功能
  - [ ] 活動規劃工具
  - [ ] 活動記錄相簿
  - [ ] 家庭時光統計
- [ ] 報告功能
  - [ ] 每週報告生成
  - [ ] 每月報告生成
  - [ ] 強調正向回饋
- [ ] 家長自我追蹤
  - [ ] 家長螢幕時間記錄
  - [ ] 以身作則提醒
  - [ ] 全家無螢幕時間設定

**交付物**：
- 家長端完全教育導向
- 提供親子對話工具
- 家長以身作則功能

---

### 階段 5：整合測試與優化（1 週）

- [ ] 端到端測試
  - [ ] 時間控制流程
  - [ ] 自然後果機制
  - [ ] 教育內容顯示
  - [ ] 替代活動推薦
- [ ] 使用者體驗測試
  - [ ] 文字語氣確認（友善、非懲罰）
  - [ ] 視覺風格確認（溫暖、教育）
  - [ ] 流程順暢度
- [ ] 效能優化
- [ ] Bug 修復
- [ ] 文檔最終確認

**交付物**：
- 完整可用的教育導向版本
- 無遊戲化元素
- 符合所有新規格

---

## 📊 詳細功能對照表

### 首頁（Home Screen）改造

#### 舊版本（遊戲化）
```
┌─────────────────────────┐
│   剩餘時間：120 分       │
│   今日積分：150 點       │
│                         │
│   📋 今日任務 (3/5)     │
│   ✅ 刷牙                │
│   ✅ 整理房間            │
│   ⬜ 運動 30 分鐘        │
│                         │
│   🏆 可兌換獎勵          │
│   🎮 額外遊戲時間        │
│   🍭 零食                │
└─────────────────────────┘
```

#### 新版本（教育導向）
```
┌─────────────────────────┐
│   嗨！今天過得好嗎？     │
│                         │
│   ⏱️ 今天還可以用        │
│   120 分鐘              │
│                         │
│   本週表現：太棒了！     │
│   🌟 連續 3 天沒超時     │
│                         │
│   💡 健康小提醒          │
│   看螢幕 20 分鐘記得     │
│   休息一下喔！           │
│                         │
│   🎨 你可以試試          │
│   - 畫一幅畫            │
│   - 到公園玩            │
│   - 看故事書            │
└─────────────────────────┘
```

### 統計頁面改造

#### 舊版本
```
本週統計：
- 遊戲時間：240 分鐘
- 影片時間：180 分鐘
- 學習時間：60 分鐘
- 獲得積分：450 點
- 完成任務：15 個
```

#### 新版本
```
本週回顧：

📈 使用趨勢
週一 ▓▓▓░░ 60 分鐘
週二 ▓▓▓░░ 70 分鐘
週三 ▓▓░░░ 50 分鐘 ⭐
週四 ▓▓▓▓░ 80 分鐘
週五 ▓▓▓░░ 60 分鐘

✨ 本週亮點
- 連續 3 天沒有超時，太棒了！
- 比上週少用了 30 分鐘
- 週三表現特別好

💪 下週可以試試
- 繼續保持不超時
- 可以多些戶外活動時間
```

---

## ⚠️ 重要注意事項

### 1. 資料遷移
- **備份**：調整前完整備份資料庫
- **使用者溝通**：提前告知用戶重大變更
- **資料保留**：使用歷史記錄保留（不含積分/任務）
- **過渡期**：考慮是否需要過渡期（可能不需要，因為還沒正式上線）

### 2. 語氣與文字
- **全面檢查**：所有文字都要符合友善、教育、正向的原則
- **避免用詞**：
  - ❌ 「違規」、「懲罰」、「扣分」
  - ❌ 「任務」、「獎勵」、「積分」
  - ❌ 「限制」、「禁止」、「鎖定」
- **建議用詞**：
  - ✅ 「今天用完囉」、「明天又有新額度」
  - ✅ 「建議」、「可以試試」、「一起學習」
  - ✅ 「休息時間」、「替代活動」、「家庭時光」

### 3. 視覺設計
- **配色**：溫暖、柔和（避免紅色警告）
- **圖示**：圓潤、友善（避免警告標誌）
- **動畫**：柔和、自然（避免強烈對比）

### 4. 測試重點
- **語氣測試**：請非技術背景的家長閱讀所有文字
- **孩童測試**：觀察孩童使用時的情緒反應
- **家長測試**：確認工具確實有助於親子對話

---

## 📝 Checklist 總覽

### 文檔 (5 項)
- [x] specification.md
- [ ] README.md
- [ ] EDUCATION_PHILOSOPHY.md
- [ ] USER_GUIDE.md
- [ ] CHANGES_SUMMARY.md

### 後端 (15 項)
- [ ] 刪除 Task 模型和 API
- [ ] 刪除 Point 模型和 API
- [ ] 刪除 Reward 模型和 API
- [ ] 調整 TimeRule 模型
- [ ] 資料庫遷移腳本
- [ ] 教育內容 API
- [ ] 替代活動 API
- [ ] 自然後果邏輯
- [ ] 規則討論 API
- [ ] 家庭活動 API
- [ ] 週報 API
- [ ] 月報 API
- [ ] 家長追蹤 API
- [ ] WebSocket 事件調整
- [ ] 單元測試更新

### 行動端 (20 項)
- [ ] 刪除 task_screen.dart
- [ ] 刪除 reward_shop.dart
- [ ] 調整 home_screen.dart
- [ ] 調整 quick_stats.dart
- [ ] 調整 time_control_service.dart
- [ ] 刪除 task 相關模型
- [ ] 刪除 points 相關模型
- [ ] 刪除 reward 相關模型
- [ ] 新增友善鎖定畫面
- [ ] 新增替代活動畫面
- [ ] 新增使用歷史畫面
- [ ] 新增教育內容畫面
- [ ] 新增教育內容模型
- [ ] 新增替代活動模型
- [ ] 新增每日摘要模型
- [ ] 新增 education_service.dart
- [ ] 新增 activity_service.dart
- [ ] 更新 Widget (friendly_reminder, activity_card 等)
- [ ] 文字語氣全面檢查
- [ ] 視覺風格調整

### 家長端 Web (15 項)
- [ ] 刪除任務管理頁面
- [ ] 刪除獎勵商城頁面
- [ ] 調整儀表板
- [ ] 調整規則設定頁面
- [ ] 調整統計頁面
- [ ] 新增教育資源中心
- [ ] 新增家庭活動功能
- [ ] 新增報告功能
- [ ] 新增家長自我追蹤
- [ ] 新增規則討論工具
- [ ] 新增 EducationCard 元件
- [ ] 新增 ActivitySuggestion 元件
- [ ] 新增 DialogueGuide 元件
- [ ] 文字語氣全面檢查
- [ ] 視覺風格調整

### Android 原生 (3 項)
- [ ] 調整 LockAccessibilityService
- [ ] 新增 FriendlyLockScreen
- [ ] 鎖定畫面 UI/UX 優化

### 測試 (5 項)
- [ ] 端到端測試
- [ ] 使用者體驗測試
- [ ] 語氣測試
- [ ] 家長訪談測試
- [ ] 效能測試

---

## 🎯 預期成果

### 量化指標
- 移除程式碼：約 30% (所有遊戲化相關)
- 新增程式碼：約 40% (教育、家庭、報告功能)
- 重構程式碼：約 30% (調整既有功能)

### 質化指標
- **理念一致**：專案完全符合教育心理學原則
- **語氣友善**：所有文字溫暖、正向、教育導向
- **功能實用**：真正幫助家長建立健康常規
- **差異化**：與市面競品完全不同的定位

---

## 📅 總時程

| 階段 | 時間 | 重點 |
|-----|------|-----|
| 階段 1 | 1 週 | 文檔與概念 |
| 階段 2 | 2 週 | 後端重構 |
| 階段 3 | 2 週 | 行動端重構 |
| 階段 4 | 2 週 | 家長端重構 |
| 階段 5 | 1 週 | 測試與優化 |
| **總計** | **8 週** | **完整重構** |

---

## ✅ 開始行動

建議從以下步驟開始：

1. **確認方向** ✅
   - 與團隊（或太太）討論新理念
   - 確認這是正確的方向

2. **更新文檔** ⏳ 下一步
   - 完成所有文檔更新
   - 準備教育內容資料

3. **後端先行**
   - 先完成後端重構
   - 為前端提供穩定 API

4. **逐步交付**
   - 行動端和家長端可並行開發
   - 持續測試和調整

---

**最後更新**：2025-10-23
**負責人**：開發團隊
**預計完成**：2025-12-15
