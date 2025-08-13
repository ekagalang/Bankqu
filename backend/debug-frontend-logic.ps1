# Debug Frontend Login Logic
Write-Host "🔍 Debugging Frontend Login Logic..." -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Blue

function Test-Browser-Fetch {
    Write-Host "🌐 Testing browser fetch capability..." -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "📋 Manual Browser Test:" -ForegroundColor Blue
    Write-Host "1. Open http://localhost:3000" -ForegroundColor Gray
    Write-Host "2. Press F12 to open Developer Tools" -ForegroundColor Gray
    Write-Host "3. Go to Console tab" -ForegroundColor Gray
    Write-Host "4. Paste and run this code:" -ForegroundColor Gray
    Write-Host ""
    
    $testCode = @'
// Test fetch from browser console
fetch('http://localhost:8000/api/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  body: JSON.stringify({
    email: 'admin@bankqu.com',
    password: 'admin123'
  })
})
.then(response => {
  console.log('Response Status:', response.status);
  console.log('Response Headers:', response.headers);
  return response.text();
})
.then(text => {
  console.log('Raw Response:', text);
  try {
    const json = JSON.parse(text);
    console.log('Parsed JSON:', json);
    if (json.success && json.data && json.data.access_token) {
      console.log('✅ Login response format is CORRECT');
      console.log('User:', json.data.user);
      console.log('Token:', json.data.access_token);
    } else {
      console.log('❌ Login response format is WRONG');
    }
  } catch (e) {
    console.log('❌ JSON parsing failed:', e);
  }
})
.catch(error => {
  console.log('❌ Fetch failed:', error);
});
'@
    
    Write-Host $testCode -ForegroundColor Green
    Write-Host ""
    Write-Host "Expected result: Should log '✅ Login response format is CORRECT'" -ForegroundColor Yellow
}

function Check-AuthContext-Logic {
    Write-Host "👤 Checking AuthContext login logic..." -ForegroundColor Yellow
    
    $authContextPath = "frontend/src/contexts/AuthContext.js"
    if (Test-Path $authContextPath) {
        $content = Get-Content $authContextPath -Raw
        
        Write-Host "   Checking response handling logic..." -ForegroundColor Gray
        
        # Check if the logic expects the right structure
        if ($content -match "if \(response\.ok && data\.success\)") {
            Write-Host "✅ Response check logic looks correct" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Response check logic might be different" -ForegroundColor Yellow
        }
        
        if ($content -match "const \{ user, access_token \} = data\.data;") {
            Write-Host "✅ Destructuring logic expects correct format" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Destructuring logic might be different" -ForegroundColor Yellow
        }
        
        # Check error handling
        if ($content -match "catch \(error\)") {
            Write-Host "✅ Error handling present" -ForegroundColor Green
        } else {
            Write-Host "⚠️ No error handling found" -ForegroundColor Yellow
        }
        
        # Show relevant parts of the login function
        if ($content -match "const login = async \(email, password\) => \{([^}]+)\}") {
            Write-Host ""
            Write-Host "📋 Current login function logic:" -ForegroundColor Blue
            Write-Host "Found login function - checking for potential issues..." -ForegroundColor Gray
        }
    }
}

