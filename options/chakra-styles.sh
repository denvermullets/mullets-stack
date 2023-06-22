#! /bin/bash

mkdir theme
cd theme

touch styles.ts
cat > styles.ts << EOL
export const globalStyles = {
  colors: {
    colorThemeName: {
      50: "#C8102E",
      100: "#ffffff",
    },
  },
  styles: {
    global: () => ({
      body: {
        overflowX: "hidden",
        bg: "gray.200",
        letterSpacing: "-0.5px",
      },
    }),
  },
};
EOL

touch styles.css
cat > styles.css << EOL
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Montserrat:wght@700&display=swap');
EOL


touch index.ts
cat > index.ts << 'EOL'
import { extendTheme, theme as base } from "@chakra-ui/react";
import { globalStyles } from "./styles";
import { momentText } from "./components/text";

const customTheme = extendTheme({
  fonts: {
    heading: \`Montserrat, \${base.fonts?.heading}\`,
    body: \`Inter, \${base.fonts?.body}\`,
  },
  components: {
    Text: {
      ...momentText,
    },
  },
  ...globalStyles,
});

export default customTheme;
EOL

mkdir components
cd components
touch text.ts
cat > text.ts << EOL
import { mode, StyleConfig, StyleFunctionProps } from "@chakra-ui/theme-tools";

// don't forget to update colors to ones you have defined in your color theme
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
};
EOL