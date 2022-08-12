# moon.nvim

This neovim plugin uses [null-ls](https://github.com/jose-elias-alvarez/null-ls.nvim) and the moonscript linter to generate diagnostics for [moonscript](moonscript.org) files.

## Installation with packer.nvim

```lua
use {
  "tombl/moon.nvim",
  ft = "moon",
  rocks = "moonscript",
  requires = {
    "jose-elias-alvarez/null-ls.nvim",
    "leafo/moonscript-vim"
  },
  config = function()
    require("moon-nvim").setup {}
  end
}
```

## Configuration
By default, the plugin is configured to lint for a Neovim config written in moonscript, with the globals taken from the currently loaded editor. To change the globals, just pass a table of your target environment's globals to the setup function like so:
```lua
require("moon-nvim").setup {
    globals = {
        "print",
        "require",
        "pairs",
        "ipairs",
        -- etc
    }
}
```