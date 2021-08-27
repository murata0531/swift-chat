# swift-chat

Swiftで某大型掲示板を再現したかった

# 環境

SwiftUI

Firebase
```
・Authentication

・Cloud Firestore
```

# 構築

Home.swiftと同じ階層に、自分で取得した `GoogleService-Info.plist` を配置する

Podfile内にfirebaseのサービス群のインストール定義を記述しているので
```
$ pod install
```
とすると適切にfirebaseを導入することができる(cocoa podを使用)
