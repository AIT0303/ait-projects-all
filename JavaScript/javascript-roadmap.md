# JavaScript 学習ロードマップ

## Phase 1: 基礎（2-4週間）

### 1.1 環境構築
- [ ] Node.js のインストール
- [ ] VSCode のセットアップ
- [ ] ブラウザの開発者ツールの使い方

### 1.2 基本文法
- [x] 変数宣言（`let`, `const`, `var`）
- [x] データ型（文字列、数値、真偽値、null、undefined）
- [ ] 演算子（算術、比較、論理）
- [ ] 条件分岐（`if`, `else`, `switch`）
- [ ] ループ（`for`, `while`, `for...of`, `for...in`）

---

## 学習メモ

### 変数宣言

| キーワード | 再代入 | 用途 |
|-----------|--------|------|
| `const` | 不可 | 変わらない値（基本これを使う） |
| `let` | 可能 | 変わる値 |
| `var` | 可能 | 古い書き方（使わない） |

```javascript
const PI = 3.14;    // 変更不可
let count = 0;      // 変更可能
count = 1;          // OK
```

### データ型

| 型 | 内容 | Python相当 | 例 |
|----|------|-----------|-----|
| `String` | 文字列 | `str` | `"hello"`, `'太郎'` |
| `Number` | 数値（整数も小数も） | `int` + `float` | `100`, `3.14` |
| `Boolean` | 真偽値 | `True` / `False` | `true`, `false` |
| `null` | 意図的に「空」 | `None` | `null` |
| `undefined` | まだ何もない | (なし) | 未代入の変数 |

```javascript
typeof "hello"     // "string"
typeof 100         // "number"
typeof true        // "boolean"
```

### console.log

画面に出力する（Pythonの `print()` と同じ）

```javascript
console.log("Hello");        // Hello
console.log(1 + 2);          // 3
console.log("合計:", 100);   // 合計: 100
```

### 1.3 関数
- [ ] 関数宣言と関数式
- [ ] アロー関数 `() => {}`
- [ ] 引数とデフォルト値
- [ ] 戻り値（`return`）
- [ ] スコープの理解

---

## Phase 2: 中級（4-6週間）

### 2.1 配列とオブジェクト
- [ ] 配列の操作（`push`, `pop`, `shift`, `unshift`）
- [ ] 配列メソッド（`map`, `filter`, `reduce`, `find`, `forEach`）
- [ ] オブジェクトの作成と操作
- [ ] スプレッド構文（`...`）
- [ ] 分割代入（Destructuring）

### 2.2 DOM操作
- [ ] 要素の取得（`getElementById`, `querySelector`）
- [ ] 要素の作成・追加・削除
- [ ] イベントリスナー（`addEventListener`）
- [ ] イベントの種類（click, submit, keydown など）

### 2.3 非同期処理
- [ ] コールバック関数
- [ ] Promise の基礎
- [ ] `async` / `await`
- [ ] `fetch` API でのデータ取得
- [ ] エラーハンドリング（`try...catch`）

---

## Phase 3: 上級（6-8週間）

### 3.1 ES6+ モダンJavaScript
- [ ] モジュール（`import` / `export`）
- [ ] クラス構文
- [ ] テンプレートリテラル
- [ ] Optional Chaining (`?.`)
- [ ] Nullish Coalescing (`??`)

### 3.2 オブジェクト指向とデザインパターン
- [ ] プロトタイプチェーン
- [ ] `this` キーワードの理解
- [ ] クロージャ
- [ ] 高階関数

### 3.3 Web API
- [ ] LocalStorage / SessionStorage
- [ ] Geolocation API
- [ ] Canvas API（基礎）
- [ ] Web Workers（基礎）

---

## Phase 4: 実践・フレームワーク（8週間〜）

### 4.1 ツールチェーン
- [ ] npm / yarn パッケージ管理
- [ ] Vite / Webpack（ビルドツール）
- [ ] ESLint / Prettier（コード品質）
- [ ] Git / GitHub

### 4.2 フレームワーク（1つ選択）
- [ ] **React** - 最も人気、求人多い
- [ ] **Vue** - 学習しやすい
- [ ] **Svelte** - シンプル、高速

### 4.3 バックエンド（オプション）
- [ ] Node.js + Express
- [ ] REST API の作成
- [ ] データベース接続（MongoDB / PostgreSQL）

---

## 推奨学習リソース

### 無料
| リソース | 説明 |
|---------|------|
| [MDN Web Docs](https://developer.mozilla.org/ja/) | 公式リファレンス |
| [JavaScript.info](https://ja.javascript.info/) | 体系的なチュートリアル |
| [freeCodeCamp](https://www.freecodecamp.org/) | 実践的な演習 |

### 有料
| リソース | 説明 |
|---------|------|
| Udemy | セール時に格安でコース購入可能 |
| Progate | 日本語で学べる初心者向け |

---

## 学習のコツ

1. **毎日コードを書く** - 少しでも毎日触れる
2. **小さなプロジェクトを作る** - Todo アプリ、電卓、クイズゲームなど
3. **エラーを恐れない** - エラーメッセージを読む習慣をつける
4. **公式ドキュメントを読む** - MDN を活用する
5. **アウトプットする** - 学んだことをブログや GitHub に残す

---

## 練習プロジェクト案

| レベル | プロジェクト |
|-------|-------------|
| 初級 | カウンターアプリ、じゃんけんゲーム |
| 中級 | Todoリスト、天気アプリ（API連携）|
| 上級 | チャットアプリ、ECサイト風UI |

---

頑張ってください！
