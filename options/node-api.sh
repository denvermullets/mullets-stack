#!/bin/bash

# Get the directory containing this script
script_dir=$(dirname "$0")

echo "📦 Initializing server package.json..."
yarn init -y
echo "✅ Package.json created"
echo "📦 Installing server dependencies..."
echo "  Production: express, knex, pg, dotenv, axios"
yarn add express knex pg dotenv axios
echo "✅ Production dependencies installed"

echo "📦 Installing server dev dependencies..."
echo "  Dev: nodemon, ts-node, typescript, @types/*"
yarn add -D nodemon ts-node typescript @types/express @types/node
echo "✅ Dev dependencies installed"
echo "⚙️  Initializing TypeScript configuration..."
yarn tsc --init
echo "✅ TypeScript config created"

echo "📝 Configuring server package.json scripts..."
# append the script to server package.json
jq '.scripts = {
    "build": "yarn install && tsc",
    "start:prod": "yarn db:migrate && node build/index.js",
    "start": "nodemon ./src/index.ts",
    "dev": "nodemon ./src/index.ts",
    "knex": "./node_modules/.bin/knex --knexfile src/database/knexfile.ts",
    "db:migrate": "yarn knex migrate:latest src/database/knexfile.ts",
    "db:rollback": "yarn knex migrate:rollback src/database/knexfile.ts"
}' package.json > package.json.tmp && mv package.json.tmp package.json
echo "✅ Server scripts configured"

echo "📋 Adding server .gitignore..."
source "$MAIN_SCRIPT_DIR/options/gitignore.sh"
echo "✅ Server .gitignore added"

echo "📁 Creating server source directory..."
mkdir src
cd src
echo "📍 Moved to src directory"

echo "📝 Creating Express server entry point..."
# Create the index.ts file
echo "import express from \"express\";
import { Request, Response } from \"express\";
const PORT = 3000
const app = express();

app.get(\"/api/v1\", (req: Request, res: Response) => {
  const response = { 'hi': 'this works' }
  res.send(response);
});

app.listen(PORT, () => console.log(\`start listening on port : \${PORT}\`));" > index.ts
echo "✅ Express server created (src/index.ts)"

echo "🗄️  Setting up database configuration..."
# create database support files
mkdir database
cd database
echo "📍 Moved to database directory"

echo "📝 Creating database connection file..."
# db.ts
echo "import knex from \"knex\";
import configs from \"./knexfile\";

const config = configs[process.env.DB_ENV || \"development\"];

const db = knex(config);

export default db;" > db.ts
echo "✅ Database connection created (src/database/db.ts)"

echo "📝 Creating Knex configuration file..."
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
echo "✅ Knex configuration created (src/database/knexfile.ts)"
echo "✅ Server setup complete!"