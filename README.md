# Task Manager App

A full-stack Task Manager application built with **Flutter** (frontend) and **Node.js + Express** (backend), using **MongoDB Atlas** for data persistence and **JWT** for authentication.

## 📁 Project Structure

```
/task-manager-app
  /flutter_app         → Flutter frontend (Dart)
  /backend             → Node.js + Express backend
```

## 🚀 Backend Setup

### Prerequisites
- Node.js v18+ and npm
- MongoDB Atlas account (free tier works)

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Copy the example env file and update with your credentials:

```bash
cp .env.example .env
```

Edit `.env`:

```env
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/taskmanager?retryWrites=true&w=majority
JWT_SECRET=your_super_secret_jwt_key_here
PORT=5000
```

### 3. Connect MongoDB Atlas

1. Go to [MongoDB Atlas](https://cloud.mongodb.com/)
2. Create a free cluster
3. Create a database user with username and password
4. Whitelist your IP address (or `0.0.0.0/0` for dev)
5. Click "Connect" → "Connect your application"
6. Copy the connection string and paste it in `.env` as `MONGO_URI`

### 4. Seed the First Manager Account

```bash
npm run seed
```

This creates:
- **Email:** `manager@taskmanager.com`
- **Password:** `manager123`
- **Role:** `manager`

> ⚠️ Change the password after first login!

### 5. Run the Backend

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server runs on `http://localhost:5000`

---

## 📱 Flutter App Setup

### Prerequisites
- Flutter SDK 3.1+
- Android Studio / VS Code with Flutter extension

### 1. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 2. Configure API URL

Edit `lib/utils/constants.dart`:

```dart
// Default for all platforms
static const String baseUrl =
   'https://wholesome-possibility-production.up.railway.app/api';

// Optional: override via --dart-define
// BACKEND_URL, BACKEND_URL_ANDROID, BACKEND_URL_IOS
```

### 3. Run the App

```bash
flutter run
```

---

## 🌐 Deploy Backend to Render.com

1. Push the `backend` folder to a GitHub repository
2. Go to [Render.com](https://render.com) → New → Web Service
3. Connect your GitHub repo
4. Configure:
   - **Root Directory:** `backend`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `node server.js`
5. Add Environment Variables:
   - `MONGO_URI` → Your MongoDB Atlas connection string
   - `JWT_SECRET` → A strong secret key
   - `PORT` → `5000`
6. Deploy!

After deployment, update the Flutter app's `baseUrl` to your Render URL.

---

## 🔐 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login (returns JWT) |
| GET | `/api/auth/me` | Get current user |

### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks (filters: status, date) |
| GET | `/api/tasks/:id` | Get single task with activity log |
| POST | `/api/tasks` | Create task [Manager] |
| PUT | `/api/tasks/:id` | Edit task [Manager] |
| DELETE | `/api/tasks/:id` | Delete task [Manager] |
| PATCH | `/api/tasks/:id/status` | Change status [Any role] |

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users [Manager] |
| POST | `/api/users` | Create team member [Manager] |
| PATCH | `/api/users/:id/deactivate` | Deactivate [Manager] |
| PATCH | `/api/users/:id/activate` | Activate [Manager] |
| DELETE | `/api/users/:id` | Delete user [Manager] |

### Activity
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/activity` | All activity feed [Manager] |

---

## 👥 User Roles

- **Manager**: Full control — create/edit/delete tasks, manage team, view activity
- **Sales Team**: View tasks, change task status (auto-logged with identity)

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter + Dart |
| State Management | Provider |
| HTTP Client | Dio (with JWT interceptor) |
| Navigation | GoRouter (role-based) |
| Backend | Node.js + Express.js |
| Database | MongoDB Atlas (Mongoose) |
| Auth | JWT (7-day expiry) |
| Password Hashing | bcryptjs |
| Validation | express-validator |
