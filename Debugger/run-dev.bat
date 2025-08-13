@echo off
echo 🚀 Starting BankQu Development Environment...
echo =============================================

:: Change to project root directory
cd /d "%~dp0"

:: Check if backend folder exists
if not exist "backend" (
    echo ❌ Backend folder not found!
    pause
    exit /b 1
)

:: Check if frontend folder exists
if not exist "frontend" (
    echo ❌ Frontend folder not found!
    pause
    exit /b 1
)

:: Setup Backend
echo.
echo 🏗️ Setting up Backend (Laravel)...
cd backend

:: Check .env file
if not exist ".env" (
    echo 📝 Creating .env file...
    copy ".env.example" ".env" >nul
    php artisan key:generate
)

:: Install dependencies if needed
if not exist "vendor" (
    echo 📦 Installing PHP dependencies...
    composer install
)

:: Run migrations and seeders
echo 🗄️ Setting up database...
php artisan migrate --force >nul 2>&1
echo 🌱 Running seeders...
php artisan db:seed --force >nul 2>&1

echo ✅ Backend setup complete

:: Setup Frontend
echo.
echo 🎨 Setting up Frontend (React)...
cd ../frontend

:: Install dependencies if needed
if not exist "node_modules" (
    echo 📦 Installing Node dependencies...
    npm install
)

echo ✅ Frontend setup complete

:: Start Backend in background
echo.
echo 🚀 Starting Development Servers...
echo ====================================
echo 📡 Starting Laravel Backend (Port 8000)...
cd ../backend
start "Laravel Backend" cmd /k "php artisan serve --host=127.0.0.1 --port=8000"

:: Wait a bit for backend to start
timeout /t 3 /nobreak >nul

:: Start Frontend
echo 🎨 Starting React Frontend (Port 3000)...
cd ../frontend

echo.
echo 🎉 Development Environment Ready!
echo =================================
echo 📍 Backend:  http://127.0.0.1:8000
echo 📍 Frontend: http://127.0.0.1:3000
echo 📍 API:      http://127.0.0.1:8000/api
echo 📍 Health:   http://127.0.0.1:8000/api/health
echo.
echo 🔑 Login Credentials:
echo    Email: admin@bankqu.com
echo    Password: admin123
echo.
echo Press Ctrl+C to stop React server
echo Close the Laravel window to stop backend
echo.

:: Start Frontend (this will block)
npm start

pause