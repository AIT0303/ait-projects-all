// ============================================
// Lesson 8: fetch API
// ============================================

// 実行コマンド: node phase2/04-fetch.js

// fetch = サーバーからデータを取得する関数
// Python の requests.get() と同じ役割

// --------------------------------------------
// 1. 基本形
// --------------------------------------------
console.log("=== fetch 基本形 ===\n");

async function getUser() {
  // JSONPlaceholder = 無料のテスト用API
  const response = await fetch("https://jsonplaceholder.typicode.com/users/1");
  const data = await response.json();  // JSON をオブジェクトに変換
  console.log("ユーザー情報:", data.name, data.email);
}

getUser();

// --------------------------------------------
// 2. 複数データの取得
// --------------------------------------------
async function getPosts() {
  const response = await fetch("https://jsonplaceholder.typicode.com/posts?_limit=3");
  const posts = await response.json();

  console.log("\n=== 投稿一覧（3件） ===");
  posts.forEach((post) => {
    console.log(`- ${post.title.substring(0, 30)}...`);
  });
}

getPosts();

// --------------------------------------------
// 3. エラーハンドリング
// --------------------------------------------
async function fetchWithError() {
  try {
    const response = await fetch("https://jsonplaceholder.typicode.com/users/1");

    // ステータスコードをチェック
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log("\n=== エラーハンドリング ===");
    console.log("成功:", data.name);
  } catch (error) {
    console.log("エラー発生:", error.message);
  }
}

fetchWithError();

// --------------------------------------------
// 4. POST リクエスト（データを送信）
// --------------------------------------------
async function createPost() {
  const newPost = {
    title: "新しい投稿",
    body: "これはテスト投稿です",
    userId: 1,
  };

  const response = await fetch("https://jsonplaceholder.typicode.com/posts", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(newPost),  // オブジェクト → JSON文字列
  });

  const data = await response.json();
  console.log("\n=== POST リクエスト ===");
  console.log("作成された投稿:", data);
}

createPost();

// --------------------------------------------
// 5. Python との比較
// --------------------------------------------
setTimeout(() => {
  console.log("\n=== Python vs JavaScript ===");
  console.log(`
Python (requests):
  import requests
  response = requests.get("https://api.example.com/data")
  data = response.json()

JavaScript (fetch):
  const response = await fetch("https://api.example.com/data");
  const data = await response.json();
`);

  console.log("=== fetch まとめ ===");
  console.log(`
GET:
  const res = await fetch(url);
  const data = await res.json();

POST:
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
`);

  console.log("✅ Lesson 8 完了！");
}, 2000);
