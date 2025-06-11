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

return viewer
