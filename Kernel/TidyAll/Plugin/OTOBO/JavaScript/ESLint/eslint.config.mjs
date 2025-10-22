import globals from "globals";
import pluginJs from "@eslint/js"

// Import custom rules
import noWindow from "./Rules/no-window.mjs";

/** @type {import('eslint').Linter.Config[]} */
export default [
  { 
    files: ["**/*.js"], 
    languageOptions: { sourceType: "commonjs" } 
  },
  {
    languageOptions: { 
      globals: {
        ...globals.browser, 
        ...globals.jquery,
        isJQueryObject: "readonly",
        CKEditor5Wrapper: "readonly",
        CKEditor5Plugins: "readonly"
      }
    },
    plugins: {
      custom: {
        rules: {
          'no-window': noWindow
        }
      }
    },
    rules: {
      'custom/no-window': 'error' // Enable the custom rule with proper namespace
    }
  },
  pluginJs.configs.recommended
];