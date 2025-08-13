# Quick SQLite Setup for Local Backend
Write-Host "🗄️ Setting up SQLite for Local Backend..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Blue

function Setup-SQLite {
    Write-Host "📝 Updating .env for SQLite..." -ForegroundColor Yellow
    
    $envPath = "backend/.env"
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        
        # Update database configuration
        $envContent = $envContent -replace "DB_CONNECTION=mysql", "DB_CONNECTION=sqlite"
        $envContent = $envContent -replace "DB_HOST=.*", "#DB_HOST=127.0.0.1"
        $envContent = $envContent -replace "DB_PORT=.*", "#DB_PORT=3306"
        $envContent = $envContent -replace "DB_DATABASE=.*", "DB_DATABASE=database/database.sqlite"
        $envContent = $envContent -replace "DB_USERNAME=.*", "#DB_USERNAME=root"
        $envContent = $envContent -replace "DB_PASSWORD=.*", "#DB_PASSWORD="
        
        $envContent | Set-Content $envPath -Encoding UTF8
        Write-Host "✅ Updated .env for SQLite" -ForegroundColor Green
    }
}

function Create-SQLite-Database {
    Write-Host "📄 Creating SQLite database file..." -ForegroundColor Yellow
    
    $dbPath = "backend/database/database.sqlite"
    if (!(Test-Path $dbPath)) {
        New-Item -ItemType File -Path $dbPath -Force | Out-Null
        Write-Host "✅ Created $dbPath" -ForegroundColor Green
    } else {
        Write-Host "✅ SQLite file already exists" -ForegroundColor Green
    }
}

function Run-Migrations {
    Write-Host "🏗️ Running database migrations..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Clear config cache
    php artisan config:clear
    
    # Create sessions table
    php artisan make:session-table --force 2>$null
    
    # Run migrations with seed
    php artisan migrate:fresh --seed --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Migrations completed successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Migrations had issues, trying without seed..." -ForegroundColor Yellow
        php artisan migrate:fresh --force
    }
    
    Pop-Location
}

function Test-Database {
    Write-Host "🧪 Testing database connection..." -ForegroundColor Blue
    
    Push-Location "backend"
    
    # Test connection with artisan tinker
    $testResult = php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'SUCCESS'; } catch(Exception \$e) { echo 'ERROR: ' . \$e->getMessage(); }" 2>&1
    
    if ($testResult -like "*SUCCESS*") {
        Write-Host "✅ Database connection successful!" -ForegroundColor Green
        
        # Test if users table has data
        $userCount = php artisan tinker --execute="echo App\Models\User::count();" 2>&1
        if ($userCount -match "\d+") {
            Write-Host "✅ Found $($userCount.Trim()) users in database" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Database connection failed: $testResult" -ForegroundColor Red
    }
    
    Pop-Location
}

function Create-Default-User {
    Write-Host "👤 Creating default admin user..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    $createUserScript = @'
use App\Models\User;
use Illuminate\Support\Facades\Hash;

// Check if admin user exists
$admin = User::where('email', 'admin@bankqu.com')->first();

if (!$admin) {
    $admin = User::create([
        'name' => 'Admin BankQu',
        'email' => 'admin@bankqu.com',
        'password' => Hash::make('admin123'),
        'email_verified_at' => now(),
    ]);
    echo "Admin user created successfully\n";
} else {
    echo "Admin user already exists\n";
}

echo "Total users: " . User::count() . "\n";
'@
    
    $createUserScript | php artisan tinker 2>$null
    Write-Host "✅ Default user setup completed" -ForegroundColor Green
    
    Pop-Location
}

function Show-Login-Info {
    Write-Host ""
    Write-Host "🎉 SQLite Setup Completed!" -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Blue
    Write-Host "✅ Database: SQLite (local file)" -ForegroundColor Green
    Write-Host "✅ Backend: http://localhost:8000" -ForegroundColor Green
    Write-Host "✅ Frontend: http://localhost:3000" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔑 Login Credentials:" -ForegroundColor Yellow
    Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
    Write-Host "   Password: admin123" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🧪 Test backend API:" -ForegroundColor Yellow
    Write-Host "   http://localhost:8000/api/health" -ForegroundColor Blue
    Write-Host ""
    Write-Host "💡 To restart backend later:" -ForegroundColor Yellow
    Write-Host "   cd backend && php artisan serve" -ForegroundColor Gray
}

# Main execution
if (!(Test-Path "backend")) {
    Write-Host "❌ Backend folder not found!" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Starting SQLite setup..." -ForegroundColor Green
Write-Host ""

# 1. Setup SQLite configuration
Setup-SQLite

# 2. Create database file
Create-SQLite-Database

# 3. Run migrations
Run-Migrations

# 4. Test database
Test-Database

# 5. Create default user
Create-Default-User

# 6. Show completion info
Show-Login-Info

Write-Host ""
Write-Host "🔧 SQLite setup completed!" -ForegroundColor Green
Write-Host "Now try logging in at http://localhost:3000" -ForegroundColor Blue