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

# BankQu Production Deployment - Code Fixes

## Overview

Dokumentasi ini menjelaskan error-error di kode aplikasi yang perlu diperbaiki untuk deployment production. Error ini teridentifikasi saat deployment ke `https://bankqu.ekagalang.my.id`.

## Frontend Issues

### 1. Hardcoded API URLs

**Problem:** Frontend menggunakan hardcoded localhost URLs yang tidak berfungsi di production.

**Files yang bermasalah:**
- `src/contexts/AuthContext.js`
- `src/services/api.js`

**Error Code:**
```javascript
// ❌ WRONG - Hardcoded localhost
const API_BASE_URL = 'http://localhost:8000/api';
```

**Fix:**
```javascript
// ✅ CORRECT - Use environment variable
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://bankqu.ekagalang.my.id/api';
```

### 2. Environment Configuration

**Problem:** Environment variables tidak dikonfigurasi untuk production.

**File:** `.env`

**Error Code:**
```bash
# ❌ WRONG - HTTP and localhost
REACT_APP_API_URL=http://localhost:8000/api
```

**Fix:**
```bash
# ✅ CORRECT - HTTPS and production domain
REACT_APP_API_URL=https://bankqu.ekagalang.my.id/api
GENERATE_SOURCEMAP=false
NODE_ENV=production
```

### 3. Mixed Content Error

**Problem:** HTTPS site trying to load HTTP resources causes browser to block requests.

**Symptoms:**
```
Blocked loading mixed active content "http://bankqu.ekagalang.my.id/api/login"
```

**Fix:** Ensure all API URLs use HTTPS in production environment.

## Backend Issues

### 1. CORS Configuration

**Problem:** CORS hanya mengizinkan localhost, memblokir requests dari production domain.

**File:** `config/cors.php`

**Error Code:**
```php
<?php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:3000',      // ❌ Only localhost
        'http://127.0.0.1:3000',
        'http://localhost:3001',
        'http://127.0.0.1:3001'
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

**Fix:**
```php
<?php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://bankqu.ekagalang.my.id',  // ✅ Production domain
        'http://bankqu.ekagalang.my.id',   // ✅ HTTP fallback
        'http://localhost:3000',           // ✅ Keep for development
        'http://127.0.0.1:3000'
    ],
    'allowed_origins_patterns' => [
        'https://*.ekagalang.my.id'        // ✅ Wildcard for subdomains
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-XSRF-TOKEN'],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 2. Database Schema Missing Column

**Problem:** Database table `investments` missing `is_active` column yang dibutuhkan controller.

**Error:**
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'is_active' in 'where clause'
```

**File affected:** `app/Http/Controllers/API/InvestmentController.php` line 16

**Fix:** Create migration to add missing column:

```bash
php artisan make:migration add_is_active_to_investments_table
```

**Migration code:**
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('investments', function (Blueprint $table) {
            $table->boolean('is_active')->default(true);
        });
    }

    public function down()
    {
        Schema::table('investments', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
```

### 3. Environment Configuration

**Problem:** Laravel environment tidak dikonfigurasi untuk production domain.

**File:** `.env`

**Required production settings:**
```bash
APP_NAME=BankQu
APP_ENV=production
APP_DEBUG=false
APP_URL=https://bankqu.ekagalang.my.id

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=bankqu_db
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# Sanctum & CORS for subdomain
SANCTUM_STATEFUL_DOMAINS=bankqu.ekagalang.my.id,*.ekagalang.my.id
SESSION_DOMAIN=.ekagalang.my.id
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax

# Cache & Session
CACHE_STORE=file
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Asset URL
ASSET_URL=https://bankqu.ekagalang.my.id
```

## Error Timeline dan Solutions

### 1. Login CORS Error
**Symptom:** Cross-Origin Request Blocked
**Root cause:** Frontend using localhost, CORS not allowing production domain
**Fix:** Update frontend API URLs + CORS configuration

### 2. Mixed Content Error
**Symptom:** Blocked loading mixed active content
**Root cause:** HTTPS site loading HTTP resources
**Fix:** Ensure all URLs use HTTPS in production

### 3. 500 Error on Investments
**Symptom:** Server error when accessing investments endpoint
**Root cause:** Missing database column
**Fix:** Add migration for `is_active` column

## Development vs Production Configuration

### Frontend Environment Variables

**Development (.env.local):**
```bash
REACT_APP_API_URL=http://localhost:8000/api
```

**Production (.env):**
```bash
REACT_APP_API_URL=https://bankqu.ekagalang.my.id/api
```

### Backend CORS Configuration

**Best Practice:** Include both development and production domains:
```php
'allowed_origins' => [
    'https://bankqu.ekagalang.my.id',  // Production
    'http://localhost:3000',           // Development
    'http://127.0.0.1:3000'            // Development
],
```

## Testing Commands

### Frontend
```bash
# Check for hardcoded localhost URLs
grep -r "localhost:8000" src/

# Verify environment variable usage
grep -r "process.env.REACT_APP_API_URL" src/

# Check build output
npm run build
grep -r "localhost" build/ || echo "Clean build"
```

### Backend
```bash
# Test CORS
curl -X OPTIONS https://bankqu.ekagalang.my.id/api/login \
  -H "Origin: https://bankqu.ekagalang.my.id" \
  -H "Access-Control-Request-Method: POST"

# Test API endpoint
curl https://bankqu.ekagalang.my.id/api/health

# Check database migration status
php artisan migrate:status
```

## Deployment Checklist

### Pre-deployment
- [ ] Update hardcoded URLs to use environment variables
- [ ] Configure CORS for production domain
- [ ] Create necessary database migrations
- [ ] Update environment files for production

### Post-deployment
- [ ] Run database migrations
- [ ] Test login functionality
- [ ] Test all API endpoints
- [ ] Verify HTTPS is working
- [ ] Check browser console for errors

## Common Pitfalls

1. **Forgetting to rebuild frontend** after changing environment variables
2. **Not including production domain in CORS** configuration
3. **Using HTTP URLs in HTTPS environment** (mixed content)
4. **Missing database columns** referenced in controller code
5. **Hardcoded URLs in source code** instead of environment variables

## Future Development

To avoid these issues in future development:

1. **Always use environment variables** for API URLs
2. **Include both dev and prod domains** in CORS from start
3. **Keep database migrations in sync** between environments
4. **Test with production-like setup** before deployment
5. **Use HTTPS in development** when possible
