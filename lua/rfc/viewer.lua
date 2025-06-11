local viewer = {}
local fetcher = require("rfc.fetcher")
local utils = require("rfc.utils")

---@param opts { notification: boolean }
---@param picker {}
viewer.Open = function(opts, picker)
  utils.set_notify(opts.notification or false)
  fetcher.fetch_rfc_index({
    on_done = function(results)
      local rfc_data_for_picker = {}
      rfc_data_for_picker = results
      picker.show(rfc_data_for_picker)
    end,
    on_error = function(err_msg)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
    end,
  })
end

return viewer
