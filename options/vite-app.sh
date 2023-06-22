#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a project name as the first argument"
    exit 1
fi

project_name=$1

# create the frontend
yarn create vite "$project_name" --template react-ts

cd "$project_name"

git init

yarn add -D husky
yarn husky install
npm pkg set scripts.prepare="husky install"
npm pkg set scripts.test="tsc -p ./tsconfig.json"
yarn husky add .husky/pre-commit "yarn test"

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"

# create prettierrc file
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

yarn add @chakra-ui/react @emotion/react @emotion/styled framer-motion

cd src

cat > main.tsx << EOL
import React from "react";
import { ChakraProvider } from "@chakra-ui/react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";
import customTheme from "./theme";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <ChakraProvider theme={customTheme}>
      <App />
    </ChakraProvider>
  </React.StrictMode>
);

EOL

source "$MAIN_SCRIPT_DIR/options/chakra-styles.sh"