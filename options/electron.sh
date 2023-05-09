#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a project name as the first argument"
    exit 1
fi

# Get the directory containing this script
script_dir=$(dirname "$0")

mkdir $1
cd $1
git init

# yarn init -y
yarn add electron electron-builder react react-dom vite typescript @chakra-ui/react @emotion/react @emotion/styled socket.io-client -D
yarn add concurrently wait-on
yarn tsc --init

yarn add husky -D
yarn husky install
npm pkg set scripts.prepare="husky install"
if [ ! -d ".husky" ]; then
  echo "Creating .husky directory"
  mkdir .husky
fi
yarn husky add .husky/pre-commit "yarn test"

echo "import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: true,
    target: 'es2019',
    minify: true,
    rollupOptions: {
      input: 'src/index.tsx',
      output: {
        format: 'iife',
        entryFileNames: '[name].[hash].js',
        assetFileNames: '[name].[hash].[ext]',
      },
    },
  },
  resolve: {
    alias: {
      '@': '/src',
    },
  },
  server: {
    port: 3000,
  },
});" > vite.config.ts

mkdir -p src/components

echo "<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\" />
    <title>$1</title>
  </head>
  <body>
    <div id=\"root\"></div>
    <script type=\"module\" src=\"/src/index.tsx\"></script>
  </body>
</html>" > src/index.html

echo "import React from 'react';
import ReactDOM from 'react-dom';
import { ChakraProvider, Box, Heading } from '@chakra-ui/react';
import * as io from 'socket.io-client';

const socket = io('http://localhost:3000');

socket.on('connect', () => {
  console.log('Socket connected!');
});

socket.on('disconnect', () => {
  console.log('Socket disconnected!');
});

socket.on('message', (data: any) => {
  console.log('Received message from server:', data);
});

const App = () => (
  <ChakraProvider>
    <Box p=\"4\">
      <Heading size=\"lg\" mb=\"4\">$1</Heading>
      <p>This is my Electron app with ChakraUI and Socket.io!</p>
    </Box>
  </ChakraProvider>
);

ReactDOM.render(<App />, document.getElementById('root'));" > src/index.tsx

#!/bin/bash

# Create directory and move into it
mkdir electron
cd electron

# Create main.ts file
echo "import { app, BrowserWindow } from \"electron\";
import * as path from \"path\";
import installExtension, {
  REACT_DEVELOPER_TOOLS,
} from \"electron-devtools-installer\";

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, \"preload.js\"),
    },
  });

  if (app.isPackaged) {
    win.loadURL(\`file:///\${__dirname}/../index.html\`);
  } else {
    win.loadURL(\"http://localhost:3000/index.html\");

    win.webContents.openDevTools();

    require(\"electron-reload\")(__dirname, {
      electron: path.join(
        __dirname,
        \"..\",
        \"..\",
        \"node_modules\",
        \".bin\",
        \"electron\"
        + (process.platform === \"win32\" ? \".cmd\" : \"\")
      ),
      forceHardReset: true,
      hardResetMethod: \"exit\",
    });
  }
}

app.whenReady().then(() => {
  installExtension(REACT_DEVELOPER_TOOLS)
    .then((name) => console.log(\`Added Extension: \${name}\`))
    .catch((err) => console.log(\"An error occurred: \", err));

  createWindow();

  app.on(\"activate\", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });

  app.on(\"window-all-closed\", () => {
    if (process.platform !== \"darwin\") {
      app.quit();
    }
  });
});" > main.ts

# Create preload.ts file
touch preload.ts

# Create tsconfig.json file
echo "{
  \"compilerOptions\": {
    \"target\": \"es5\",
    \"module\": \"commonjs\",
    \"sourceMap\": true,
    \"strict\": true,
    \"outDir\": \"../build\",
    \"rootDir\": \"../\",
    \"noEmitOnError\": true,
    \"typeRoots\": [\"node_modules/@types\"]
  }
}" > tsconfig.json

cd ..

jq '.scripts += {"start": "vite"}' package.json > tmp.json && mv tmp.json package.json

jq '.scripts += {"build": "tsc && vite build"}' package.json > tmp.json && mv tmp.json package.json

jq '.scripts += {"electron": "electron ."}' package.json > tmp.json && mv tmp.json package.json

jq '.scripts += {"electron-build": "yarn build && tsc -p electron && electron-builder"}' package.json > tmp.json && mv tmp.json package.json

source "$MAIN_SCRIPT_DIR/options/gitignore.sh"