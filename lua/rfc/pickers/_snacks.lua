local M = {}
local function open_rfc(picker, open_mode)
  local fetcher = require("rfc.fetcher")
  local item = picker:current()
  if not item then
    return
  end

  picker:close()
  local num = tonumber(item.value:match("^(%d+)"))
  if num then
    fetcher.open_rfc_document(num, open_mode)
  end
end

---@param rfc_data string[]
function M.show(rfc_data)
  local snacks = require("snacks")

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
        open_rfc(picker, nil)
      end,
      open_vsplit = function(picker)
        open_rfc(picker, "vnew")
      end,
      open_split = function(picker)
        open_rfc(picker, "new")
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
