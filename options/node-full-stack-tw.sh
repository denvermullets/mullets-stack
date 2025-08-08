#!/bin/bash

# Get the directory containing this script
script_dir=$(dirname "$0")

# take the first argument as the folder name
project_name=$1

echo "==========================================="
echo "🚀 STARTING FULLSTACK TAILWIND PROJECT SETUP"
echo "==========================================="
echo "📁 Project Name: $project_name"
echo

# create the folder for everything
echo "📂 Creating project directory..."
mkdir "$project_name"
cd "$project_name"
echo "✅ Moved to: $(pwd)"
project_root=$(pwd)

echo "🔧 Initializing git repository..."
git init
echo "✅ Git initialized"

echo
echo "🎨 Setting up Prettier configuration..."
touch .prettierrc
cat > .prettierrc << EOL
{
  "trailingComma": "es5",
  "tabWidth": 2,
  "semi": true,
  "singleQuote": false,
  "printWidth": 100
}
EOL
echo "✅ Prettier configured"

echo
echo "⚛️  Creating React frontend with Vite..."
npx create-vite@latest client --template react-ts
echo "✅ Frontend created"

echo
echo "📦 Installing root dependencies..."
echo "  - concurrently (for running client & server)"
echo "  - husky (for git hooks)"
yarn add concurrently
yarn add -D husky
npx husky init
echo "yarn test" > .husky/pre-commit
echo "✅ Root dependencies installed"

echo "📝 Configuring package.json scripts..."
jq '.scripts = {
    "dev": "concurrently \"cd ./server && yarn start\" \"cd ./client && yarn dev\"",
    "tscheck:client": "tsc -p ./client/tsconfig.json",
    "tscheck:server": "tsc -p ./server/tsconfig.json",
    "test": "yarn tscheck:client && yarn tscheck:server"
}' package.json > package.json.tmp && mv package.json.tmp package.json
echo "✅ Scripts configured"

echo "📋 Adding root .gitignore..."
source "$MAIN_SCRIPT_DIR/options/gitignore.sh"
echo "✅ Root .gitignore added"

echo
echo "==========================================="
echo "🖥️  SETTING UP EXPRESS SERVER"
echo "==========================================="
mkdir server
cd server
echo "📍 Moved to: $(pwd)"

source "$MAIN_SCRIPT_DIR/options/node-api.sh"
echo "✅ Express server setup complete"

echo
echo "==========================================="
echo "⚛️  SETTING UP REACT CLIENT WITH TAILWIND"
echo "==========================================="
cd "$project_root/client"
# cd ../../client
echo "📍 Back to project root: $(pwd)"
# cd client
echo "📍 Moved to client: $(pwd)"

echo "📋 Adding client .gitignore..."
source "$MAIN_SCRIPT_DIR/options/gitignore.sh"
echo "✅ Client .gitignore added"

echo
echo "🎨 Installing Tailwind CSS v4..."
echo "  - tailwindcss (core library)"
echo "  - @tailwindcss/vite (vite plugin)"
yarn add tailwindcss @tailwindcss/vite
echo "✅ Tailwind CSS v4 installed"

echo "📝 Configuring Tailwind CSS v4..."
echo "  - Updating src/index.css with @import directive"
cat > "$project_root/client/src/index.css" << EOL
@import "tailwindcss";
EOL
echo "✅ Tailwind CSS configured"


echo "⚙️  Updating Vite configuration..."
echo "  - Adding Tailwind CSS Vite plugin"
echo "  - Configuring API proxy"
cat > "$project_root/client/vite.config.ts" << EOL
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  server: {
    proxy: {
      "/api/v1": "http://localhost:3000/",
    },
  },
  plugins: [react(), tailwindcss()]
})
EOL
echo "✅ Vite configuration updated"

echo
echo "📦 Installing client dependencies..."
yarn install
echo "✅ Client dependencies installed"

echo
echo "==========================================="
echo "🎉 SETUP COMPLETE!"
echo "==========================================="
echo "📁 Project: $project_name"
echo "🖥️  Server: Express + TypeScript + Knex + PostgreSQL"
echo "⚛️  Client: React + TypeScript + Vite + Tailwind CSS v4"
echo
echo "🚀 To start development:"
echo "   cd $project_name"
echo "   yarn dev"
echo "==========================================="