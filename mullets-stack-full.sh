#!/bin/bash

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

# add the following script to the package.json file
# you will run this to run both sides of the app
jq '.scripts = {
    "dev": "concurrently \"cd ./server && yarn start\" \"cd ./client && yarn dev\"",
    "tscheck:client": "tsc -p ./client/tsconfig.json",
    "tscheck:server": "tsc -p ./server/tsconfig.json",
    "test": "yarn tscheck:client && yarn tscheck:server"
}' package.json > package.json.tmp && mv package.json.tmp package.json

cat > .gitignore <<EOL
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

node_modules
.DS_Store
error_log
*.log
.cache
dist
build
.env
.vscode
.idea
dump.rdb

/cypress/videos
EOL

# create the server
mkdir server
cd server
yarn init -y
yarn add express knex pg dotenv axios
yarn add -D nodemon ts-node typescript @types/express @types/node
yarn tsc --init

# append the script to server package.json
jq '.scripts = {
    "build": "yarn install && tsc",
    "start:prod": "yarn db:migrate && node build/index.js",
    "start": "nodemon ./src/index.ts",
    "knex": "./node_modules/.bin/knex --knexfile src/database/knexfile.ts",
    "db:migrate": "yarn knex migrate:latest src/database/knexfile.ts",
    "db:rollback": "yarn knex migrate:rollback src/database/knexfile.ts"
}' package.json > package.json.tmp && mv package.json.tmp package.json

cat > .gitignore <<EOL
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

node_modules
.DS_Store
error_log
*.log
.cache
dist
build
.env
.vscode
.idea
dump.rdb

/cypress/videos
EOL

mkdir src
cd src

# Create the index.ts file
echo "import express from \"express\";
import { Request, Response } from \"express\";
const PORT = 3000
const app = express();

app.get(\"/api/v1\", (req: Request, res: Response) => {
  const response = { 'hi': 'this works' }
  res.send(response);
});

app.listen(PORT, () => console.log(`start listening on port : ${PORT}`));" > index.ts

# create database support files
mkdir database
cd database

# db.ts
echo "import knex from \"knex\";
import configs from \"./knexfile\";

const config = configs[process.env.DB_ENV || \"development\"];

const db = knex(config);

export default db;" > db.ts

# knexfile.ts
cat > knexfile.ts <<EOL
// was unable to read .env since this was nested ?_?, unsure why that is
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

import { Knex } from "knex";

const DB = process.env.DATABASE_URL;
console.log("DB", DB);

interface IKnexConfig {
  [key: string]: Knex.Config;
}

const configs: IKnexConfig = {
  development: {
    client: "pg",
    connection: DB,
    debug: true,
    migrations: {
      directory: "./migrations",
      tableName: "knex_migrations",
    },
    seeds: {
      directory: "./seeds",
    },
  },

  production: {
    client: "pg",
    connection: DB + "?ssl=true",
    migrations: {
      directory: "./migrations",
      tableName: "knex_migrations",
    },
    pool: {
      min: 0,
      max: 7,
      acquireTimeoutMillis: 300000,
      createTimeoutMillis: 300000,
      destroyTimeoutMillis: 50000,
      idleTimeoutMillis: 300000,
      reapIntervalMillis: 10000,
      createRetryIntervalMillis: 2000,
      propagateCreateError: false,
    },
    acquireConnectionTimeout: 600000,
  },
};

export default configs;
EOL

cd ..
cd ..
cd ..

# react client stuff
cd client

cat > .gitignore <<EOL
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*

node_modules
.DS_Store
error_log
*.log
.cache
dist
build
.env
.vscode
.idea
dump.rdb

/cypress/videos
EOL

# install chakra deps if argument provided
if [ $# -eq 2 ]; then
  second_arg=$2
  echo "Second argument provided: $second_arg"
  if [ "$second_arg" == "chakra" ]; then
    yarn add @chakra-ui/react @emotion/react @emotion/styled framer-motion

    cd src
    cat > main.tsx << EOL
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import { ChakraProvider } from '@chakra-ui/react'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <ChakraProvider>
      <App />
    </ChakraProvider>
  </React.StrictMode>,
)
EOL

  cd ..
  fi
fi

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