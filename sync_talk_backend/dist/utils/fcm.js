"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendFcm = sendFcm;
const https_1 = __importDefault(require("https"));
// export async function sendFcm(serverKey: string, to: string, title: string, body: string) {
//   const payload = JSON.stringify({ to, notification: { title, body } });
//   const options = { hostname: 'fcm.googleapis.com', path: '/fcm/send', method: 'POST',
//     headers: { 'Authorization': `key=${serverKey}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) } };
//   await new Promise<void>((resolve, reject)=>{ const req = https.request(options, res=>{ res.on('data',()=>{}); res.on('end',()=>resolve()); }); req.on('error', reject); req.write(payload); req.end(); });
// }
async function sendFcm(serverKey, token, title, body) {
    try {
        const payload = JSON.stringify({ token, notification: { title, body } });
        const options = { hostname: 'fcm.googleapis.com', path: '/fcm/send', method: 'POST',
            headers: { 'Authorization': `key=${serverKey}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) } };
        await new Promise((resolve, reject) => { const req = https_1.default.request(options, res => { res.on('data', () => { }); res.on('end', () => resolve()); }); req.on('error', reject); req.write(payload); req.end(); });
        console.log(`FCM notification sent: ${title}`);
    }
    catch (error) {
        console.error('FCM error:', error);
    }
}
