{ internal, lib, ... }:
let
  inherit (lib.nixvim) mkRaw mkRawFn keymap;
in
{ config, lib, ... }:
{
  _file = ./keybindings.nix;
  keymaps = with config.plugins; [
    (keymap.n   "<leader>/" "gcc" "toggle comment" { remap = true; })
    (keymap.v   "<leader>/" "gc" "toggle comment" { remap = true; })
    (keymap.i   "<C-b>" "<ESC>^i" "move beginning offline" {})
    (keymap.i   "<C-e>" "<End>" "move end of line" {})
    (keymap.i   "<C-h>" "<Left>" "move left" {})
    (keymap.i   "<C-l>" "<Right>" "move right" {})
    (keymap.i   "<C-j>" "<Down>" "move down" {})
    (keymap.i   "<C-k>" "<Up>" "move up" {})
    (keymap.n   "<C-h>" "<C-w>h" "switch window left" {})
    (keymap.n   "<C-l>" "<C-w>l" "switch window right" {})
    (keymap.n   "<C-j>" "<C-w>j" "switch window down" {})
    (keymap.n   "<C-k>" "<C-w>k" "switch window up" {})
    (keymap.n   "<Esc>" "<cmd>noh<CR>" "general clear highlights" {})
    (keymap.n   "<C-s>" "<cmd>w<CR>" "general save file" {})
    (keymap.n   "<C-c>" "<cmd>%y+<CR>" "general copy whole file" {})
    (keymap.n   "<leader>n" "<cmd>set nu!<CR>" "toggle line number" {})
    (keymap.n   "<leader>rn" "<cmd>set rnu!<CR>" "toggle relative number" {})
    (keymap.n.x "<leader>fm" (mkRawFn ''require("conform").format { lsp_fallback = true }'') "general format file" {})
    (keymap.n   "<leader>ds" (mkRaw "vim.diagnostic.setloclist") "LSP diagnostic loclist" {})
    
    # terminal
    (keymap.t "<C-x>" "<C-\\><C-N>" "terminal escape terminal mode" {})

    # nvimtree
  ] ++ lib.optionals nvim-tree.enable [
    (keymap.n "<C-n>" "<cmd>NvimTreeToggle<CR>" "nvimtree toggle window" {})
    (keymap.n "<leader>e" "<cmd>NvimTreeFocus<CR>" "nvimtree focus window" {})
  ] ++ lib.optionals telescope.enable [
    # telescope
    (keymap.n "<leader>fw" "<cmd>Telescope live_grep<CR>" "telescope live grep" {})
    (keymap.n "<leader>fb" "<cmd>Telescope buffers<CR>" "telescope find buffers" {})
    (keymap.n "<leader>fh" "<cmd>Telescope help_tags<CR>" "telescope help page" {})
    (keymap.n "<leader>ma" "<cmd>Telescope marks<CR>" "telescope find marks" {})
    (keymap.n ("<leader>f"+"o") "<cmd>Telescope oldfiles<CR>" "telescope find oldfiles" {})
    (keymap.n "<leader>fz" "<cmd>Telescope current_buffer_fuzzy_find<CR>" "telescope find in current buffer" {})
    (keymap.n "<leader>cm" "<cmd>Telescope git_commits<CR>" "telescope git commits" {})
    (keymap.n "<leader>gt" "<cmd>Telescope git_status<CR>" "telescope git status" {})
    (keymap.n "<leader>pt" "<cmd>Telescope terms<CR>" "telescope pick hidden term" {})
    (keymap.n "<leader>ff" "<cmd>Telescope find_files<cr>" "telescope find files" {})
    (keymap.n "<leader>fa" "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>" "telescope find all files" {})
  ] ++ lib.optionals which-key.enable [
    # whichkey
    (keymap.n "<leader>wK" "<cmd>WhichKey <CR>" "whichkey all keymaps" {})
    (keymap.n "<leader>wk" (mkRawFn ''vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")'') "whichkey query lookup" {})
  ];
}
