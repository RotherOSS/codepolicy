import globals from "globals";
import pluginJs from "@eslint/js"

// Import custom rules
import noWindow from "./Rules/no-window.mjs";

/** @type {import('eslint').Linter.Config[]} */
export default [
  pluginJs.configs.recommended,
  {
    languageOptions: { 
      sourceType: "commonjs", 
      globals: {
        ...globals.browser, 
        ...globals.jquery,
        isJQueryObject: "readonly",
        CKEditor5Wrapper: "readonly",
        CKEditor5Plugins: "readonly",
        CKEditor5CoreTranslations: "readonly",
        CKEditorInstances: "readonly",
        QUnit: "readonly",
        CodeMirror: "readonly"
      }
    },
    ignores: [
      "var/httpd/htdocs/js/thirdparty/**",
      "var/httpd/htdocs/js/js-cache/**",
      "var/httpd/htdocs/js/Core.UI.CKEditor5Wrapper.js"  // has to be ignored due to using import/export in a non-module file
    ],
    files: ["**/*.js"], 
    plugins: {
      otobo: {
        rules: {
          'no-window': noWindow
        }
      }
    },
    rules: {
      'otobo/no-window': 'error',
      'camelcase': 'warn',
      // The following rules are temparorily set to 'warn' to avoid breaking existing code

      'no-prototype-builtins': 'warn',
      'no-unused-vars': 'warn',
      'no-redeclare': 'warn',
      'no-undef': 'warn',
      'no-useless-escape': 'warn'

    }
  }
];