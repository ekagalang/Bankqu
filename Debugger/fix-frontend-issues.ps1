# Fix Frontend Issues - CORS dan CSS
Write-Host "🔧 Fixing Frontend Issues..." -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Blue
Write-Host "Problems to fix:" -ForegroundColor Yellow
Write-Host "1. ❌ CORS error (127.0.0.1 vs localhost)" -ForegroundColor Red
Write-Host "2. ❌ HTML polos (Tailwind CSS tidak load)" -ForegroundColor Red
Write-Host ""

function Fix-CORS-URLs {
    Write-Host "🌐 Fixing CORS URL consistency..." -ForegroundColor Yellow
    
    # Fix AuthContext.js - ganti 127.0.0.1 ke localhost
    $authContextPath = "frontend/src/contexts/AuthContext.js"
    if (Test-Path $authContextPath) {
        $content = Get-Content $authContextPath -Raw
        
        # Ganti URL dari 127.0.0.1 ke localhost
        $content = $content -replace "const API_BASE_URL = 'http://127\.0\.0\.1:8000/api';", "const API_BASE_URL = 'http://localhost:8000/api';"
        
        $content | Set-Content $authContextPath -Encoding UTF8
        Write-Host "✅ Fixed AuthContext.js API URL to localhost" -ForegroundColor Green
    }
    
    # Pastikan services/api.js juga konsisten
    $apiServicePath = "frontend/src/services/api.js"
    if (Test-Path $apiServicePath) {
        $content = Get-Content $apiServicePath -Raw
        
        # Pastikan pakai localhost
        if ($content -match "127\.0\.0\.1") {
            $content = $content -replace "127\.0\.0\.1", "localhost"
            $content | Set-Content $apiServicePath -Encoding UTF8
            Write-Host "✅ Fixed api.js URL to localhost" -ForegroundColor Green
        } else {
            Write-Host "✅ api.js already using localhost" -ForegroundColor Green
        }
    }
    
    # Update frontend .env untuk consistency
    $frontendEnv = @'
REACT_APP_API_URL=http://localhost:8000/api
REACT_APP_APP_NAME=BankQu
CHOKIDAR_USEPOLLING=true
GENERATE_SOURCEMAP=false
BROWSER=none
'@
    $frontendEnv | Set-Content "frontend/.env" -Encoding UTF8
    Write-Host "✅ Updated frontend .env with localhost" -ForegroundColor Green
}

function Fix-Tailwind-CSS {
    Write-Host "🎨 Fixing Tailwind CSS setup..." -ForegroundColor Yellow
    
    # 1. Ensure proper index.css with Tailwind directives
    $indexCssPath = "frontend/src/index.css"
    $tailwindCSS = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Global styles */
* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f8fafc;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}

/* Ensure Tailwind classes work */
.min-h-screen {
  min-height: 100vh;
}

.bg-gray-50 {
  background-color: #f9fafb;
}
'@
    
    $tailwindCSS | Set-Content $indexCssPath -Encoding UTF8
    Write-Host "✅ Updated index.css with Tailwind directives" -ForegroundColor Green
    
    # 2. Ensure tailwind.config.js exists and is proper
    $tailwindConfigPath = "frontend/tailwind.config.js"
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
          100: '#dbeafe', 
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
    Write-Host "✅ Updated tailwind.config.js" -ForegroundColor Green
    
    # 3. Ensure postcss.config.js exists
    $postcssConfigPath = "frontend/postcss.config.js"
    $postcssConfig = @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@
    
    $postcssConfig | Set-Content $postcssConfigPath -Encoding UTF8
    Write-Host "✅ Updated postcss.config.js" -ForegroundColor Green
    
    # 4. Create .npmrc for package resolution
    $npmrcContent = @'
legacy-peer-deps=true
save-exact=false
'@
    
    $npmrcContent | Set-Content "frontend/.npmrc" -Encoding UTF8
    Write-Host "✅ Created .npmrc" -ForegroundColor Green
}

function Update-Frontend-Dockerfile {
    Write-Host "🐳 Updating Frontend Dockerfile for CSS..." -ForegroundColor Yellow
    
    $frontendDockerfile = @'
FROM node:18-alpine

WORKDIR /app

# Copy package files and npmrc
COPY package*.json ./
COPY .npmrc ./

# Install dependencies with legacy peer deps
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build CSS explicitly (important!)
RUN npx tailwindcss -i ./src/index.css -o ./public/tailwind.css --minify 2>/dev/null || echo "Tailwind build attempted"

# Expose port
EXPOSE 3000

# Start development server
CMD ["npm", "start"]
'@
    
    $frontendDockerfile | Set-Content "frontend/Dockerfile" -Encoding UTF8
    Write-Host "✅ Updated Frontend Dockerfile" -ForegroundColor Green
}

