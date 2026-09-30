import React, { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState('Loading...');

  useEffect(() => {
    fetch('/api/hello')
      .then((res) => res.json())
      .then((data) => setMessage(data.message))
      .catch((err) => setMessage('Error connecting to backend'));
  }, []);

  // FIXED: Removed the loose, undefined getOrigin() call that was crashing your build pipeline

  return (
    <div style={{ textAlign: 'center', marginTop: '50px', fontFamily: 'Arial' }}>
      <h1>🚀 React + Node.js App Deployed on AWS EC2</h1>
      <p>Automated beautifully via <strong>Terraform</strong>.</p>
      <p>Deployed using <strong>Docker</strong>.</p>
      {/* FIXED: Added the state output message to see your API connectivity status */}
      <p style={{ marginTop: '20px', fontSize: '18px', color: '#0070f3' }}>
        Backend status: <strong>{message}</strong>
      </p>
    </div>
  );
}

export default App;
