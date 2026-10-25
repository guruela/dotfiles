local keymap = vim.keymap

keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })
keymap.set("v", "<C-y>", '"+y', { desc = "Yank into clipboard" })
