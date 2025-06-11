# rfc.nvim

Browse and read RFC documents directly within neovim. It fetches and caches RFC indexes and documents, offering a quick way to access these essential internet standards.

## Features
- Search the full RFC index
- Fetches and caches RFC content locally
- Configurable picker

## Installation

Install with your favorite package manager:

lazy.nvim:
```Lua
{
  'FrancescoDeSimone/rfc.nvim', 
  dependencies = {
    'nvim-telescope/telescope.nvim', -- or snacks.nvim
  },
  config = function()
    require('rfc').setup({
      picker = 'telescope', -- or 'snacks'
      notification = true,  -- Enable/disable notifications
    })
  end
}
```

## Usage
Open the RFC index:
```vim
:RFC
```
