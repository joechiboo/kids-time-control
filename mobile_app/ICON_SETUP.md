# App Icon 設定說明

## 圖示設計概念
Kids Time Control 應用程式需要一個友善且容易識別的圖示。建議設計包含以下元素：

### 設計建議
1. **主要元素**: 時鐘圖案搭配防護盾牌
2. **顏色方案**: 使用主題色 #7C4DFF (紫色) 作為背景
3. **前景顏色**: 白色或淺色系，確保與背景對比明顯
4. **風格**: 簡潔、友善、適合兒童應用

### 需要的圖示尺寸

#### app_icon.png (主要圖示)
- 尺寸: 1024x1024 像素
- 格式: PNG (帶透明背景)
- 用途: Android 標準圖示

#### app_icon_foreground.png (前景圖示)
- 尺寸: 1024x1024 像素
- 格式: PNG (帶透明背景)
- 內容: 時鐘圖案，居中放置在 432x432 像素的安全區域內
- 用途: Android Adaptive Icon 前景層

## 製作圖示的方法

### 方法 1: 使用線上工具
1. 訪問 [Canva](https://www.canva.com) 或 [Figma](https://www.figma.com)
2. 創建 1024x1024 的畫布
3. 設計一個包含時鐘和盾牌元素的圖示
4. 導出為 PNG 格式

### 方法 2: 使用 Flutter Icon Generator
1. 訪問 [App Icon Generator](https://www.appicon.co/)
2. 上傳你的設計
3. 下載生成的圖示包

### 方法 3: 使用 Material Icons
如果想要快速測試，可以使用 Material Design 的圖示：
- 訪問 [Material Icons](https://fonts.google.com/icons)
- 搜尋 "schedule" 或 "lock_clock"
- 下載 PNG 版本

## 安裝步驟

1. 將製作好的圖示放入專案目錄：
   ```
   mobile_app/assets/icon/app_icon.png
   mobile_app/assets/icon/app_icon_foreground.png
   ```

2. 執行 Flutter 圖示生成指令：
   ```bash
   cd mobile_app
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. 重新構建應用程式：
   ```bash
   flutter build apk
   ```
   或
   ```bash
   flutter run
   ```

## 目前配置

已在 `pubspec.yaml` 中配置：
- Android adaptive icon 背景色: #7C4DFF
- 圖示路徑已設定
- 只需要創建並放置圖示檔案即可

## 簡易替代方案

如果暫時沒有設計資源，可以使用以下簡易方案：

1. 從網路下載免費的時鐘圖示 (例如：[Flaticon](https://www.flaticon.com))
2. 使用簡單的文字 "KTC" (Kids Time Control) 作為圖示
3. 使用純色背景搭配簡單的時鐘符號

記得遵守圖示的授權條款！
