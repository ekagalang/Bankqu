# 🏦 BankQu - Personal Finance Management

Docker-based personal finance management application with React frontend and Laravel backend.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Git

### Setup (Any Device)
```bash
# 1. Clone repository
git clone https://github.com/yourusername/bankqu-docker.git
cd bankqu-docker

# 2. Setup environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 3. Generate Laravel app key
cd backend
php artisan key:generate
cd ..

# 4. Start Docker containers
docker-compose up -d

# 5. Setup database
docker-compose exec backend php artisan migrate --force
docker-compose exec backend php artisan db:seed --force

Access Application

Frontend: http://localhost:3000
Backend: http://localhost:8000
API: http://localhost:8000/api/health

Default Login

Email: admin@bankqu.com
Password: admin123

🛠️ Development
Start Development
bashdocker-compose up -d
Stop Development
bashdocker-compose down
View Logs
bashdocker-compose logs -f
Reset Database
bashdocker-compose exec backend php artisan migrate:fresh --seed
🏗️ Architecture

Frontend: React 18 with Tailwind CSS
Backend: Laravel 11 with Sanctum
Database: SQLite (development)
Containerization: Docker Compose

📁 Project Structure
bankqu-docker/
├── frontend/          # React application
├── backend/           # Laravel API
├── docker-compose.yml # Docker configuration
└── README.md
🔧 Troubleshooting
Reset Everything
bashdocker-compose down -v
docker-compose build --no-cache
docker-compose up -d
Backend Issues
bashdocker-compose exec backend php artisan config:clear
docker-compose exec backend php artisan cache:clear
📝 License
This project is open source and available under the MIT License.

---

## 🔄 STEP 4: Migration ke Device Baru

### 4.1 Prerequisites di Device Baru
1. **Install Docker Desktop**
2. **Install Git**
3. **Restart computer** setelah install Docker

### 4.2 Clone & Setup
```bash
# 1. Clone repository
git clone https://github.com/yourusername/bankqu-docker.git
cd bankqu-docker

# 2. Setup environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 3. Generate new Laravel app key
cd backend
php artisan key:generate
cd ..

# 4. Start containers (first time akan download images)
docker-compose up -d

# 5. Wait for containers to start (60-120 seconds)
docker-compose ps

# 6. Setup database
docker-compose exec backend php artisan migrate:fresh --seed --force

# 7. Test application
curl http://localhost:8000/api/health
4.3 Verification Checklist

 ✅ Docker containers running: docker-compose ps
 ✅ Backend health check: http://localhost:8000/api/health
 ✅ Frontend accessible: http://localhost:3000
 ✅ Login working: admin@bankqu.com / admin123


🔐 STEP 5: Security & Best Practices
5.1 Environment Security
bash# Generate unique app keys per environment
php artisan key:generate

# Use different passwords per environment
# Update database passwords
# Use environment-specific CORS settings
5.2 Production Considerations

Use MySQL/PostgreSQL instead of SQLite
Set APP_ENV=production
Use real SSL certificates
Configure proper CORS settings
Use secure passwords


🚀 STEP 6: Advanced Deployment
6.1 Production Docker Compose
yaml# docker-compose.prod.yml
version: '3.8'
services:
  frontend:
    build: 
      context: ./frontend
      target: production
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  backend:
    build: ./backend
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
6.2 Cloud Deployment Commands
bash# Production deployment
docker-compose -f docker-compose.prod.yml up -d

# With custom environment
docker-compose --env-file .env.production up -d

📋 Migration Checklist
From Current Device:

 ✅ Add .gitignore
 ✅ Create .env.example files
 ✅ Remove sensitive data
 ✅ Create README.md
 ✅ Push to GitHub

To New Device:

 ✅ Install Docker Desktop
 ✅ Clone repository
 ✅ Copy environment files
 ✅ Generate app key
 ✅ Start Docker containers
 ✅ Run migrations
 ✅ Test application


🎯 Benefits of This Setup

Consistent Environment - Same setup di semua device
Easy Migration - Clone & run commands
No PHP/Node Installation - Everything in Docker
Database Included - SQLite portable
Development Ready - Hot reload enabled
Production Ready - Easy to deploy


💡 Tips

Always run docker-compose ps untuk check container status
Use docker-compose logs untuk debug issues
Keep .env files private (never commit)
Update README.md dengan project changes
Tag releases dengan git tag v1.0.0 untuk versioning

Happy coding! 🚀
