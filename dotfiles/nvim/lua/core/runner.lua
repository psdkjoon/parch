local M = {}

local state = {
	buf = nil,
	win = nil,
	job_id = nil,
}

local function is_valid_win(win)
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
	return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

local function stop_running_job()
	if state.job_id ~= nil then
		pcall(vim.fn.jobstop, state.job_id)
		state.job_id = nil
	end
end

local function close_existing()
	stop_running_job()
	if is_valid_win(state.win) then
		pcall(vim.api.nvim_win_close, state.win, true)
	end
	if is_valid_buf(state.buf) then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
	end
	state.win = nil
	state.buf = nil
end

local function open_terminal(cmd)
	close_existing()

	vim.cmd("botright split")
	state.win = vim.api.nvim_get_current_win()
	vim.cmd("vertical resize 90")

	local ok, job_id = pcall(vim.fn.termopen, cmd, {
		on_exit = function()
			state.job_id = nil
		end,
	})

	state.buf = vim.api.nvim_get_current_buf()

	if ok then
		state.job_id = job_id
	end

	local this_buf = state.buf
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = this_buf,
		once = true,
		callback = function()
			if state.buf == this_buf then
				state.buf = nil
				state.win = nil
				state.job_id = nil
			end
		end,
	})

	vim.cmd("startinsert")
end

local project_runners = {
	rust = function()
		local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
		if cargo_toml ~= "" then
			return "cargo run"
		end
		local file = vim.fn.expand("%:p")
		return "rustc " .. vim.fn.shellescape(file) .. " -o /tmp/nvim_rust_run && /tmp/nvim_rust_run"
	end,
	dart = function()
		local pubspec = vim.fn.findfile("pubspec.yaml", ".;")
		local file = vim.fn.expand("%:p")
		if pubspec ~= "" then
			local content = vim.fn.readfile(pubspec)
			for _, line in ipairs(content) do
				if line:match("^%s*flutter:%s*$") or line:match("flutter:") then
					vim.notify(
						"This looks like a Flutter project. Use <leader>Fr to run with hot reload.",
						vim.log.levels.INFO
					)
					return nil
				end
			end
			return "dart run " .. vim.fn.shellescape(file)
		end
		return "dart run " .. vim.fn.shellescape(file)
	end,
}

local simple_runners = {
	python = function(file)
		return "python3 " .. vim.fn.shellescape(file)
	end,
	sh = function(file)
		return "bash " .. vim.fn.shellescape(file)
	end,
	bash = function(file)
		return "bash " .. vim.fn.shellescape(file)
	end,
	lua = function(file)
		return "lua " .. vim.fn.shellescape(file)
	end,
	go = function(file)
		return "go run " .. vim.fn.shellescape(file)
	end,
	c = function(file)
		return "gcc " .. vim.fn.shellescape(file) .. " -o /tmp/nvim_c_run && /tmp/nvim_c_run"
	end,
	cpp = function(file)
		return "g++ " .. vim.fn.shellescape(file) .. " -o /tmp/nvim_cpp_run && /tmp/nvim_cpp_run"
	end,
	cs = function(file)
		return "dotnet run"
	end,
}

function M.run(flags)
	flags = flags and (" " .. flags) or ""
	vim.cmd("silent! write")

	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local cmd

	if project_runners[ft] then
		cmd = project_runners[ft]()
		if cmd == nil then
			return
		end
	elseif simple_runners[ft] then
		cmd = simple_runners[ft](file)
	else
		local first_line = vim.fn.getline(1)
		if first_line:match("^#!") then
			cmd = vim.fn.shellescape(file)
		else
			vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
			return
		end
	end

	open_terminal(cmd .. flags)
end

function M.stop()
	if state.job_id == nil then
		vim.notify("No runner job is currently active", vim.log.levels.INFO)
		return
	end
	stop_running_job()
	vim.notify("Runner stopped", vim.log.levels.INFO)
end

function M.toggle_window()
	if is_valid_win(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
		return
	end
	if is_valid_buf(state.buf) then
		vim.cmd("botright split")
		state.win = vim.api.nvim_get_current_win()
		vim.cmd("vertical resize 90")
		vim.api.nvim_win_set_buf(state.win, state.buf)
		vim.cmd("startinsert")
	else
		vim.notify("No runner output to show", vim.log.levels.INFO)
	end
end

return M
