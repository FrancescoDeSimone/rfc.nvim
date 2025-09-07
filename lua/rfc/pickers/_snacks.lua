local M = {}

function M.show(rfc_data)
  local snacks = require("snacks")
  local fetcher = require("rfc.fetcher")

  snacks.picker.pick({
    prompt = "RFC Index> ",
    items = vim.tbl_map(function(line)
      return { text = line, value = line }
    end, rfc_data),
    format = "text",
    layout = { preset = "select" },
    preview = "none",
    confirm = function(picker, item)
      picker:close()
      local num = tonumber(item.value:match("^(%d+)"))
      if num then
        fetcher.open_rfc_document(num)
      end
    end,
  })
end

return M