function Create-Debug-AuthContext {
    Write-Host "🔧 Creating debug version of AuthContext..." -ForegroundColor Yellow
    
    $debugAuthContext = @'
import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [token, setToken] = useState(localStorage.getItem('token'));

  const API_BASE_URL = 'http://localhost:8000/api';

  useEffect(() => {
    if (token) {
      // Could set axios defaults here if using axios
    }
  }, [token]);

  useEffect(() => {
    const checkAuth = async () => {
      const savedToken = localStorage.getItem('token');
      const savedUser = localStorage.getItem('user');
      
      if (savedToken && savedUser) {
        try {
          setToken(savedToken);
          setUser(JSON.parse(savedUser));
        } catch (error) {
          console.error('Auth check error:', error);
          localStorage.removeItem('user');
          localStorage.removeItem('token');
        }
      }
      setLoading(false);
    };

    checkAuth();
  }, []);

  const login = async (email, password) => {
    console.log('🔐 Login attempt started...');
    console.log('Email:', email);
    console.log('API URL:', API_BASE_URL);
    
    try {
      const requestData = { email, password };
      console.log('📤 Request data:', requestData);
      
      const response = await fetch(`${API_BASE_URL}/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: JSON.stringify(requestData),
      });

      console.log('📥 Response status:', response.status);
      console.log('📥 Response ok:', response.ok);

      // Get response text first to debug
      const responseText = await response.text();
      console.log('📥 Raw response:', responseText);

      // Try to parse JSON
      let data;
      try {
        data = JSON.parse(responseText);
        console.log('📥 Parsed JSON:', data);
      } catch (parseError) {
        console.error('❌ JSON parse error:', parseError);
        return { 
          success: false, 
          message: 'Invalid response format from server' 
        };
      }

      if (response.ok && data.success) {
        console.log('✅ Login response successful');
        
        // Check if data structure is correct
        if (data.data && data.data.user && data.data.access_token) {
          console.log('✅ Response structure is correct');
          
          const { user, access_token } = data.data;
          
          console.log('👤 User data:', user);
          console.log('🔑 Access token:', access_token.substring(0, 20) + '...');
          
          setUser(user);
          setToken(access_token);
          
          localStorage.setItem('user', JSON.stringify(user));
          localStorage.setItem('token', access_token);
          
          console.log('✅ Login successful - user and token saved');
          return { success: true };
        } else {
          console.error('❌ Response structure is wrong:', data);
          return { 
            success: false, 
            message: 'Invalid response structure' 
          };
        }
      } else {
        console.error('❌ Login failed:', data);
        return { 
          success: false, 
          message: data.message || 'Login failed' 
        };
      }
    } catch (error) {
      console.error('❌ Login error:', error);
      return { 
        success: false, 
        message: 'Network error. Please check if backend is running.' 
      };
    }
  };

  const register = async (name, email, password, password_confirmation) => {
    // Keep existing register logic...
    try {
      const response = await fetch(`${API_BASE_URL}/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ 
          name, 
          email, 
          password, 
          password_confirmation 
        }),
      });

      const data = await response.json();

      if (response.ok && data.success) {
        const { user, access_token } = data.data;
        
        setUser(user);
        setToken(access_token);
        
        localStorage.setItem('user', JSON.stringify(user));
        localStorage.setItem('token', access_token);
        
        return { success: true };
      } else {
        return { 
          success: false, 
          message: data.message || 'Registration failed',
          errors: data.data || {}
        };
      }
    } catch (error) {
      return { 
        success: false, 
        message: 'Network error. Please check if backend is running.' 
      };
    }
  };

  const logout = async () => {
    try {
      if (token) {
        await fetch(`${API_BASE_URL}/logout`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
        });
      }
    } catch (error) {
      // Silently handle logout errors
    } finally {
      setUser(null);
      setToken(null);
      localStorage.removeItem('user');
      localStorage.removeItem('token');
    }
  };

  const value = {
    user,
    token,
    login,
    register,
    logout,
    loading,
    isAuthenticated: !!user
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
'@
    
    # Create backup first
    $authContextPath = "frontend/src/contexts/AuthContext.js"
    if (Test-Path $authContextPath) {
        Copy-Item $authContextPath "$authContextPath.backup" -Force
        Write-Host "✅ Created backup of original AuthContext.js" -ForegroundColor Green
    }
    
    # Write debug version
    $debugAuthContext | Set-Content $authContextPath -Encoding UTF8
    Write-Host "✅ Created debug version of AuthContext.js" -ForegroundColor Green
    Write-Host "   Added extensive console logging for debugging" -ForegroundColor Gray
}

function Show-Debug-Instructions {
    Write-Host ""
    Write-Host "🔍 Debug Instructions:" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Updated AuthContext.js with debug logging" -ForegroundColor Yellow
    Write-Host "2. Restart frontend to pick up changes:" -ForegroundColor Yellow
    Write-Host "   docker-compose restart frontend" -ForegroundColor Blue
    Write-Host ""
    Write-Host "3. Open http://localhost:3000" -ForegroundColor Yellow
    Write-Host "4. Open browser console (F12)" -ForegroundColor Yellow
    Write-Host "5. Try to login and watch console messages" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Expected console output:" -ForegroundColor Yellow
    Write-Host "   🔐 Login attempt started..." -ForegroundColor Gray
    Write-Host "   📤 Request data: {email: ..., password: ...}" -ForegroundColor Gray
    Write-Host "   📥 Response status: 200" -ForegroundColor Gray
    Write-Host "   📥 Raw response: {success: true, ...}" -ForegroundColor Gray
    Write-Host "   ✅ Login successful - user and token saved" -ForegroundColor Gray
    Write-Host ""
    Write-Host "If you see errors, share the console output!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To restore original:" -ForegroundColor Yellow
    Write-Host "   Copy frontend/src/contexts/AuthContext.js.backup back" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 Starting frontend login debug..." -ForegroundColor Green
Write-Host ""

Write-Host "✅ Backend is working (Postman successful)" -ForegroundColor Green
Write-Host "❌ Frontend login not working" -ForegroundColor Red
Write-Host "🎯 Focus: Debug frontend login logic" -ForegroundColor Yellow
Write-Host ""

# 1. Test browser fetch capability
Test-Browser-Fetch

Write-Host ""
$browserTestDone = Read-Host "Run browser console test first? (y/n)"

if ($browserTestDone -eq "y" -or $browserTestDone -eq "Y") {
    Write-Host ""
    Write-Host "⏳ Waiting for you to run browser console test..." -ForegroundColor Blue
    Write-Host "Press any key when done with browser test" -ForegroundColor Gray
    Read-Host
}

# 2. Check current AuthContext logic
Check-AuthContext-Logic

Write-Host ""
$createDebug = Read-Host "Create debug version of AuthContext? (y/n)"

if ($createDebug -eq "y" -or $createDebug -eq "Y") {
    # 3. Create debug AuthContext
    Create-Debug-AuthContext
    
    # 4. Show instructions
    Show-Debug-Instructions
} else {
    Write-Host ""
    Write-Host "💡 Manual debugging tips:" -ForegroundColor Yellow
    Write-Host "1. Check browser console for JavaScript errors" -ForegroundColor Gray
    Write-Host "2. Check Network tab for actual request/response" -ForegroundColor Gray
    Write-Host "3. Add console.log statements to AuthContext login function" -ForegroundColor Gray
    Write-Host "4. Verify frontend is using correct API URL" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔍 Frontend debug setup completed!" -ForegroundColor Green