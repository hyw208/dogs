import './App.css';
import { useEffect, useState } from 'react';

export function App() {
  const [now, setNow] = useState<string>(new Date().toLocaleTimeString());

  useEffect(() => {
    const id = setInterval(() => {
      setNow(new Date().toLocaleTimeString());
    }, 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <main className="app">
      <h1>Hello dogs~</h1>
      <p>Welcome to the starter React + Vite UI.</p>
      <div className="clock" aria-live="polite">Current time: {now}</div>
      <div className="button-group">
        <button className="btn btn-primary">Login</button>
        <button className="btn btn-secondary">Walk</button>
      </div>
    </main>
  );
}