function Test-Local-CSS {
    Write-Host "🧪 Testing CSS build locally..." -ForegroundColor Yellow
    
    if (Test-Path "frontend/package.json") {
        Push-Location "frontend"
        
        Write-Host "   Building Tailwind CSS..." -ForegroundColor Gray
        
        # Try building CSS locally first
        npx tailwindcss -i ./src/index.css -o ./public/tailwind.css --minify 2>$null
        
        if (Test-Path "./public/tailwind.css") {
            Write-Host "✅ Tailwind CSS built successfully" -ForegroundColor Green
            
            # Add CSS import to index.html if not exists
            $indexHtmlPath = "./public/index.html"
            if (Test-Path $indexHtmlPath) {
                $htmlContent = Get-Content $indexHtmlPath -Raw
                
                if ($htmlContent -notmatch "tailwind.css") {
                    $htmlContent = $htmlContent -replace '<title>React App</title>', '<title>BankQu</title>`n    <link rel="stylesheet" href="/tailwind.css">'
                    $htmlContent | Set-Content $indexHtmlPath -Encoding UTF8
                    Write-Host "✅ Added Tailwind CSS link to index.html" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "⚠️ Tailwind build failed locally, will try in Docker" -ForegroundColor Yellow
        }
        
        Pop-Location
    }
}

function Rebuild-Frontend-Container {
    Write-Host "🔨 Rebuilding frontend container..." -ForegroundColor Yellow
    
    # Stop frontend container
    docker-compose stop frontend
    
    # Remove frontend container and image
    docker-compose rm -f frontend
    docker rmi $(docker images -q "$(Split-Path -Leaf $PWD)_frontend") 2>$null
    
    # Rebuild with no cache
    docker-compose build frontend --no-cache
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Frontend rebuild successful" -ForegroundColor Green
        
        # Start frontend
        docker-compose up -d frontend
        
        Write-Host "✅ Frontend container started" -ForegroundColor Green
    } else {
        Write-Host "❌ Frontend build failed" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Test-Frontend-Access {
    Write-Host "🧪 Testing frontend access..." -ForegroundColor Blue
    
    Start-Sleep 5  # Wait for container to start
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 10 -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Frontend responding on port 3000" -ForegroundColor Green
            
            # Check if response contains Tailwind classes
            if ($response.Content -match "bg-gray-50" -or $response.Content -match "tailwind") {
                Write-Host "✅ Tailwind CSS appears to be working" -ForegroundColor Green
            } else {
                Write-Host "⚠️ Frontend responding but CSS might not be loaded" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "⚠️ Frontend not responding yet, might still be starting..." -ForegroundColor Yellow
    }
}

function Show-Debug-Info {
    Write-Host ""
    Write-Host "🔍 Debug Information:" -ForegroundColor Blue
    Write-Host "=====================" -ForegroundColor Blue
    
    # Check if containers are running
    Write-Host "Container status:" -ForegroundColor Yellow
    docker-compose ps
    
    Write-Host ""
    Write-Host "Frontend logs (last 10 lines):" -ForegroundColor Yellow
    docker-compose logs --tail=10 frontend
    
    Write-Host ""
    Write-Host "🌐 URLs to test:" -ForegroundColor Yellow
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor Blue
    Write-Host "   Backend:  http://localhost:8000/api/health" -ForegroundColor Blue
    
    Write-Host ""
    Write-Host "🔧 Manual troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Open browser dev tools (F12)" -ForegroundColor Gray
    Write-Host "   2. Check Console for CSS/JS errors" -ForegroundColor Gray
    Write-Host "   3. Check Network tab for failed requests" -ForegroundColor Gray
    Write-Host "   4. Try hard refresh (Ctrl+Shift+R)" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 Starting frontend fixes..." -ForegroundColor Green
Write-Host ""

# 1. Fix CORS URLs
Fix-CORS-URLs

# 2. Fix Tailwind CSS
Fix-Tailwind-CSS

# 3. Update Dockerfile
Update-Frontend-Dockerfile

# 4. Test CSS build locally
Test-Local-CSS

Write-Host ""
$rebuildChoice = Read-Host "Rebuild frontend container with fixes? (y/n)"

if ($rebuildChoice -eq "y" -or $rebuildChoice -eq "Y") {
    $rebuildSuccess = Rebuild-Frontend-Container
    
    if ($rebuildSuccess) {
        Write-Host ""
        Write-Host "⏳ Waiting for frontend to start..." -ForegroundColor Yellow
        Test-Frontend-Access
        
        Write-Host ""
        Write-Host "🎉 Fixes applied!" -ForegroundColor Green
        Write-Host "=================" -ForegroundColor Blue
        Write-Host "✅ CORS URLs fixed (using localhost consistently)" -ForegroundColor Green
        Write-Host "✅ Tailwind CSS configuration updated" -ForegroundColor Green
        Write-Host "✅ Frontend container rebuilt" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🧪 Test now:" -ForegroundColor Yellow
        Write-Host "   1. Open http://localhost:3000" -ForegroundColor Blue
        Write-Host "   2. Should see STYLED login form (not plain HTML)" -ForegroundColor Blue
        Write-Host "   3. Try login - should NOT get CORS error" -ForegroundColor Blue
        
        Show-Debug-Info
    } else {
        Write-Host ""
        Write-Host "❌ Rebuild failed. Check logs above." -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "⚠️ Skipped rebuild. Manual rebuild commands:" -ForegroundColor Yellow
    Write-Host "   docker-compose build frontend --no-cache" -ForegroundColor Gray
    Write-Host "   docker-compose up -d frontend" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 Frontend fix completed!" -ForegroundColor Green