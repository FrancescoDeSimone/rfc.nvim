local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
	vim.notify(
		"Telescope not found. Please install nvim-telescope/telescope.nvim",
		vim.log.levels.ERROR,
		{ title = "RFC Viewer Script" }
	)
	return
end

local actions_ok, actions = pcall(require, "telescope.actions")
local finders_ok, finders = pcall(require, "telescope.finders")
local pickers_ok, pickers = pcall(require, "telescope.pickers")
local conf_ok, conf = pcall(require, "telescope.config")
local action_state_ok, action_state = pcall(require, "telescope.actions.state")

if not (actions_ok and finders_ok and pickers_ok and conf_ok and action_state_ok) then
	vim.notify(
		"Failed to load some Telescope modules. Ensure Telescope is correctly installed.",
		vim.log.levels.ERROR,
		{ title = "RFC Viewer Script" }
	)
	return
end
local telescope_config_values = conf.values -- Get the actual config values table

-- Variable to hold the fetched data, accessible by callbacks
local rfc_data_for_picker = {}

-- Function to fetch and display the RFC index in Telescope
local function do_show_rfc_index_in_telescope()
	local url = "https://www.ietf.org/rfc/rfc-index.txt"
	local command = { "curl", "-s", "-L", url } -- -s for silent, -L to follow redirects

	vim.notify("Fetching RFC Index...", vim.log.levels.INFO, { title = "RFC Viewer" })
	rfc_data_for_picker = {} -- Clear previous data if any

	vim.fn.jobstart(command, {
		stdout_buffered = true, -- Buffer stdout until job completes or buffer is full
		stderr_buffered = true, -- Buffer stderr
		on_stdout = function(_, data_chunks, _)
			-- data_chunks is a table of strings (lines or chunks of lines)
			if data_chunks then
				for _, chunk in ipairs(data_chunks) do
					if chunk and #chunk > 0 then
						-- Each chunk could be multiple lines already if curl outputs that way,
						-- or it could be partial lines. vim.split handles newlines within the chunk.
						local lines_in_chunk = vim.split(chunk, "\n", { plain = true, trimempty = false })
						for _, line in ipairs(lines_in_chunk) do
							table.insert(rfc_data_for_picker, line)
						end
					end
				end
			end
		end,
		on_stderr = function(_, data, _)
			if data and #data > 0 and data[1] ~= "" then -- Check if there's actual error content
				local err_msg = "Error during RFC Index fetch (stderr):\n" .. table.concat(data, "\n")
				vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
				-- Populate with error to show in Telescope if stdout was empty
				if #rfc_data_for_picker == 0 then
					rfc_data_for_picker = { "Error fetching RFC Index. Check notifications." }
				end
			end
		end,
		on_exit = function(_, code, _)
			-- Handle case where curl exits non-zero and we might not have gotten stderr output
			-- or if stdout was empty despite a zero exit code.
			if
				code ~= 0
				and (
					#rfc_data_for_picker == 0
					or (#rfc_data_for_picker == 1 and string.find(rfc_data_for_picker[1], "Error"))
				)
			then
				local err_msg = "RFC Index fetch failed. Exit code: " .. code
				vim.notify(err_msg, vim.log.levels.ERROR, { title = "RFC Viewer" })
				rfc_data_for_picker = { "Error fetching RFC Index. Exit code: " .. tostring(code) }
			end

			if #rfc_data_for_picker == 0 then
				rfc_data_for_picker = { "No content received or an error occurred during fetch." }
			end

			-- Optional: Remove a single trailing empty line if present
			if #rfc_data_for_picker > 0 and rfc_data_for_picker[#rfc_data_for_picker] == "" then
				table.remove(rfc_data_for_picker)
			end

			-- Now, create and show the Telescope picker
			pickers
				.new({}, {
					prompt_title = "RFC Index",
					finder = finders.new_table({
						results = rfc_data_for_picker,
						-- entry_maker can be used for more complex display formatting if needed
						-- entry_maker = function(line)
						--   return {
						--     value = line,
						--     display = string.format("RFC Line: %s", line),
						--     ordinal = line -- for sorting
						--   }
						-- end
					}),
					sorter = telescope_config_values.generic_sorter({}), -- Use the default generic sorter
					attach_mappings = function(prompt_bufnr, map)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()
							if selection and selection.value then
								vim.notify(
									"Selected: " .. selection.value,
									vim.log.levels.INFO,
									{ title = "RFC Viewer" }
								)

								-- Example action: Try to parse RFC number and open its URL
								-- This regex looks for a sequence of digits at the start of the line (RFC number)
								-- or "RFC " followed by digits.
								local rfc_number_str = string.match(selection.value, "^(%d+)")
									or string.match(selection.value, "^RFC%s*?(%d+)")
								if rfc_number_str then
									local rfc_number = tonumber(rfc_number_str)
									if rfc_number then
										local rfc_url = "https://www.rfc-editor.org/rfc/rfc" .. rfc_number .. ".txt"
										vim.notify(
											"Attempting to open: " .. rfc_url,
											vim.log.levels.INFO,
											{ title = "RFC Viewer" }
										)
										local open_cmd
										if vim.fn.has("mac") == 1 then
											open_cmd = { "open", rfc_url }
										elseif vim.fn.has("unix") == 1 then -- General Linux/Unix
											open_cmd = { "xdg-open", rfc_url }
										elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
											open_cmd = { "cmd", "/c", "start", "", rfc_url } -- The empty "" is for title for start cmd
										else
											vim.notify(
												"Don't know how to open URLs on this system.",
												vim.log.levels.WARN,
												{ title = "RFC Viewer" }
											)
										end

										if open_cmd then
											vim.fn.jobstart(open_cmd, { detach = true })
										end
									end
								else
									vim.notify(
										"Could not parse RFC number from selected line.",
										vim.log.levels.WARN,
										{ title = "RFC Viewer" }
									)
								end
							end
						end)
						-- Important to return true to keep default mappings like <Esc> to close
						return true
					end,
				})
				:find() -- Show the picker
		end,
	})
end

-- DIRECTLY CALL THE FUNCTION WHEN THE SCRIPT IS EXECUTED
do_show_rfc_index_in_telescope()

-- End of script
