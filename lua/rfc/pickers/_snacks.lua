local M = {}

---@param rfc_data string[]
function M.show(rfc_data)
  local ok, snacks = pcall(require, "snacks")
  local viewer = require("rfc.viewer")
  local utils = require("rfc.utils")
  if not ok then
    utils.notify("snacks not found", vim.log.levels.ERROR)
    return
  end

  snacks.picker.pick({
    prompt = "RFC Index> ",
    items = vim.tbl_map(function(line)
      return { text = line, value = line }
    end, rfc_data),
    format = "text",
    layout = { preset = "select" },
    preview = "none",

    actions = {
      open = function(picker)
        local item = picker:current()
        picker:close()
        if item then
          viewer.select_and_open(item.value, nil)
        end
      end,
      open_vsplit = function(picker)
        local item = picker:current()
        picker:close()
        if item then
          viewer.select_and_open(item.value, "vnew")
        end
      end,
      open_split = function(picker)
        local item = picker:current()
        picker:close()
        if item then
          viewer.select_and_open(item.value, "new")
        end
      end,
    },

    confirm = "open",
    win = {
      input = {
        keys = {
          ["<C-v>"] = { "open_vsplit", mode = { "i", "n" } },
          ["<C-x>"] = { "open_split", mode = { "i", "n" } },
        },
      },
      list = {
        keys = {
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
        },
      },
    },
  })
end

return M
