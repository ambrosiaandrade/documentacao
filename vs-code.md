### ✅ **1. Java Development Enhancements**

```jsonc
// Show parameter hints while typing
"editor.parameterHints.enabled": true,

// Enable Java inlay hints (type hints, parameter names)
"java.inlayHints.parameterNames.enabled": "all",
"java.inlayHints.parameterNames.suppressWhenArgumentMatchesName": false,
"java.inlayHints.parameterTypes.enabled": true,
"java.inlayHints.variableTypes.enabled": true,

// Enable semantic highlighting for Java
"editor.semanticHighlighting.enabled": true,

// Automatically organize imports
"java.format.onSave.organizeImports": true,

// Enable preview features (if using Java 17+ and Records, Sealed, etc.)
"java.configuration.enablePreview": true,

// Linting and Code Analysis
"java.errors.incompleteClasspath.severity": "warning"
```

---

### ✅ **2. Editor Quality of Life**

```jsonc
// Tab size and consistent formatting
"editor.tabSize": 4,
"editor.insertSpaces": true,

// Trim trailing whitespace
"files.trimTrailingWhitespace": true,

// Auto-save
"files.autoSave": "onWindowChange",

// Word wrap for easier reading
"editor.wordWrap": "on",

// Bracket pair colorization
"editor.bracketPairColorization.enabled": true,

// Highlight matching brackets
"editor.matchBrackets": "always",

// Breadcrumbs for navigation
"breadcrumbs.enabled": true,
```

---

### ✅ **3. Multi-Cursor & Selection Tweaks**

If you want to use **Alt + Click** for multiple cursors (instead of Ctrl/Cmd):

```jsonc
"editor.multiCursorModifier": "alt",
"editor.accessibilitySupport": "off"

//"editor.multiCursorModifier": "ctrlCmd"
```

---

### ✅ **4. Terminal & Git Integration**

```jsonc
// Java terminal for Gradle/Maven
"terminal.integrated.defaultProfile.windows": "Command Prompt",
"terminal.integrated.env.windows": {
    "JAVA_HOME": "C:\\Program Files\\Java\\jdk-17" // Adjust path
},

// Git auto fetch
"git.autofetch": true,
"git.confirmSync": false,
```

---

### ✅ **5. Suggested Extensions (if not already installed)**

- ✅ `redhat.java` (Java Language Support)
- ✅ `vscjava.vscode-java-debug` (Java Debugger)
- ✅ `vscjava.vscode-java-test` (Java Test Runner)
- ✅ `vscjava.vscode-maven` (for Maven support)
- ✅ `esbenp.prettier-vscode`
- ✅ `dbaeumer.vscode-eslint` (for JS/TS linting)
- ✅ `eamodio.gitlens`
- ✅ `formulahendry.code-runner` (Run snippets easily)
- ✅ `vscode-icons`
- ✅ `pkief.material-icon-theme`

---

### ✅ **6. Workspace-Specific Java Configs (Optional)**

Create a `.vscode/settings.json` per project to override global behavior, especially if some Java projects differ in structure or Java version.

---

```json
{
  "workbench.iconTheme": "material-icon-theme",
  "workbench.colorTheme": "Deepdark Material Theme | Full Black Version",
  "vsicons.dontShowNewVersionMessage": true,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "vscode.html-language-features"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[java]": {
    "editor.defaultFormatter": "redhat.java"
  },
  "java.project.sourcePaths": ["src/main/java"],
  "editor.multiCursorModifier": "ctrlCmd",
  // Show parameter hints while typing
  "editor.parameterHints.enabled": true,
  // Enable auto-format on save
  "editor.formatOnSave": true,
  // Tab size and consistent formatting
  "editor.tabSize": 4,
  "editor.insertSpaces": true,

  // Trim trailing whitespace
  "files.trimTrailingWhitespace": true,
  // Enable auto-save
  "files.autoSave": "afterDelay",
  // Set the default terminal to bash
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  // Enable word wrap
  "editor.wordWrap": "on",
  // Show line numbers
  "editor.lineNumbers": "on",
  // Enable bracket pair colorization
  "editor.bracketPairColorization.enabled": true,
  // Highlight matching brackets
  "editor.matchBrackets": "always",
  // Enable minimap
  "editor.minimap.enabled": true,
  // Enable code lens
  "editor.codeLens": true,
  // Breadcrumbs for navigation
  "breadcrumbs.enabled": true,
  // Enable code actions on save
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },

  // Enable Java inlay hints (type hints, parameter names)
  "java.inlayHints.parameterNames.enabled": "all",
  "java.inlayHints.parameterNames.suppressWhenArgumentMatchesName": false,
  "java.inlayHints.parameterTypes.enabled": true,
  "java.inlayHints.variableTypes.enabled": true,

  // Enable semantic highlighting for Java
  "editor.semanticHighlighting.enabled": true,

  // Automatically organize imports
  "java.format.onSave.organizeImports": true,

  // Enable preview features (if using Java 17+ and Records, Sealed, etc.)
  "java.configuration.enablePreview": true,

  // Linting and Code Analysis
  "java.errors.incompleteClasspath.severity": "warning"
}
```

