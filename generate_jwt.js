const jwt = require('jsonwebtoken');
const fs = require('fs');

// Apple Developer Console에서 확인한 정보
const TEAM_ID = 'YOUR_TEAM_ID'; // Apple Developer Console에서 확인
const KEY_ID = 'KXG8TRVC36';
const CLIENT_ID = 'com.yourcompany.luckywalk.signin';

// Private Key 파일 경로
const privateKeyPath = '/Users/noahs/Downloads/AuthKey_KXG8TRVC36.p8';

// Private Key 읽기
const privateKey = fs.readFileSync(privateKeyPath, 'utf8');

// JWT 생성
const now = Math.floor(Date.now() / 1000);
const token = jwt.sign(
  {
    iss: TEAM_ID,
    iat: now,
    exp: now + 3600, // 1시간 후 만료
    aud: 'https://appleid.apple.com',
    sub: CLIENT_ID
  },
  privateKey,
  {
    algorithm: 'ES256',
    header: {
      kid: KEY_ID
    }
  }
);

console.log('Generated JWT Token:');
console.log(token);
