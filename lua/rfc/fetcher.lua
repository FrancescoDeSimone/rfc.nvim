local utils = require("rfc.utils")
local M = {}

---@param callbacks { on_done: fun(data: string[]), on_error: fun(err: string) }
function M.fetch_rfc_index(callbacks)
  local function parse_line(line)
    local rfc_id, rfc_title = string.match(line, "^(%d%d%d%d)%s+(.-)%.%s+[A-Z]")
    if rfc_id and rfc_title then
      return rfc_id .. ": " .. rfc_title
    end
    return nil
  end

  utils.fetch_url({
    url = "https://www.ietf.org/rfc/rfc-index.txt",
    on_success = function(lines)
      local parsed = {}
      for _, line in ipairs(lines) do
        local result = parse_line(line)
        if result then
          table.insert(parsed, result)
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

function M.open_rfc_document(rfc_number, open_mode)
  local url = "https://www.rfc-editor.org/rfc/rfc" .. rfc_number .. ".txt"

  utils.fetch_url({
    url = url,
    on_success = function(data_lines)
      local previous_win = vim.api.nvim_get_current_win()
      if open_mode then
        vim.cmd(open_mode)
      end
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_set_current_win(previous_win)

      vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
      vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
      vim.api.nvim_buf_set_option(buf, "swapfile", false)
      vim.api.nvim_buf_set_name(buf, "RFC" .. rfc_number)
      vim.api.nvim_buf_set_option(buf, "modifiable", true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, data_lines)
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
      vim.api.nvim_buf_set_option(buf, "modified", false)

      utils.notify("RFC " .. rfc_number .. " loaded.", vim.log.levels.INFO)
    end,
    on_error = function(err_msg)
      vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
    end,
  })
end

return M
