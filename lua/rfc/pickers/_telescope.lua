local fetcher = require("rfc.fetcher")
local utils = require("rfc.utils")

local M = {}

---@param entries string[]
M.show = function(entries)
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    utils.notify("Telescope not found", vim.log.levels.ERROR)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "RFC Index",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return { value = entry, display = entry, ordinal = entry }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local function get_rfc_number()
          local entry = action_state.get_selected_entry()
          if entry and entry.value then
            return tonumber(string.match(entry.value, "^(%d+)"))
          end
          return nil
        end

        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local rfc = get_rfc_number()
          if rfc then
            fetcher.open_rfc_document(rfc, nil)
          end
        end)

        map("i", "<C-v>", function()
          actions.close(prompt_bufnr)
          local rfc = get_rfc_number()
          if rfc then
            fetcher.open_rfc_document(rfc, "vnew")
          end
        end)

        map("i", "<C-x>", function()
          actions.close(prompt_bufnr)
          local rfc = get_rfc_number()
          if rfc then
            fetcher.open_rfc_document(rfc, "new")
          end
        end)

        return true
      end,
    })
    :find()
end

return M
