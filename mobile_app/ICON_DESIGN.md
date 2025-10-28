# Kids Time Control - APP 圖示設計規格

## 設計概念
- **主題**: 時鐘 + 保護（家長控制）
- **風格**: 現代、友善、適合家庭使用
- **顏色方案**: 紫色到藍綠色漸層

## 設計元素
1. **主圖形**: 圓形時鐘
2. **副圖形**: 愛心或盾牌（保護）
3. **顏色**:
   - 主色：#7C4DFF（深紫色）
   - 輔色：#4ECDC4（藍綠色）
   - 背景：白色或漸層

## 快速生成方案

### 方案 1：使用 Canva（推薦）
1. 前往 https://www.canva.com/
2. 創建 1024x1024 的設計
3. 搜尋「clock icon」+ 「shield icon」
4. 使用漸層色 #7C4DFF → #4ECDC4
5. 導出為 PNG

### 方案 2：使用 Figma
1. 創建 1024x1024 畫布
2. 繪製圓形時鐘
3. 添加愛心/盾牌元素
4. 應用漸層填充
5. 導出為 PNG

### 方案 3：使用線上圖示生成器
- https://icon.kitchen/ （超簡單！）
  1. 選擇「Custom」
  2. 上傳或選擇 clock/timer 圖示
  3. 選擇漸層背景：紫色 → 藍綠色
  4. 下載所有尺寸

## 檔案要求
- **格式**: PNG
- **尺寸**: 1024x1024 px（高解析度）
- **透明背景**: 可選
- **檔名**: `icon.png`

## 安裝步驟
1. 將生成的圖示重命名為 `icon.png`
2. 放置到 `mobile_app/assets/icon/icon.png`
3. 執行指令生成所有平台圖示：
   ```bash
   cd mobile_app
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

## 臨時解決方案
如果現在沒時間設計，可以用這個：
- 線上生成工具：https://icon.kitchen/
- 選一個時鐘圖示 + 紫色背景
- 5 分鐘內完成！
