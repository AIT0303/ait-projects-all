// ============================================
// Lesson 2: データ型
// ============================================

// 実行コマンド: node phase1/02-data-types.js

// --------------------------------------------
// 1. 文字列（String）- テキストデータ
// --------------------------------------------
const greeting = "こんにちは";
const name = '太郎';  // シングルクォートもOK

console.log("=== 文字列 ===");
console.log(greeting);
console.log(name);

// テンプレートリテラル（バッククォート）- 変数を埋め込める
const message = `${name}さん、${greeting}！`;
console.log(message);  // 太郎さん、こんにちは！

// --------------------------------------------
// 2. 数値（Number）- 整数も小数も同じ
// --------------------------------------------
const age = 25;
const price = 1980.5;
const negative = -10;

console.log("\n=== 数値 ===");
console.log("年齢:", age);
console.log("価格:", price);
console.log("負の数:", negative);

// --------------------------------------------
// 3. 真偽値（Boolean）- true か false
// --------------------------------------------
const isStudent = true;
const isAdult = false;

console.log("\n=== 真偽値 ===");
console.log("学生ですか？:", isStudent);
console.log("大人ですか？:", isAdult);

// --------------------------------------------
// 4. null と undefined
// --------------------------------------------
let empty = null;        // 意図的に「空」を代入
let notDefined;          // 何も代入していない → undefined

console.log("\n=== null と undefined ===");
console.log("null:", empty);
console.log("undefined:", notDefined);

// --------------------------------------------
// 5. 型を調べる - typeof
// --------------------------------------------
console.log("\n=== typeof で型を確認 ===");
console.log("'hello' の型:", typeof "hello");     // string
console.log("100 の型:", typeof 100);             // number
console.log("true の型:", typeof true);           // boolean
console.log("null の型:", typeof null);           // object (※歴史的なバグ)
console.log("undefined の型:", typeof undefined); // undefined

// --------------------------------------------
// 6. 型変換
// --------------------------------------------
console.log("\n=== 型変換 ===");

// 文字列 → 数値
const strNum = "123";
const num = Number(strNum);
console.log("Number('123'):", num, "型:", typeof num);

// 数値 → 文字列
const numToStr = String(456);
console.log("String(456):", numToStr, "型:", typeof numToStr);

// 真偽値への変換
console.log("Boolean(1):", Boolean(1));     // true
console.log("Boolean(0):", Boolean(0));     // false
console.log("Boolean(''):", Boolean(""));   // false（空文字はfalse）
console.log("Boolean('hello'):", Boolean("hello")); // true

console.log("\n✅ Lesson 2 完了！");
