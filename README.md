# NewsApp


<img width="300" src="https://github.com/user-attachments/assets/b82c4d68-7ebd-4be2-a843-220731aa5601">
<img width="300" src="https://github.com/user-attachments/assets/62410fa8-bf2e-48e6-9602-c9ba593d0228">
<img width="300" src="https://github.com/user-attachments/assets/44927690-f36b-4e15-b923-8b7d3e81bd81">

## 概要
ニュースビューアサンプルプロジェクト
- ニュースソース: News API (https://newsapi.org/)

## 仕様・考慮点

- Firebaseを使用したアカウント管理・データ管理
  - Configuration切り替えによるFireabse接続先の切り替え(開発・本番)
  - Firebase Authenticationによるアカウント管理
  - Firebase Firestoreによるユーザ設定情報、ブックマークの管理
  - Firebase Firestoreによる利用規約の提供(不要なアプリアップデートの回避)
- ログイン状態に対応した機能制限
- fastlaneによる自動ユニットテスト実行(GitHubへのpush時)
- URLSessionによる外部API(News API)からの情報取得
- Dependency ContainerによるInitializer Injectionの実現
- Architecture: MVVM
- Figmaによるデザインおよび、SwiftUIによるデザイン実装
  - デザイン参考元: https://ground.news/app
- ダークモード実装
- Gitへのシークレット情報登録除外(API key、Firebase設定ファイル)
- トーストによる操作結果通知

## インストール
### 1. News APIのAPIキーを設定する
#### 1.1. News APIサイト(https://newsapi.org/)でアカウントを作成する
#### 1.2. News APIサイトでAPIキーを取得する
#### 1.3. Xcodeプロジェクトを開き、NewsAppディイレクトリ配下にConfig.xcconfigファイルを追加する
![create_Configfile](https://github.com/user-attachments/assets/1754af3d-1845-4392-bf28-952f4e8bd687)

#### 1.4. Config.xcconfigファイルにNewsAPIのAPIキーを記述する
![enter_API_key](https://github.com/user-attachments/assets/c049bc5a-b139-4409-afde-7fcb92f2067c)

キー名は`API_KEY_NewsAPI`にする

### 2. Firebaseプロジェクトを設定する
#### 2.1. Firebase consoleで開発用プロジェクトと本番用プロジェクトを作成する
![create_firebase_projects](https://github.com/user-attachments/assets/66d16650-a824-4c1f-813e-035070c8e37a)

プロジェクト名は任意。
開発用プロジェクトには開発用Bundle IDを、本番用プロジェクトには本番用Bundle IDをそれぞれ登録すること
使用プロダクトは以下。
- Authentication
- Firestore Database

#### 2.2. 開発用プロジェクト用Firebase設定ファイルおよび本番用プロジェクト用Firebase設定ファイルを配置する
![download_project_setting_files](https://github.com/user-attachments/assets/332c077d-6a5d-4f3e-9ac2-2bf04c1f1686)
作成したFirebaseプロジェクトの設定ファイルをxcodeprojファイルと同ディレクトリに配置する。
ファイル名は以下の様にする
- 開発用プロジェクト: GoogleService-Info-dev.plist
- 本番用プロジェクト: GoogleService-Info-prod.plist

#### 2.3. 利用規約テキストをFirestoreに配置する
Firestoreトップレベルのコレクションに`terms`を作成する。
`terms`に、以下のフィールドを持つドキュメントを追加する。
- body: String
  - 利用規約本体
  - 改行文字(`\n`)込みのMarkdownで利用規約を記載する
- createdAt: Date
  - 利用規約登録日
- effectiveDate: Date
  - 利用規約発効日
- title: String
  - 利用規約タイトル
  - 例として`NewsApp 利用規約`など

### 3. (オプション)fastlaneを設定する
#### 3.1. fastlaneをインストールする
#### 3.2. push時に実行するスクリプトを配置する


