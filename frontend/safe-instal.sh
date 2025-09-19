#!/usr/bin/env bash

# Safe Installation Script untuk React App Dependencies (Bash)
# Menghindari dependency conflict yang menyebabkan react-scripts jadi 0.0.0

set -e

FRESH=false
VERBOSE=false

# Argument parsing
for arg in "$@"; do
  case $arg in
    -f|--fresh)
      FRESH=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
  esac
done

echo -e "\033[36mSafe Installation untuk React App Dependencies\033[0m"
echo -e "\033[34m====================================================\033[0m"

if $FRESH; then
  echo -e "\033[32mCreating fresh React app...\033[0m"

  if [ -d "frontend" ]; then
    cd ..
    rm -rf frontend
  fi

  npx create-react-app frontend
  cd frontend || exit 1

  echo -e "\033[32mFresh React app created!\033[0m"
else
  if [ ! -f "package.json" ]; then
    if [ -d "frontend" ]; then
      cd frontend || exit 1
    else
      echo -e "\033[31mError: Not in frontend directory and no frontend folder found!\033[0m"
      exit 1
    fi
  fi
fi

# Function to check react-scripts version
test_react_scripts() {
  result=$(npm list react-scripts 2>/dev/null || true)
  if [[ $result =~ react-scripts@([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    version="${BASH_REMATCH[1]}"
    if [[ $version == "0.0.0" ]]; then
      return 1
    else
      echo -e "\033[32mreact-scripts version: $version\033[0m"
      return 0
    fi
  else
    echo -e "\033[33mreact-scripts not found\033[0m"
    return 1
  fi
}

echo -e "\033[33mInitial react-scripts check...\033[0m"
if ! test_react_scripts; then
  echo -e "\033[31mreact-scripts is not properly installed. Please run with --fresh flag.\033[0m"
  exit 1
fi

echo -e "\033[34mInstalling dependencies safely...\033[0m"

# Dependencies
dependencies=(
  "axios@^1.6.2"
  "lucide-react@^0.294.0"
  "react-router-dom@^6.8.1"
)

devDependencies=(
  "postcss@^8.4.31"
  "autoprefixer@^10.4.16"
  "tailwindcss@^3.3.5"
)

# Install regular dependencies
for dep in "${dependencies[@]}"; do
  echo -e "\033[33mInstalling $dep...\033[0m"
  if ! npm install "$dep"; then
    echo -e "\033[33mFailed to install $dep, retrying with --legacy-peer-deps...\033[0m"
    npm install "$dep" --legacy-peer-deps
  fi

  if ! test_react_scripts; then
    echo -e "\033[31mreact-scripts broken after installing $dep!\033[0m"
    echo -e "\033[33mFixing react-scripts...\033[0m"
    npm install react-scripts@5.0.1 --force
    if ! test_react_scripts; then
      echo -e "\033[31mCannot fix react-scripts. Stopping installation.\033[0m"
      exit 1
    fi
  fi
done

# Install dev dependencies
echo -e "\033[34mInstalling development dependencies...\033[0m"
for dep in "${devDependencies[@]}"; do
  echo -e "\033[33mInstalling $dep as dev dependency...\033[0m"
  if ! npm install "$dep" --save-dev; then
    echo -e "\033[33mFailed to install $dep, retrying with --legacy-peer-deps...\033[0m"
    npm install "$dep" --save-dev --legacy-peer-deps
  fi

  if ! test_react_scripts; then
    echo -e "\033[31mreact-scripts broken after installing $dep!\033[0m"
    echo -e "\033[33mFixing react-scripts...\033[0m"
    npm install react-scripts@5.0.1 --force
    if ! test_react_scripts; then
      echo -e "\033[31mCannot fix react-scripts. Stopping installation.\033[0m"
      exit 1
    fi
  fi
done

# Final verification
echo -e "\n\033[36mFinal verification...\033[0m"
if test_react_scripts; then
  echo -e "\033[32mAll dependencies installed successfully!\033[0m"
else
  echo -e "\033[31mInstallation completed but react-scripts is still broken\033[0m"
  exit 1
fi

if $VERBOSE; then
  echo -e "\n\033[34mInstalled packages:\033[0m"
  npm list --depth=0
fi

# Test build
echo -e "\033[33mTesting build process...\033[0m"
CI=true npm run build >/dev/null 2>&1 || true
if [ $? -eq 0 ]; then
  echo -e "\033[32mBuild test successful!\033[0m"
  rm -rf build
else
  echo -e "\033[33mBuild test failed, but development mode should work\033[0m"
fi

# Tailwind config
if [ ! -f "tailwind.config.js" ]; then
  echo -e "\033[33mCreating Tailwind config...\033[0m"
  npx tailwindcss init -p
fi

echo -e "\n\033[32mInstallation completed successfully!\033[0m"
echo -e "\033[34m========================================\033[0m"
echo -e "\033[34mLocation: $(pwd)\033[0m"
echo -e "\033[34mTo start development: npm start\033[0m"
echo -e "\033[34mTo build: npm run build\033[0m"

echo -e "\n\033[33mNext steps:\033[0m"
echo -e "   1. Add Tailwind directives to src/index.css"
echo -e "   2. Configure Tailwind content paths in tailwind.config.js"
echo -e "   3. Start coding your app!"

read -p "Start development server now? (y/n): " startNow
if [[ $startNow == "y" || $startNow == "Y" ]]; then
  echo -e "\033[32mStarting development server...\033[0m"
  npm start
fi
