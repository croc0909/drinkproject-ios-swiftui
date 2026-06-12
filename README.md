# IOSDrinkProject

SwiftUI + MVVM 的飲料訂購 iOS 前端雛形，可使用 Xcode 開啟 `IOSDrinkProject.xcodeproj`。

## 結構

- `Models`: 飲品、購物車、訂單資料模型
- `ViewModels`: 畫面狀態與訂單流程
- `Views`: SwiftUI 畫面元件
- `Services`: 與 Go 後端串接的 API client

## 後端串接

目前 `APIClient` 預設連到：

```swift
http://localhost:8080/api
```

預期 API：

- `GET /api/drinks` 回傳 `[Drink]`
- `POST /api/orders` 建立訂單

若後端尚未啟動，App 會顯示範例飲品資料，方便先確認 UI。
