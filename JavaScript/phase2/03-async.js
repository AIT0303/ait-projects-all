// ============================================
// Lesson 7: 非同期処理
// ============================================

// 実行コマンド: node phase2/03-async.js

// --------------------------------------------
// なぜ非同期が必要？
// --------------------------------------------
// JavaScript は「待てない」言語
// API通信、ファイル読み込みなど時間がかかる処理を
// 「待たずに」次の処理を実行する

console.log("=== 同期 vs 非同期 ===");

// 同期処理（順番に実行）
console.log("1. 開始");
console.log("2. 処理中...");
console.log("3. 完了");

// 非同期処理（setTimeout で擬似的に再現）
console.log("\n--- 非同期の例 ---");
console.log("A. 開始");
setTimeout(() => {
  console.log("B. 2秒後に実行");  // これは後で表示される
}, 2000);
console.log("C. すぐ実行（Bを待たない）");

// --------------------------------------------
// 1. コールバック関数（古い書き方）
// --------------------------------------------
console.log("\n=== コールバック関数 ===");

function fetchData(callback) {
  setTimeout(() => {
    const data = { id: 1, name: "太郎" };
    callback(data);  // 完了したらコールバックを呼ぶ
  }, 1000);
}

fetchData((result) => {
  console.log("コールバックで取得:", result);
});

// 問題: コールバック地獄（ネストが深くなる）
// fetchData((data1) => {
//   fetchMore((data2) => {
//     fetchEvenMore((data3) => {
//       // どんどん深くなる...
//     });
//   });
// });

// --------------------------------------------
// 2. Promise（ES6）
// --------------------------------------------
console.log("\n=== Promise ===");

function fetchDataPromise() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const success = true;
      if (success) {
        resolve({ id: 2, name: "花子" });  // 成功
      } else {
        reject("エラーが発生");  // 失敗
      }
    }, 1500);
  });
}

// .then() で結果を受け取る
fetchDataPromise()
  .then((data) => {
    console.log("Promise成功:", data);
  })
  .catch((error) => {
    console.log("Promiseエラー:", error);
  });

// --------------------------------------------
// 3. async / await（モダンな書き方）★推奨
// --------------------------------------------
console.log("\n=== async / await ===");

async function getData() {
  try {
    console.log("データ取得開始...");
    const data = await fetchDataPromise();  // 完了を「待つ」
    console.log("async/await成功:", data);
  } catch (error) {
    console.log("エラー:", error);
  }
}

getData();

// --------------------------------------------
// 4. 比較
// --------------------------------------------
setTimeout(() => {
  console.log("\n=== 3つの書き方比較 ===");
  console.log(`
// 1. コールバック（古い）
fetchData((data) => {
  console.log(data);
});

// 2. Promise + then
fetchData()
  .then((data) => console.log(data))
  .catch((err) => console.log(err));

// 3. async/await（推奨）★
async function main() {
  try {
    const data = await fetchData();
    console.log(data);
  } catch (err) {
    console.log(err);
  }
}
`);
  console.log("✅ Lesson 7 完了！");
}, 3000);
