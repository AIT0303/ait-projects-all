import { useState } from 'react'
import './App.css'

function App() {
  const [display, setDisplay] = useState('0')
  const [firstNum, setFirstNum] = useState(null)
  const [operator, setOperator] = useState(null)
  const [waitingForSecond, setWaitingForSecond] = useState(false)

  const inputNumber = (num) => {
    if (waitingForSecond) {
      setDisplay(num)
      setWaitingForSecond(false)
    } else {
      setDisplay(display === '0' ? num : display + num)
    }
  }

  const inputOperator = (op) => {
    setFirstNum(parseFloat(display))
    setOperator(op)
    setWaitingForSecond(true)
  }

  const calculate = () => {
    if (firstNum === null || operator === null) return
    
    const second = parseFloat(display)
    let result
    
    switch (operator) {
      case '+': result = firstNum + second; break
      case '-': result = firstNum - second; break
      case '×': result = firstNum * second; break
      case '÷': result = second !== 0 ? firstNum / second : 'Error'; break
      default: return
    }
    
    setDisplay(String(result))
    setFirstNum(null)
    setOperator(null)
  }

  const clear = () => {
    setDisplay('0')
    setFirstNum(null)
    setOperator(null)
    setWaitingForSecond(false)
  }

  return (
    <div className="calculator">
      <div className="display">{display}</div>
      <div className="buttons">
        <button className="clear" onClick={clear}>C</button>
        <button className="operator" onClick={() => inputOperator('÷')}>÷</button>
        <button className="operator" onClick={() => inputOperator('×')}>×</button>
        <button className="operator" onClick={() => inputOperator('-')}>−</button>
        
        <button onClick={() => inputNumber('7')}>7</button>
        <button onClick={() => inputNumber('8')}>8</button>
        <button onClick={() => inputNumber('9')}>9</button>
        <button className="operator" onClick={() => inputOperator('+')}>+</button>
        
        <button onClick={() => inputNumber('4')}>4</button>
        <button onClick={() => inputNumber('5')}>5</button>
        <button onClick={() => inputNumber('6')}>6</button>
        <button className="equals" onClick={calculate}>=</button>
        
        <button onClick={() => inputNumber('1')}>1</button>
        <button onClick={() => inputNumber('2')}>2</button>
        <button onClick={() => inputNumber('3')}>3</button>
        <button className="zero" onClick={() => inputNumber('0')}>0</button>
      </div>
    </div>
  )
}

export default App
