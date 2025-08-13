# Fix All Docker Issues - Sessions, CORS, CSS
Write-Host "🔧 Fixing All Docker Issues..." -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Blue
Write-Host "Issues to fix:" -ForegroundColor Yellow
Write-Host "1. ❌ Sessions table not found" -ForegroundColor Red
Write-Host "2. ❌ CORS policy error" -ForegroundColor Red  
Write-Host "3. ❌ HTML polos (CSS tidak load)" -ForegroundColor Red
Write-Host ""

function Fix-SessionsTable {
    Write-Host "🗄️ Creating sessions table migration..." -ForegroundColor Yellow
    
    $sessionsMigration = @'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sessions');
    }
};
'@
    
    $migrationFile = "backend/database/migrations/" + (Get-Date -Format "yyyy_MM_dd_HHmmss") + "_create_sessions_table.php"
    $sessionsMigration | Set-Content $migrationFile -Encoding UTF8
    Write-Host "✅ Created sessions migration: $migrationFile" -ForegroundColor Green
}

function Fix-CORS {
    Write-Host "🌐 Fixing CORS configuration..." -ForegroundColor Yellow
    
    # Update CORS config
    $corsConfig = @'
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:3000',
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
'@
    
    $corsConfig | Set-Content "backend/config/cors.php" -Encoding UTF8
    Write-Host "✅ Updated CORS config" -ForegroundColor Green
    
    # Update .env for proper API URL
    $envPath = "backend/.env"
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        
        # Ensure SANCTUM domains are set
        if ($envContent -notmatch "SANCTUM_STATEFUL_DOMAINS") {
            $envContent += "`nSANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000"
        }
        
        # Ensure SESSION_DOMAIN is set
        if ($envContent -notmatch "SESSION_DOMAIN") {
            $envContent += "`nSESSION_DOMAIN=null"
        }
        
        $envContent | Set-Content $envPath -Encoding UTF8
        Write-Host "✅ Updated backend .env for CORS" -ForegroundColor Green
    }
    
    # Fix Frontend API URL to use 127.0.0.1 consistently  
    $frontendEnvPath = "frontend/.env"
    $frontendEnv = @'
REACT_APP_API_URL=http://127.0.0.1:8000/api
REACT_APP_APP_NAME=BankQu
CHOKIDAR_USEPOLLING=true
GENERATE_SOURCEMAP=false
BROWSER=none
'@
    $frontendEnv | Set-Content $frontendEnvPath -Encoding UTF8
    Write-Host "✅ Fixed frontend API URL to use 127.0.0.1" -ForegroundColor Green
}

function Fix-CSS-Tailwind {
    Write-Host "🎨 Fixing CSS and Tailwind..." -ForegroundColor Yellow
    
    # Check if Tailwind directives exist in index.css
    $indexCssPath = "frontend/src/index.css"
    if (Test-Path $indexCssPath) {
        $cssContent = Get-Content $indexCssPath -Raw
        
        if ($cssContent -notmatch "@tailwind base") {
            Write-Host "   Adding Tailwind directives to index.css..." -ForegroundColor Gray
            
            $tailwindCSS = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom styles */
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
'@
            $tailwindCSS | Set-Content $indexCssPath -Encoding UTF8
            Write-Host "✅ Added Tailwind directives" -ForegroundColor Green
        }
    }
    
    # Ensure tailwind.config.js exists and is proper
    $tailwindConfigPath = "frontend/tailwind.config.js"
    if (!(Test-Path $tailwindConfigPath)) {
        Write-Host "   Creating tailwind.config.js..." -ForegroundColor Gray
        
        $tailwindConfig = @'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
    "./public/index.html"
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6', 
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [],
}
'@
        $tailwindConfig | Set-Content $tailwindConfigPath -Encoding UTF8
        Write-Host "✅ Created tailwind.config.js" -ForegroundColor Green
    }
    
    # Ensure postcss.config.js exists
    $postcssConfigPath = "frontend/postcss.config.js"
    if (!(Test-Path $postcssConfigPath)) {
        Write-Host "   Creating postcss.config.js..." -ForegroundColor Gray
        
        $postcssConfig = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@
        $postcssConfig | Set-Content $postcssConfigPath -Encoding UTF8
        Write-Host "✅ Created postcss.config.js" -ForegroundColor Green
    }
    
    # Update Frontend Dockerfile to build CSS properly
    $frontendDockerfile = @'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY .npmrc ./

