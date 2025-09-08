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
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
    end,
  })
end

---@param entry_value string | nil The full string value from the picker (e.g., "1234: Title").
---@param open_mode string | nil The command to use for opening the window (e.g., "vnew").
function viewer.select_and_open(entry_value, open_mode)
  if not entry_value then
    return
  end

  local rfc_number = tonumber(string.match(entry_value, "^(%d+)"))
  if rfc_number then
    fetcher.open_rfc_document(rfc_number, open_mode)
  end
end
return viewer
