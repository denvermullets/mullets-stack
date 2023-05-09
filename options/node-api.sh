#!/bin/bash

# Get the directory containing this script
script_dir=$(dirname "$0")

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

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"

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