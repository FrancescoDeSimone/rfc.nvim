-- main module file
local viewer = require("rfc.viewer")

---@class Config
---@field opt string Your config option
local config = {
  opts = {
    picker = "snacks",
    notification = false,
  },
}

---@class RFC
local RFC = {}

---@type Config
RFC.config = config
RFC.picker = function(picker_name)
  return require("rfc.pickers").get(picker_name)
end

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
RFC.setup = function(args)
  RFC.config = vim.tbl_deep_extend("force", RFC.config, args or {})
end

RFC.rfcOpen = function()
  return viewer.Open(RFC.config.opts, RFC.picker(RFC.config.opts.picker))
end

return RFC
