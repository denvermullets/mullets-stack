#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a project name as the first argument"
    exit 1
fi

# Get the directory containing this script
script_dir=$(dirname "$0")

# create electron app, create folders and add dependencies
yarn create @quick-start/electron $1 --template react-ts
cd $1
yarn add @chakra-ui/react @emotion/react @emotion/styled framer-motion
yarn add husky -D
yarn husky install
npm pkg set scripts.prepare="husky install"
if [ ! -d ".husky" ]; then
  echo "Creating .husky directory"
  mkdir .husky
fi
yarn husky add .husky/pre-commit "yarn test"
mkdir src/renderer/src/theme
mkdir src/renderer/src/theme/components
source "$MAIN_SCRIPT_DIR/options/gitignore.sh"

# create theme files
echo "import React from 'react'
import ReactDOM from 'react-dom/client'
import customTheme from './theme'
import './assets/index.css'
import App from './App'
import { ChakraProvider } from '@chakra-ui/react'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <ChakraProvider theme={customTheme}>
      <App />
    </ChakraProvider>
  </React.StrictMode>
)" > src/renderer/src/main.tsx

# theme export
echo 'import { mode } from "@chakra-ui/theme-tools";
export const globalStyles = {
  colors: {
    darkMode: {
      50: "#f7f7f9",
    },
  },
  styles: {
    global: (props) => ({
      body: {
        overflowX: "hidden",
        bg: mode("pinkMoment.500", "darkMode.500")(props),
        letterSpacing: "-0.5px",
      },
      input: {
        color: "gray.700",
      },
    }),
  },
};' > src/renderer/src/theme/styles.ts

# set font
echo '@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Montserrat:wght@700&display=swap");' > src/renderer/src/theme/styles.css

# default text import
echo "import { extendTheme, theme as base, ThemeConfig } from '@chakra-ui/react'
import { globalStyles } from './styles'
import { momentText } from './components/text'

const config: ThemeConfig = {
  initialColorMode: 'dark'
}

const customTheme = extendTheme({
  config,
  fonts: {
    heading: \`Montserrat, \${base.fonts?.heading}\`,
    body: \`Inter, \${base.fonts?.body}\`
  },
  components: {
    Text: {
      ...momentText
    }
  },
  ...globalStyles
})

export default customTheme" > src/renderer/src/theme/index.ts

echo 'import { mode, StyleConfig, StyleFunctionProps } from "@chakra-ui/theme-tools";

export const momentText: StyleConfig = {
  baseStyle: (props: StyleFunctionProps) => ({
    color: mode("purpleMoment.800", "darkMode.200")(props),
  }),

  variants: {
    navLinks: (props: StyleFunctionProps) => ({
      color: mode("purpleMoment.900", "darkMode.100")(props),
      marginLeft: "5px",
      fontWeight: "800",
    }),
    navHeader: (props: StyleFunctionProps) => ({
      color: mode("purpleMoment.800", "darkMode.200")(props),
      fontWeight: "900",
      fontSize: "34px",
      _focus: { boxShadow: "none" },
    }),
  },
};' > src/renderer/src/theme/components/text.ts