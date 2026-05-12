import { useState } from 'react'
import './App.css'

function App() {
  const [result, setResult] = useState('')
  const [playerHand, setPlayerHand] = useState('')
  const [cpuHand, setCpuHand] = useState('')
  const [score, setScore] = useState({ win: 0, lose: 0, draw: 0 })

  const hands = ['グー', 'チョキ', 'パー']

  const play = (player) => {
    const cpu = hands[Math.floor(Math.random() * 3)]
    setPlayerHand(player)
    setCpuHand(cpu)

    if (player === cpu) {
      setResult('draw')
      setScore({ ...score, draw: score.draw + 1 })
    } else if (
      (player === 'グー' && cpu === 'チョキ') ||
      (player === 'チョキ' && cpu === 'パー') ||
      (player === 'パー' && cpu === 'グー')
    ) {
      setResult('win')
      setScore({ ...score, win: score.win + 1 })
    } else {
      setResult('lose')
      setScore({ ...score, lose: score.lose + 1 })
    }
  }

  const getResultText = () => {
    if (result === 'win') return '勝ち！🎉'
    if (result === 'lose') return '負け...💦'
    if (result === 'draw') return 'あいこ！🤝'
    return ''
  }

  return (
    <div className="game-container">
      <h1>じゃんけんゲーム</h1>

      <div className="hands">
        {hands.map(hand => (
          <button
            key={hand}
            className="hand-btn"
            onClick={() => play(hand)}
          >
            {hand === 'グー' ? '✊' : hand === 'チョキ' ? '✌️' : '🖐️'}
          </button>
        ))}
      </div>

      {result && (
        <div className="result-area">
          <p className="battle">
            あなた: {playerHand} vs CPU: {cpuHand}
          </p>
          <p className={`result ${result}`}>{getResultText()}</p>
        </div>
      )}

      <div className="score-board">
        <div className="score-item win">勝ち: {score.win}</div>
        <div className="score-item draw">あいこ: {score.draw}</div>
        <div className="score-item lose">負け: {score.lose}</div>
      </div>
    </div>
  )
}

export default App
