// ============================================
// Lesson 6: 配列メソッド（超重要！）
// ============================================

// 実行コマンド: node phase2/02-array-methods.js

// これらのメソッドは React で毎日使う！

const numbers = [1, 2, 3, 4, 5];

// --------------------------------------------
// 1. forEach - 各要素に処理を実行
// --------------------------------------------
console.log("=== forEach ===");

// Python: for n in numbers: print(n)
numbers.forEach((n) => {
  console.log(n);
});

// --------------------------------------------
// 2. map - 各要素を変換して新しい配列を作る ★超重要
// --------------------------------------------
console.log("\n=== map ===");

// 全ての要素を2倍にする
const doubled = numbers.map((n) => n * 2);
console.log("元:", numbers);
console.log("2倍:", doubled);  // [2, 4, 6, 8, 10]

// 文字列に変換
const strings = numbers.map((n) => `番号${n}`);
console.log("文字列:", strings);

// --------------------------------------------
// 3. filter - 条件に合う要素だけ抽出 ★超重要
// --------------------------------------------
console.log("\n=== filter ===");

// 偶数だけ抽出
const evens = numbers.filter((n) => n % 2 === 0);
console.log("偶数:", evens);  // [2, 4]

// 3以上の数
const big = numbers.filter((n) => n >= 3);
console.log("3以上:", big);  // [3, 4, 5]

// --------------------------------------------
// 4. find - 条件に合う最初の1つを見つける
// --------------------------------------------
console.log("\n=== find ===");

const users = [
  { id: 1, name: "太郎" },
  { id: 2, name: "花子" },
  { id: 3, name: "次郎" },
];

const user = users.find((u) => u.id === 2);
console.log("ID=2のユーザー:", user);  // { id: 2, name: "花子" }

const notFound = users.find((u) => u.id === 99);
console.log("ID=99:", notFound);  // undefined

// --------------------------------------------
// 5. reduce - 配列を1つの値にまとめる
// --------------------------------------------
console.log("\n=== reduce ===");

// 合計を計算
const sum = numbers.reduce((total, n) => total + n, 0);
console.log("合計:", sum);  // 15

// 最大値を見つける
const max = numbers.reduce((a, b) => (a > b ? a : b));
console.log("最大:", max);  // 5

// --------------------------------------------
// 6. メソッドチェーン（組み合わせ）
// --------------------------------------------
console.log("\n=== メソッドチェーン ===");

const scores = [85, 92, 78, 95, 88, 72];

// 80点以上を抽出して、10点加点
const result = scores
  .filter((s) => s >= 80)
  .map((s) => s + 10);

console.log("元:", scores);
console.log("80点以上+10:", result);  // [95, 102, 105, 98]

// --------------------------------------------
// 7. 実践例：商品リスト
// --------------------------------------------
console.log("\n=== 実践例 ===");

const products = [
  { name: "りんご", price: 100, inStock: true },
  { name: "バナナ", price: 80, inStock: false },
  { name: "オレンジ", price: 120, inStock: true },
  { name: "ぶどう", price: 300, inStock: true },
];

// 在庫ありの商品名だけ取得
const available = products
  .filter((p) => p.inStock)
  .map((p) => p.name);
console.log("在庫あり:", available);

// 合計金額（在庫ありのみ）
const total = products
  .filter((p) => p.inStock)
  .reduce((sum, p) => sum + p.price, 0);
console.log("合計金額:", total);

// --------------------------------------------
// 8. まとめ
// --------------------------------------------
console.log("\n=== まとめ ===");
console.log(`
メソッド    戻り値      用途
-----------------------------------------
forEach     なし        ループ処理
map         新配列      変換（同じ長さ）
filter      新配列      抽出（短くなる）
find        1要素       検索（最初の1つ）
reduce      1つの値     集計（合計など）
`);

console.log("✅ Lesson 6 完了！");
