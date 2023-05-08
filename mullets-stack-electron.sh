#!/bin/bash

# Check if project name argument is provided
if [ -z "$1" ]
  then
    echo "Please provide a project name as the first argument"
    exit 1
fi

# Create directory and move into it
mkdir $1
cd $1

# Initialize Node.js project
npm init -y

# Install dependencies
npm install electron typescript @chakra-ui/react @emotion/react @emotion/styled socket.io framer-motion --save-dev

# Create TypeScript configuration file
npx tsc --init

# Create main.ts file
touch main.ts

# Create index.html file
echo "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\">
    <title>$1</title>
  </head>
  <body>
    <div id=\"root\"></div>
    <script src=\"./renderer.js\"></script>
  </body>
</html>" > index.html

# Create renderer.tsx file
touch renderer.tsx

# Write code to main.ts file
echo "import { app, BrowserWindow } from 'electron';
import { ChakraProvider } from \"@chakra-ui/react\";
import * as io from 'socket.io';

let mainWindow: BrowserWindow | null = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true
    }
  });

  mainWindow.loadFile('index.html');

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

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
}

app.on('ready', () => {
  createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});" > main.ts

# Write code to renderer.tsx file
echo "import React from 'react';
import { render } from 'react-dom';
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

render(<App />, document.getElementById('root'));" > renderer.tsx

# Add start script to package.json
jq '.scripts += {"start": "electron ."}' package.json > tmp.json && mv tmp.json package.json

# Build TypeScript code

# # Build TypeScript code
# npx tsc

# # Start Electron app
# npm start
