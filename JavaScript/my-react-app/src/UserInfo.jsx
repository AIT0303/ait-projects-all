import { useState, useEffect } from 'react'

function UserInfo() {
  const [user, setUser] = useState(null)

  useEffect(() => {
    // コンポーネントが表示された時に実行される
    fetch('https://jsonplaceholder.typicode.com/users/1')
      .then(response => response.json())
      .then(data => setUser(data))
  }, [])  // ← 空配列 = 最初の1回だけ実行

  if (!user) {
    return <p>読み込み中...</p>
  }

  return (
    <div>
      <h3>ユーザー情報</h3>
      <p>名前: {user.name}</p>
      <p>メール: {user.email}</p>
    </div>
  )
}

export default UserInfo
