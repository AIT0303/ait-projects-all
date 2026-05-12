// ============================================
// Lesson 4: 関数
// ============================================

// 実行コマンド: node phase1/04-functions.js

// --------------------------------------------
// 1. 関数宣言（function declaration）
// --------------------------------------------
console.log("=== 関数宣言 ===");

// Python: def greet():
function greet() {
  console.log("こんにちは！");
}

greet();  // 関数を呼び出す

// 引数あり
function greetPerson(name) {
  console.log(`こんにちは、${name}さん！`);
}

greetPerson("太郎");

// --------------------------------------------
// 2. 戻り値（return）
// --------------------------------------------
console.log("\n=== 戻り値 ===");

function add(a, b) {
  return a + b;
}

const result = add(5, 3);
console.log("5 + 3 =", result);

// 複数の処理
function calculateTax(price) {
  const tax = price * 0.1;
  const total = price + tax;
  return total;
}

console.log("税込価格:", calculateTax(1000));

// --------------------------------------------
// 3. 関数式（function expression）
// --------------------------------------------
console.log("\n=== 関数式 ===");

// 関数を変数に代入
const multiply = function(a, b) {
  return a * b;
};

console.log("4 * 5 =", multiply(4, 5));

// --------------------------------------------
// 4. アロー関数（arrow function）★重要
// --------------------------------------------
console.log("\n=== アロー関数 ===");

// 基本形
const subtract = (a, b) => {
  return a - b;
};
console.log("10 - 3 =", subtract(10, 3));

// 1行なら {} と return を省略できる
const divide = (a, b) => a / b;
console.log("20 / 4 =", divide(20, 4));

// 引数が1つなら () も省略できる
const double = n => n * 2;
console.log("double(5) =", double(5));

// 引数なし
const sayHello = () => console.log("Hello!");
sayHello();

// --------------------------------------------
// 5. デフォルト引数
// --------------------------------------------
console.log("\n=== デフォルト引数 ===");

// Python: def greet(name="ゲスト"):
function greetWithDefault(name = "ゲスト") {
  console.log(`ようこそ、${name}さん！`);
}

greetWithDefault("花子");  // ようこそ、花子さん！
greetWithDefault();        // ようこそ、ゲストさん！

// --------------------------------------------
// 6. 関数の書き方比較
// --------------------------------------------
console.log("\n=== 3つの書き方比較 ===");

// 同じ処理を3通りで書く
function square1(n) { return n * n; }           // 関数宣言
const square2 = function(n) { return n * n; };  // 関数式
const square3 = n => n * n;                     // アロー関数

console.log("square1(4):", square1(4));
console.log("square2(4):", square2(4));
console.log("square3(4):", square3(4));

// --------------------------------------------
// 7. Python vs JavaScript 比較
// --------------------------------------------
console.log("\n=== Python vs JavaScript ===");
console.log(`
Python:
  def add(a, b):
      return a + b

JavaScript:
  function add(a, b) {
    return a + b;
  }

  // または
  const add = (a, b) => a + b;
`);

console.log("✅ Lesson 4 完了！");
