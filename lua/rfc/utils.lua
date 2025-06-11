local M = {}
local _notify_enabled = false

---@param enabled boolean
function M.set_notify(enabled)
  _notify_enabled = enabled
end

---@param msg string
---@param level number|nil
function M.notify(msg, level)
  if _notify_enabled then
    vim.notify(msg, level or vim.log.levels.INFO, { title = "RFC Viewer" })
  end
end

---Generic curl fetcher
---@class FetchUrlOpts
---@field url string
---@field on_success fun(data: string[])
---@field on_error fun(err_msg: string)

---@param opts FetchUrlOpts
function M.fetch_url(opts)
  local results = {}

  M.notify("Fetching: " .. opts.url)

  vim.fn.jobstart({ "curl", "-s", "-L", opts.url }, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(results, line)
        end
      end
    end,

    on_stderr = function(_, err)
      if err and #err > 0 and err[1] ~= "" then
        opts.on_error("Error fetching " .. opts.url .. ":\n" .. table.concat(err, "\n"))
      end
    end,

    on_exit = function(_, code)
      if code ~= 0 or vim.tbl_isempty(results) then
        opts.on_error("Failed to fetch: " .. opts.url .. " (exit code " .. code .. ")")
      else
        opts.on_success(results)
      end
    end,
  })
end

return M
