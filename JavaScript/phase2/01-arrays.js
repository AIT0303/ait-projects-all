// ============================================
// Lesson 5: 配列の基本操作
// ============================================

// 実行コマンド: node phase2/01-arrays.js

// --------------------------------------------
// 1. 配列の作成
// --------------------------------------------
console.log("=== 配列の作成 ===");

// Python: fruits = ["apple", "banana", "orange"]
const fruits = ["apple", "banana", "orange"];
console.log("fruits:", fruits);

// 要素へのアクセス（0から始まる）
console.log("fruits[0]:", fruits[0]);  // apple
console.log("fruits[1]:", fruits[1]);  // banana

// 長さ
console.log("length:", fruits.length);  // 3

// --------------------------------------------
// 2. 要素の追加・削除
// --------------------------------------------
console.log("\n=== push / pop（末尾） ===");

const numbers = [1, 2, 3];
console.log("初期:", numbers);

// push: 末尾に追加
numbers.push(4);
console.log("push(4):", numbers);  // [1, 2, 3, 4]

numbers.push(5, 6);
console.log("push(5, 6):", numbers);  // [1, 2, 3, 4, 5, 6]

// pop: 末尾から削除（削除した要素を返す）
const removed = numbers.pop();
console.log("pop():", numbers, "/ 削除:", removed);

// --------------------------------------------
// 3. 先頭の追加・削除
// --------------------------------------------
console.log("\n=== unshift / shift（先頭） ===");

const letters = ["b", "c", "d"];
console.log("初期:", letters);

// unshift: 先頭に追加
letters.unshift("a");
console.log("unshift('a'):", letters);  // ["a", "b", "c", "d"]

// shift: 先頭から削除
const first = letters.shift();
console.log("shift():", letters, "/ 削除:", first);

// --------------------------------------------
// 4. まとめ図
// --------------------------------------------
console.log("\n=== 操作まとめ ===");
console.log(`
  配列: [1, 2, 3]

  末尾:
    push(4)  → [1, 2, 3, 4]  追加
    pop()    → [1, 2]        削除

  先頭:
    unshift(0) → [0, 1, 2, 3]  追加
    shift()    → [2, 3]        削除
`);

// --------------------------------------------
// 5. その他の便利な操作
// --------------------------------------------
console.log("=== その他の操作 ===");

const arr = [1, 2, 3, 4, 5];

// includes: 含まれているか
console.log("includes(3):", arr.includes(3));  // true
console.log("includes(10):", arr.includes(10)); // false

// indexOf: 位置を探す
console.log("indexOf(3):", arr.indexOf(3));    // 2
console.log("indexOf(10):", arr.indexOf(10));  // -1 (見つからない)

// slice: 一部を取り出す（元の配列は変わらない）
console.log("slice(1, 3):", arr.slice(1, 3));  // [2, 3]
console.log("元の配列:", arr);  // [1, 2, 3, 4, 5]

// splice: 削除・挿入（元の配列を変更する）
const colors = ["red", "green", "blue"];
colors.splice(1, 1, "yellow");  // index 1から1個削除し、yellowを挿入
console.log("splice後:", colors);  // ["red", "yellow", "blue"]

// --------------------------------------------
// 6. Python vs JavaScript
// --------------------------------------------
console.log("\n=== Python vs JavaScript ===");
console.log(`
Python:           JavaScript:
list.append(x)    array.push(x)
list.pop()        array.pop()
list.insert(0,x)  array.unshift(x)
list.pop(0)       array.shift()
x in list         array.includes(x)
`);

console.log("✅ Lesson 5 完了！");
