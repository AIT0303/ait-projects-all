// ============================================
// Lesson 3: 演算子
// ============================================

// 実行コマンド: node phase1/03-operators.js

// --------------------------------------------
// 1. 算術演算子（計算）
// --------------------------------------------
console.log("=== 算術演算子 ===");

console.log("5 + 3 =", 5 + 3);   // 足し算: 8
console.log("5 - 3 =", 5 - 3);   // 引き算: 2
console.log("5 * 3 =", 5 * 3);   // 掛け算: 15
console.log("5 / 3 =", 5 / 3);   // 割り算: 1.666...
console.log("5 % 3 =", 5 % 3);   // 余り: 2
console.log("5 ** 3 =", 5 ** 3); // べき乗: 125 (5の3乗)

// --------------------------------------------
// 2. 代入演算子
// --------------------------------------------
console.log("\n=== 代入演算子 ===");

let x = 10;
console.log("x =", x);

x += 5;  // x = x + 5 と同じ
console.log("x += 5 →", x);  // 15

x -= 3;  // x = x - 3 と同じ
console.log("x -= 3 →", x);  // 12

x *= 2;  // x = x * 2 と同じ
console.log("x *= 2 →", x);  // 24

// --------------------------------------------
// 3. 比較演算子（結果は true/false）
// --------------------------------------------
console.log("\n=== 比較演算子 ===");

console.log("5 > 3:", 5 > 3);    // より大きい: true
console.log("5 < 3:", 5 < 3);    // より小さい: false
console.log("5 >= 5:", 5 >= 5);  // 以上: true
console.log("5 <= 4:", 5 <= 4);  // 以下: false

// == と === の違い（重要！）
console.log("\n--- == と === の違い ---");
console.log("5 == '5':", 5 == "5");   // true（型を無視して比較）
console.log("5 === '5':", 5 === "5"); // false（型も比較）★こっちを使う

console.log("5 != '5':", 5 != "5");   // false
console.log("5 !== '5':", 5 !== "5"); // true ★こっちを使う

// --------------------------------------------
// 4. 論理演算子
// --------------------------------------------
console.log("\n=== 論理演算子 ===");

const isAdult = true;
const hasTicket = true;
const isMember = false;

// AND（両方trueならtrue）
console.log("isAdult && hasTicket:", isAdult && hasTicket);  // true

// OR（どちらかtrueならtrue）
console.log("isAdult || isMember:", isAdult || isMember);    // true

// NOT（反転）
console.log("!isMember:", !isMember);  // true

// 組み合わせ
const canEnter = isAdult && (hasTicket || isMember);
console.log("入場可能:", canEnter);  // true

// --------------------------------------------
// 5. 文字列の結合
// --------------------------------------------
console.log("\n=== 文字列の結合 ===");

const firstName = "太郎";
const lastName = "山田";

// + で結合
const fullName = lastName + " " + firstName;
console.log("フルネーム:", fullName);

// テンプレートリテラル（おすすめ）
const greeting = `こんにちは、${lastName}${firstName}さん！`;
console.log(greeting);

// --------------------------------------------
// 6. インクリメント・デクリメント
// --------------------------------------------
console.log("\n=== インクリメント・デクリメント ===");

let count = 0;
count++;  // count = count + 1
console.log("count++:", count);  // 1

count++;
console.log("count++:", count);  // 2

count--;  // count = count - 1
console.log("count--:", count);  // 1

console.log("\n✅ Lesson 3 完了！");
