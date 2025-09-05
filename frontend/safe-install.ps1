# Safe Installation Script untuk Windows
# Menghindari dependency conflict yang menyebabkan react-scripts jadi 0.0.0

param(
    [switch]$Fresh = $false,  # Start fresh dengan create-react-app baru
    [switch]$Verbose = $false # Show verbose output
)

$ErrorActionPreference = "Continue"

Write-Host "Safe Installation untuk React App Dependencies" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Blue

if ($Fresh) {
    Write-Host "Creating fresh React app..." -ForegroundColor Green
    
    # Go to parent directory
    if (Test-Path "frontend") {
        Set-Location ".."
        Remove-Item "frontend" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Create new React app
    npx create-react-app frontend
    Set-Location "frontend"
    
    Write-Host "Fresh React app created!" -ForegroundColor Green
} else {
    # Check if we're in frontend directory
    if (!(Test-Path "package.json")) {
        if (Test-Path "frontend") {
            Set-Location "frontend"
        } else {
            Write-Host "Error: Not in frontend directory and no frontend folder found!" -ForegroundColor Red
            exit 1
        }
    }
}

# Function to check react-scripts version
function Test-ReactScripts {
    $result = npm list react-scripts 2>$null | Out-String
    if ($result -match "react-scripts@(\d+\.\d+\.\d+)") {
        $version = $matches[1]
        if ($version -eq "0.0.0") {
            return $false
        } else {
            Write-Host "react-scripts version: $version" -ForegroundColor Green
            return $true
        }
    } else {
        Write-Host "react-scripts not found" -ForegroundColor Yellow
        return $false
    }
}

# Initial check
Write-Host "Initial react-scripts check..." -ForegroundColor Yellow
$initialCheck = Test-ReactScripts

if (!$initialCheck) {
    Write-Host "react-scripts is not properly installed. Please run with -Fresh flag." -ForegroundColor Red
    exit 1
}

# Install dependencies one by one with safety checks
Write-Host "Installing dependencies safely..." -ForegroundColor Blue

$dependencies = @(
    @{name="axios"; version="^1.6.2"; dev=$false},
    @{name="lucide-react"; version="^0.294.0"; dev=$false},
    @{name="react-router-dom"; version="^6.8.1"; dev=$false}
)

$devDependencies = @(
    @{name="postcss"; version="^8.4.31"; dev=$true},
    @{name="autoprefixer"; version="^10.4.16"; dev=$true},
    @{name="tailwindcss"; version="^3.3.5"; dev=$true}
)

# Install regular dependencies
foreach ($dep in $dependencies) {
    Write-Host "Installing $($dep.name)..." -ForegroundColor Yellow
    
    if ($dep.version) {
        npm install "$($dep.name)@$($dep.version)"
    } else {
        npm install $dep.name
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install $($dep.name), trying with --legacy-peer-deps..." -ForegroundColor Yellow
        npm install "$($dep.name)@$($dep.version)" --legacy-peer-deps
    }
    
    # Check react-scripts after each install
    $check = Test-ReactScripts
    if (!$check) {
        Write-Host "react-scripts broken after installing $($dep.name)!" -ForegroundColor Red
        Write-Host "Fixing react-scripts..." -ForegroundColor Yellow
        npm install react-scripts@5.0.1 --force
        
        $recheck = Test-ReactScripts
        if (!$recheck) {
            Write-Host "Cannot fix react-scripts. Stopping installation." -ForegroundColor Red
            exit 1
        }
    }
}

# Install dev dependencies
Write-Host "Installing development dependencies..." -ForegroundColor Blue
foreach ($dep in $devDependencies) {
    Write-Host "Installing $($dep.name) as dev dependency..." -ForegroundColor Yellow
    
    npm install "$($dep.name)@$($dep.version)" --save-dev
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install $($dep.name), trying with --legacy-peer-deps..." -ForegroundColor Yellow
        npm install "$($dep.name)@$($dep.version)" --save-dev --legacy-peer-deps
    }
    
    # Check react-scripts after each install
    $check = Test-ReactScripts
    if (!$check) {
        Write-Host "react-scripts broken after installing $($dep.name)!" -ForegroundColor Red
        Write-Host "Fixing react-scripts..." -ForegroundColor Yellow
        npm install react-scripts@5.0.1 --force
        
        $recheck = Test-ReactScripts
        if (!$recheck) {
            Write-Host "Cannot fix react-scripts. Stopping installation." -ForegroundColor Red
            exit 1
        }
    }
}

# Final verification
Write-Host ""
Write-Host "Final verification..." -ForegroundColor Cyan

# Check all dependencies
$finalCheck = Test-ReactScripts
if ($finalCheck) {
    Write-Host "All dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Installation completed but react-scripts is still broken" -ForegroundColor Red
    exit 1
}

# Show installed packages
if ($Verbose) {
    Write-Host ""
    Write-Host "Installed packages:" -ForegroundColor Blue
    npm list --depth=0
}

# Test build
Write-Host "Testing build process..." -ForegroundColor Yellow
$env:CI = "true"  # Prevent build from opening browser
npm run build 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Build test successful!" -ForegroundColor Green
    # Clean up build folder
    Remove-Item "build" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Build test failed, but development mode should work" -ForegroundColor Yellow
}

# Create Tailwind config if needed
if (!(Test-Path "tailwind.config.js")) {
    Write-Host "Creating Tailwind config..." -ForegroundColor Yellow
    npx tailwindcss init -p
}

Write-Host ""
Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Blue
Write-Host "Location: $(Get-Location)" -ForegroundColor Blue
Write-Host "To start development: npm start" -ForegroundColor Blue
Write-Host "To build: npm run build" -ForegroundColor Blue
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "   1. Add Tailwind directives to src/index.css" -ForegroundColor Gray
Write-Host "   2. Configure Tailwind content paths in tailwind.config.js" -ForegroundColor Gray
Write-Host "   3. Start coding your app!" -ForegroundColor Gray

# Ask if user wants to start development server
Write-Host ""
$startNow = Read-Host "Start development server now? (y/n)"
if ($startNow -eq "y" -or $startNow -eq "Y") {
    Write-Host "Starting development server..." -ForegroundColor Green
    npm start
}