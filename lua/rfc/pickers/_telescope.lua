local M = {}

---@param entries string[]
M.show = function(entries)
  local utils = require("rfc.utils")
  local viewer = require("rfc.viewer")
  local ok, _ = pcall(require, "telescope")
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
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            viewer.select_and_open(entry.value, nil)
          end
        end)

        map("i", "<C-v>", function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            viewer.select_and_open(entry.value, "vnew")
          end
        end)

        map("i", "<C-x>", function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            viewer.select_and_open(entry.value, "new")
          end
        end)

        return true
      end,
    })
    :find()
end

return M
