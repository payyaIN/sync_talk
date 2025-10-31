
import https from 'https';
export async function sendFcm(serverKey: string, to: string, title: string, body: string) {
  const payload = JSON.stringify({ to, notification: { title, body } });
  const options = { hostname: 'fcm.googleapis.com', path: '/fcm/send', method: 'POST',
    headers: { 'Authorization': `key=${serverKey}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) } };
  await new Promise<void>((resolve, reject)=>{ const req = https.request(options, res=>{ res.on('data',()=>{}); res.on('end',()=>resolve()); }); req.on('error', reject); req.write(payload); req.end(); });
}
