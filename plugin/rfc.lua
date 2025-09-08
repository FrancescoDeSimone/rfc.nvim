vim.api.nvim_create_user_command("RFC", require("rfc").command, {
  nargs = "?", -- Allows the command to accept zero or one argument
  complete = function(_arglead, _cmdline, _cursorpos)
    -- This provides tab-completion for your subcommands
    return { "clean", "refresh" }
  end,
})
