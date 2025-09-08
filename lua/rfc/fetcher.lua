local utils = require("rfc.utils")
local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/rfc"
vim.fn.mkdir(cache_dir, "p")

local function parse_index(lines)
  local parsed = {}
  for _, line in ipairs(lines) do
    local id, title = string.match(line, "^(%d%d%d%d)%s+(.-)%.%s+[A-Z]")
    if id and title then
      table.insert(parsed, id .. ": " .. title)
    end
  end
  return parsed
end

local function handle_parsed_data(lines, callbacks)
  local parsed = parse_index(lines)
  if not vim.tbl_isempty(parsed) then
    callbacks.on_done(parsed)
  else
    callbacks.on_error("RFC Index fetched but no entries were parsed.")
  end
end

---@param callbacks { on_done: fun(data: string[]), on_error: fun(err: string) }
---@param force_refresh? boolean
function M.fetch_rfc_index(callbacks, force_refresh)
  local cache_path = cache_dir .. "/rfc-index.txt"

  if not force_refresh then
    local cached = utils.read_file_if_exists(cache_path)
    if cached and #cached > 0 then
      handle_parsed_data(cached, callbacks)
      return
    end
  end

  utils.fetch_url({
    url = "https://www.ietf.org/rfc/rfc-index.txt",
    on_success = function(lines)
      utils.write_file(cache_path, table.concat(lines, "\n"))
      handle_parsed_data(lines, callbacks)
    end,
    on_error = callbacks.on_error,
  })
end

---@param rfc_number number
---@param callback fun(data_lines: string[]|nil)
---@param force_refresh? boolean
function M.fetch_rfc_document(rfc_number, callback, force_refresh)
  local cache_path = string.format("%s/rfc%d.txt", cache_dir, rfc_number)

  if not force_refresh then
    local cached = utils.read_file_if_exists(cache_path)
    if cached then
      callback(cached)
      return
    end
  end

  local url = "https://www.rfc-editor.org/rfc/rfc" .. rfc_number .. ".txt"

  utils.fetch_url({
    url = url,
    on_success = function(data_lines)
      utils.write_file(cache_path, table.concat(data_lines, "\n"))
      callback(data_lines)
    end,
    on_error = function(err_msg)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
      callback(nil)
    end,
  })
end

return M
