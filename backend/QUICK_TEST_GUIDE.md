## Quick Testing Guide for Mobile Devices

### 1. Get Your Computer's IP Address

Run this command in your terminal:

**Windows PowerShell:**
```powershell
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*"}).IPAddress
```

**Or simply:**
```cmd
ipconfig
```

Look for your local IP (usually `192.168.x.x`)

---

### 2. Test from Mobile Device/Emulator

Replace `YOUR_IP` with your actual IP address (e.g., `192.168.1.68`)

#### Test 1: Health Check (No Auth Required)
```
GET http://YOUR_IP:5257/api/Auth/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "message": "API is running and accessible"
}
```

#### Test 2: Login
```
POST http://YOUR_IP:5257/api/Auth/login
Content-Type: application/json

{
  "email": "your@email.com",
  "password": "yourpassword"
}
```

**Expected Success Response:**
```json
{
  "accessToken": "eyJhbGciOiJI...",
  "refreshToken": "abc123..."
}
```

#### Test 3: Register
```
POST http://YOUR_IP:5257/api/Auth/register
Content-Type: application/json

{
  "email": "new@email.com",
  "password": "password123",
  "name": "John Doe",
  "phoneNumber": "1234567890",
  "role": "tourist"
}
```

---

### 3. Special Cases

#### Android Emulator (AVD)
Use this special IP instead of your computer's IP:
```
http://10.0.2.2:5257/api/Auth/login
```

#### iOS Simulator
Use localhost:
```
http://localhost:5257/api/Auth/login
```

#### Real Android/iOS Device
Use your computer's actual IP:
```
http://192.168.1.68:5257/api/Auth/login
```

---

### 4. Troubleshooting Checklist

- [ ] Computer and device on same WiFi network
- [ ] Firewall allows port 5257 (see MOBILE_SETUP.md)
- [ ] Using correct IP address (not localhost/127.0.0.1)
- [ ] Backend server is running (check Visual Studio debug console)
- [ ] Health endpoint responds successfully

---

### 5. Check Server Logs

When you make a request, you should see logs like this in Visual Studio Output window:

```
[2024-01-15 10:30:00] POST /api/Auth/login from 192.168.1.100
Headers: Content-Type=application/json, Accept=*/*
Login attempt for email: user@example.com
Login successful for email: user@example.com
Response Status: 200
```

If you don't see these logs, the request isn't reaching the server (network/firewall issue).

---

### 6. Windows Firewall Quick Fix

Run this in PowerShell as Administrator:

```powershell
New-NetFirewallRule -DisplayName "ASP.NET Core Backend" -Direction Inbound -Protocol TCP -LocalPort 5257 -Action Allow
```

Or manually:
1. Windows Defender Firewall ? Advanced Settings
2. Inbound Rules ? New Rule
3. Port ? TCP ? 5257
4. Allow the connection ? All profiles ? Name it "Backend API"
