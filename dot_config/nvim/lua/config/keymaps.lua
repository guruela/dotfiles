local keymap = vim.keymap

keymap.set("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })
keymap.set("v", "<C-y>", '"+y', { desc = "Yank to system clipboard", silent = true })
