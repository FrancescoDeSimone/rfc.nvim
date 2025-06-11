local M = {}

function M.show(rfc_data)
  local snacks = require("snacks")
  local fetcher = require("rfc.fetcher")

  -- Convert string list to snacks picker items (tables)
  local items = {}
  for _, line in ipairs(rfc_data) do
    table.insert(items, { text = line })
  end

  snacks.picker.pick({
    items = items,
    prompt = "RFC Index>",
    format = function(item)
      -- Return formatted lines for display
      return {
        { item.text, "Normal" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      -- Extract RFC number from the text
      local rfc_number = tonumber(item.text:match("^(%d+)"))
      if rfc_number then
        fetcher.open_rfc_document(rfc_number)
      else
        vim.notify("Invalid RFC number: " .. tostring(item.text), vim.log.levels.WARN)
      end
    end,
  })
end

return M
