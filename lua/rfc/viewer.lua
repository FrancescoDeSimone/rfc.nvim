local viewer = {}

local fetcher = require("rfc.fetcher")
local utils = require("rfc.utils")

---@class RFCViewer.Picker
---@field show fun(items: string[])

---@param opts { notification?: boolean }
---@param picker RFCViewer.Picker
viewer.Open = function(opts, picker)
  opts = opts or {}
  utils.set_notify(opts.notification or false)

  fetcher.fetch_rfc_index({
    on_done = function(results)
      picker.show(results)
    end,
    on_error = function(err_msg)
      utils.notify(err_msg, vim.log.levels.ERROR)
    end,
  })
end

local function open_in_buffer(data_lines, rfc_number, open_mode)
  local prev_win = vim.api.nvim_get_current_win()
  if open_mode then
    if not pcall(vim.cmd, open_mode) then
      utils.notify("Invalid open_mode: " .. open_mode, vim.log.levels.ERROR)
      return
    end
  end
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_win(prev_win)
  vim.api.nvim_buf_set_name(buf, "RFC" .. rfc_number)

  vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, data_lines)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  utils.notify("RFC " .. rfc_number .. " loaded.", vim.log.levels.INFO)
end

---@param entry_value string | nil The full string value from the picker (e.g., "1234: Title").
---@param open_mode string | nil The command to use for opening the window (e.g., "vnew").
---@param force_refresh boolean| nil Force the refresh of the rfc overriding the cache
function viewer.select_and_open(entry_value, open_mode, force_refresh)
  if not entry_value then
    return
  end

  local rfc_number = tonumber(string.match(entry_value, "^(%d+)"))
  if rfc_number then
    fetcher.fetch_rfc_document(rfc_number, function(data)
      if data then
        open_in_buffer(data, rfc_number, open_mode)
      else
        utils.notify("Failed to fetch RFC", vim.log.levels.ERROR)
      end
    end, force_refresh)
  end
end
return viewer