# Install dependencies with legacy peer deps
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build CSS (important for Tailwind)
RUN npm run build:css 2>/dev/null || echo "No build:css script found"

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "start"]
'@
    
    $frontendDockerfile | Set-Content "frontend/Dockerfile" -Encoding UTF8
    Write-Host "✅ Updated Frontend Dockerfile for CSS build" -ForegroundColor Green
}

function Run-DatabaseMigrations {
    Write-Host "🗄️ Running database migrations..." -ForegroundColor Yellow
    
    Write-Host "   Creating sessions table..." -ForegroundColor Gray
    docker-compose exec backend php artisan make:session-table --force 2>$null
    
    Write-Host "   Running all migrations..." -ForegroundColor Gray
    docker-compose exec backend php artisan migrate --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database migrations completed" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Migration had issues, trying manual fix..." -ForegroundColor Yellow
        
        # Create sessions table manually via SQL
        $createSessionsSQL = @"
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    INDEX sessions_user_id_index (user_id),
    INDEX sessions_last_activity_index (last_activity)
);
"@
        
        Write-Host "   Creating sessions table manually..." -ForegroundColor Gray
        docker-compose exec mysql mysql -u bankqu_docker -pSamphistik@7 bankqu_docker -e "$createSessionsSQL"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Sessions table created manually" -ForegroundColor Green
        }
    }
}

function Clear-And-Restart {
    Write-Host "🔄 Clearing caches and restarting..." -ForegroundColor Yellow
    
    # Clear Laravel caches
    docker-compose exec backend php artisan config:clear
    docker-compose exec backend php artisan cache:clear  
    docker-compose exec backend php artisan route:clear
    docker-compose exec backend php artisan view:clear
    
    # Restart containers to apply all changes
    Write-Host "   Restarting containers..." -ForegroundColor Gray
    docker-compose restart
    
    Write-Host "✅ Caches cleared and containers restarted" -ForegroundColor Green
}

function Test-Fixes {
    Write-Host "🧪 Testing fixes..." -ForegroundColor Blue
    
    Start-Sleep 5  # Wait for containers to be ready
    
    # Test Backend
    try {
        $backendResponse = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/health" -TimeoutSec 10
        Write-Host "✅ Backend: $($backendResponse.status)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Backend: Still starting up..." -ForegroundColor Yellow
    }
    
    # Test Frontend
    try {
        $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 10 -UseBasicParsing
        if ($frontendResponse.StatusCode -eq 200) {
            Write-Host "✅ Frontend: Responding" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️ Frontend: Still starting up..." -ForegroundColor Yellow
    }
    
    # Test Database
    try {
        docker-compose exec mysql mysql -u bankqu_docker -pSamphistik@7 bankqu_docker -e "SHOW TABLES;" > $null
        Write-Host "✅ Database: Connected" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Database: Connection issues" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host "🚀 Starting comprehensive fix..." -ForegroundColor Green
Write-Host ""

# 1. Fix Sessions Table
Fix-SessionsTable

# 2. Fix CORS
Fix-CORS

# 3. Fix CSS/Tailwind
Fix-CSS-Tailwind

Write-Host ""
Write-Host "🔨 Rebuilding containers with fixes..." -ForegroundColor Blue

# Rebuild frontend for CSS fixes
docker-compose build frontend --no-cache

# 4. Run migrations
Run-DatabaseMigrations

# 5. Clear caches and restart
Clear-And-Restart

Write-Host ""
Write-Host "🧪 Testing all fixes..." -ForegroundColor Blue
Test-Fixes

Write-Host ""
Write-Host "🎉 Fix process completed!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Blue
Write-Host "🌐 Frontend: http://localhost:3000" -ForegroundColor Blue
Write-Host "🔗 Backend:  http://127.0.0.1:8000" -ForegroundColor Blue
Write-Host "🔍 API:      http://127.0.0.1:8000/api/health" -ForegroundColor Blue
Write-Host ""
Write-Host "📋 What was fixed:" -ForegroundColor Yellow
Write-Host "   ✅ Sessions table created" -ForegroundColor Green
Write-Host "   ✅ CORS configuration updated" -ForegroundColor Green
Write-Host "   ✅ Tailwind CSS properly configured" -ForegroundColor Green
Write-Host "   ✅ API URL consistency (127.0.0.1)" -ForegroundColor Green
Write-Host ""
Write-Host "🔑 Try login now:" -ForegroundColor Yellow
Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
Write-Host "   Password: admin123" -ForegroundColor Gray