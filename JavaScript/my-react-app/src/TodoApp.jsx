import { useState } from 'react'

function TodoApp() {
  const [todos, setTodos] = useState([])
  const [input, setInput] = useState('')

  // タスクを追加
  const addTodo = () => {
    if (input.trim() === '') return
    setTodos([...todos, { id: Date.now(), text: input, done: false }])
    setInput('')
  }

  // タスクを削除
  const deleteTodo = (id) => {
    setTodos(todos.filter(todo => todo.id !== id))
  }

  // 完了/未完了を切り替え
  const toggleTodo = (id) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    ))
  }

  return (
    <div style={{ padding: '20px', maxWidth: '400px' }}>
      <h2>Todo リスト</h2>
      
      <div>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="タスクを入力"
          onKeyDown={(e) => e.key === 'Enter' && addTodo()}
        />
        <button onClick={addTodo}>追加</button>
      </div>

      <ul style={{ listStyle: 'none', padding: 0 }}>
        {todos.map(todo => (
          <li key={todo.id} style={{ margin: '10px 0' }}>
            <input
              type="checkbox"
              checked={todo.done}
              onChange={() => toggleTodo(todo.id)}
            />
            <span style={{ 
              textDecoration: todo.done ? 'line-through' : 'none',
              marginLeft: '10px'
            }}>
              {todo.text}
            </span>
            <button 
              onClick={() => deleteTodo(todo.id)}
              style={{ marginLeft: '10px' }}
            >
              削除
            </button>
          </li>
        ))}
      </ul>
    </div>
  )
}

export default TodoApp
