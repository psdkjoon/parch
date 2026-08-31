local cmd = vim.api.nvim_create_user_command

cmd("W", "w", {})
cmd("WQ", "wq", {})
cmd("WQA", "wqa", {})
cmd("Q", "q", {})
cmd("QA", "qa", {})
