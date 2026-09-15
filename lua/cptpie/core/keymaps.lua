-- leader key is <space>
vim.g.mapleader = " "

local keymap = vim.keymap


---------------------
-- General Keymaps --
---------------------

-- exit insert mode
keymap.set("i","jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear highlight
keymap.set("n","<leader>nh", ":nohl<CR>", { desc = "Clear highlights" })

-- numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) 
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) 
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) 
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) 
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) 

-- command aliases
vim.api.nvim_create_user_command("W", "w<bang> <args>", { bang = true, nargs = "?", complete = "file", desc = "Alias for :w" })
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true, desc = "Alias for :q" })
vim.api.nvim_create_user_command("Wq", "wq<bang> <args>", { bang = true, nargs = "?", complete = "file", desc = "Alias for :wq" })
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true, desc = "Alias for :qa" })
vim.api.nvim_create_user_command("Wqa", "wqa<bang>", { bang = true, desc = "Alias for :wqa" })
