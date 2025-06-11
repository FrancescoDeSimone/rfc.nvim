local M = {}

local pickers = {
  telescope = require("rfc.pickers._telescope"),
  snacks = require("rfc.pickers._snacks"),
}
M.get = function(picker_name)
  return pickers[picker_name]
end
return M
