local viewer = require("rfc.viewer")

---@class RFC.ConfigOpts
---@field picker string
---@field notification boolean

---@class RFC.Config
---@field opts RFC.ConfigOpts

---@class RFCModule
---@field config RFC.Config
---@field setup fun(opts: { picker?: string, notification?: boolean }?)
---@field rfcOpen fun(): nil
---@field picker fun(name: string): RFCViewer.Picker

local RFC = {}

RFC.config = {
  opts = {
    picker = "snacks", -- or "telescope"
    notification = false,
  },
}

---@param args RFC.ConfigOpts
function RFC.setup(args)
  args = args or {}
  RFC.config.opts = vim.tbl_deep_extend("force", RFC.config.opts, args)
end

---@param name string
---@return RFCViewer.Picker
function RFC.picker(name)
  return require("rfc.pickers").get(name)
end

--- Entry point to open the RFC index viewer
function RFC.rfcOpen()
  local opts = RFC.config.opts
  local picker = RFC.picker(opts.picker)
  viewer.Open(opts, picker)
end

return RFC
