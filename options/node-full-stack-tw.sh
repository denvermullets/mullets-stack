#!/bin/bash

# Get the directory containing this script
script_dir=$(dirname "$0")

# take the first argument as the folder name
project_name=$1

# create the folder for everything
mkdir "$project_name"
cd "$project_name"
git init


# create the frontend
yarn create vite client --template react-ts

# main folder needs to add concurrently
yarn add concurrently
yarn add -D husky
yarn husky install
npm pkg set scripts.prepare="husky install"
yarn husky add .husky/pre-commit "yarn test"

jq '.scripts = {
    "dev": "concurrently \"cd ./server && yarn start\" \"cd ./client && yarn dev\"",
    "tscheck:client": "tsc -p ./client/tsconfig.json",
    "tscheck:server": "tsc -p ./server/tsconfig.json",
    "test": "yarn tscheck:client && yarn tscheck:server"
}' package.json > package.json.tmp && mv package.json.tmp package.json

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"

# create the server
mkdir server
cd server

# create the Express Server
source "$MAIN_SCRIPT_DIR/options/node-api.sh"

cd ..
cd ..
cd ..

# react client stuff
cd client

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"

# install tailwind if argument provided
# if [ $# -eq 2 ]; then
#   second_arg=$2
#   echo "Second argument provided: $second_arg"
#   if [ "$second_arg" == "chakra" ]; then
yarn add tailwindcss postcss autoprefixer -D
npx tailwindcss init -p

cd src
#     cat > main.tsx << EOL
# import React from 'react'
# import ReactDOM from 'react-dom/client'
# import App from './App'
# import './index.css'
# import { ChakraProvider } from '@chakra-ui/react'

# ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
#   <React.StrictMode>
#     <ChakraProvider>
#       <App />
#     </ChakraProvider>
#   </React.StrictMode>,
# )
# EOL

cd ..
#   fi
# fi

# create vite.config.js in the client folder
cat > vite.config.js << EOL
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  server: {
    proxy: {
      "/api/v1": "http://localhost:3000/",
    },
  },
  plugins: [react()]
})
EOL

yarn install