Perfeito! Abaixo está um **perfil “Modo Estudo”** para Java no VS Code — ideal para fazer exercícios com **zero distrações**: sem IntelliSense, sem dicas, sem sugestões, sem organização automática, e com apenas o essencial para digitar e compilar.

---

## 🎓 `settings.json` — Modo Estudo (limpo e silencioso)

Copie e substitua no seu arquivo `settings.json` (ou crie um perfil separado):

```json
{
  "workbench.iconTheme": "material-icon-theme",
  "workbench.colorTheme": "Default Dark+",

  // Linguagem do Java com configurações de estudo
  "[java]": {
    "editor.defaultFormatter": null,
    "editor.quickSuggestions": {
      "other": false,
      "comments": false,
      "strings": false
    },
    "editor.suggestOnTriggerCharacters": false,
    "editor.parameterHints.enabled": false,
    "editor.formatOnType": false,
    "editor.codeLens": false,
    "editor.inlayHints.enabled": "off"
  },

  // Desabilita sugestões e IntelliSense globalmente
  "editor.quickSuggestions": {
    "other": false,
    "comments": false,
    "strings": false
  },
  "editor.suggestOnTriggerCharacters": false,
  "editor.parameterHints.enabled": false,
  "editor.wordBasedSuggestions": false,
  "editor.inlineSuggest.enabled": false,
  "editor.hover.enabled": false,
  "editor.suggest.showWords": false,
  "editor.suggest.snippetsPreventQuickSuggestions": false,

  // Desativa todas as sugestões específicas
  "editor.suggest.showMethods": false,
  "editor.suggest.showFunctions": false,
  "editor.suggest.showConstructors": false,
  "editor.suggest.showFields": false,
  "editor.suggest.showVariables": false,
  "editor.suggest.showClasses": false,
  "editor.suggest.showInterfaces": false,
  "editor.suggest.showModules": false,
  "editor.suggest.showProperties": false,
  "editor.suggest.showEvents": false,
  "editor.suggest.showOperators": false,
  "editor.suggest.showUnits": false,
  "editor.suggest.showValues": false,
  "editor.suggest.showConstants": false,
  "editor.suggest.showEnums": false,

  // Auto save e aparência básica
  "files.autoSave": "afterDelay",
  "files.trimTrailingWhitespace": true,
  "editor.tabSize": 4,
  "editor.insertSpaces": true,
  "editor.wordWrap": "on",
  "editor.lineNumbers": "on",

  // Terminal padrão (opcional)
  "terminal.integrated.defaultProfile.windows": "Git Bash",

  // Desabilita ferramentas Java adicionais
  "java.completion.enabled": false,
  "java.inlayHints.parameterNames.enabled": "none",
  "java.inlayHints.parameterTypes.enabled": false,
  "java.inlayHints.variableTypes.enabled": false,
  "java.referencesCodeLens.enabled": false,
  "java.contentProvider.preferred": "none",
  "java.errors.incompleteClasspath.severity": "ignore",
  "java.format.onSave.organizeImports": false,

  // Visual simples
  "editor.minimap.enabled": false,
  "editor.bracketPairColorization.enabled": false,
  "breadcrumbs.enabled": false
}
```

---

Ajuste nas cores dos () {} ...

```json
"editor.bracketPairColorization.enabled": true,
"workbench.colorCustomizations": {
  "editorBracketHighlight.foreground1": "#FFB86C",  // laranja
  "editorBracketHighlight.foreground2": "#8BE9FD",  // azul claro
  "editorBracketHighlight.foreground3": "#50FA7B",  // verde
  "editorBracketHighlight.unexpectedBracket.foreground": "#FF5555",  // vermelho para brackets inesperados
  "editorBracketMatch.border": "#FFFFFF",  // borda quando você clica no {}
  "editorBracketMatch.background": "#00000000"  // fundo transparente para evitar sobreposição
}

```

---

## 🧪 Como usar

### 🔁 Para alternar entre “modo estudo” e “modo completo”:

- Use perfis no VS Code:
  `Ctrl + Shift + P` → `Profiles: Create Profile`
- Crie um para **Estudo Java** e um para **Desenvolvimento Completo**.
- Depois alterne entre eles facilmente via `Ctrl + Shift + P` → `Profiles: Switch Profile`.
