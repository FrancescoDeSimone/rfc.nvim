local utils = require("rfc.utils")
local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/rfc"
vim.fn.mkdir(cache_dir, "p")

local function read_file_if_exists(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return vim.split(content, "\n", { plain = true })
end

local function write_file(path, content)
  local f = io.open(path, "w")
  if not f then
    return false
  end
  f:write(content)
  f:close()
  return true
end

---@param callbacks { on_done: fun(data: string[]), on_error: fun(err: string) }
---@param force_refresh? boolean
function M.fetch_rfc_index(callbacks, force_refresh)
  local cache_path = cache_dir .. "/rfc-index.txt"

  if not force_refresh then
    local cached = read_file_if_exists(cache_path)
    if cached and #cached > 0 then
      local parsed = {}
      for _, line in ipairs(cached) do
        local id, title = string.match(line, "^(%d%d%d%d)%s+(.-)%.%s+[A-Z]")
        if id and title then
          table.insert(parsed, id .. ": " .. title)
        end
      end
      if not vim.tbl_isempty(parsed) then
        callbacks.on_done(parsed)
        return
      end
    end
  end

  utils.fetch_url({
    url = "https://www.ietf.org/rfc/rfc-index.txt",
    on_success = function(lines)
      write_file(cache_path, table.concat(lines, "\n"))
      local parsed = {}
      for _, line in ipairs(lines) do
        local id, title = string.match(line, "^(%d%d%d%d)%s+(.-)%.%s+[A-Z]")
        if id and title then
          table.insert(parsed, id .. ": " .. title)
        end
      end
      if vim.tbl_isempty(parsed) then
        callbacks.on_error("RFC Index fetched but no entries were parsed.")
      else
        callbacks.on_done(parsed)
      end
    end,
    on_error = callbacks.on_error,
  })
end

--- Fetch and open an RFC document in buffer (cached on disk)
---@param rfc_number number
---@param open_mode? string
---@param force_refresh? boolean
function M.open_rfc_document(rfc_number, open_mode, force_refresh)
  local cache_path = string.format("%s/rfc%d.txt", cache_dir, rfc_number)

  local function open_in_buffer(data_lines)
    local prev_win = vim.api.nvim_get_current_win()
    if open_mode then
      local ok = pcall(vim.cmd, open_mode)
      if not ok then
        utils.notify("Invalid open_mode: " .. open_mode, vim.log.levels.ERROR)
        return
      end
    end
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_win(prev_win)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_name(buf, "RFC" .. rfc_number)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data_lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "modified", false)
    utils.notify("RFC " .. rfc_number .. " loaded.", vim.log.levels.INFO)
  end

  if not force_refresh then
    local cached = read_file_if_exists(cache_path)
    if cached then
      open_in_buffer(cached)
      return
    end
  end

  local url = "https://www.rfc-editor.org/rfc/rfc" .. rfc_number .. ".txt"
  utils.fetch_url({
    url = url,
    on_success = function(data_lines)
      write_file(cache_path, table.concat(data_lines, "\n"))
      open_in_buffer(data_lines)
    end,
    on_error = function(err_msg)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
    end,
  })
end

return M
