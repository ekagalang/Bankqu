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
