async function testLogin() {
  try {
    const response = await fetch('https://sync-talk-backend-4ubc.onrender.com/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'admin@synctalk.com',
        password: 'admin123'
      })
    });
    const data = await response.json();
    console.log('Status:', response.status);
    console.log('Response:', data);
  } catch (error: any) {
    console.error('Fetch failed:', error.message);
  }
}

testLogin();
