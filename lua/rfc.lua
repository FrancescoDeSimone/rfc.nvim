local viewer = require("rfc.viewer")

---@class RFC.ConfigOpts
---@field picker string
---@field notification boolean

---@class RFC.Config
---@field opts RFC.ConfigOpts

---@class RFCModule
---@field config RFC.Config
---@field setup fun(opts: { picker?: string, notification?: boolean }?)
---@field command fun(opts: { fargs: string[] })

local RFC = {}

RFC.config = {
  opts = {
    -- pick the first not null picker
    picker = (function()
      for _, p in pairs(require("rfc.pickers")) do
        if p then
          return p
        end
      end
    end)(),
    notification = false,
  },
}

---@param args RFC.ConfigOpts
function RFC.setup(args)
  args = args or {}
  RFC.config.opts = vim.tbl_deep_extend("force", RFC.config.opts, args)
end

local function Picker(name)
  return require("rfc.pickers").get(name)
end

local function RfcOpen()
  local opts = RFC.config.opts
  local picker = Picker(opts.picker)
  viewer.Open(opts, picker)
end

local function RfcClean()
  local cache_dir = vim.fn.stdpath("cache") .. "/rfc"
  vim.fn.delete(cache_dir, "rf")
  vim.notify("Clean cache dir: " .. cache_dir)
end

local function RfcRefresh()
  require("rfc.fetcher").fetch_rfc_index({
    on_done = function(results)
      require("rfc.utils").notify("RFC Index refreshed successfully. Found " .. #results .. " entries.")
    end,
    on_error = function(err_msg)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
    end,
  }, true)
end

--- Entry point to open the RFC index viewer
---@param opts table The arguments passed by the user command
function RFC.command(opts)
  local arg = (opts.fargs or {})[1]
  if arg == "clean" then
    RfcClean()
  elseif arg == "refresh" then
    RfcRefresh()
  else
    RfcOpen()
  end
end

return RFC
