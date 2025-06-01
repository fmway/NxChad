{ internal, lib, ... }:
let
  inherit (lib.nixvim) mkRawFn iKeymap' nKeymap' vKeymap' tKeymap';
in
{ config, lib, ... }:
{
  _file = ./keybindings.nix;
  keymaps = with config.plugins; [
    (nKeymap' "<leader>/" "gcc" "toggle comment" // {
      options.remap = true;
    })
    (vKeymap' "<leader>/" "gc" "toggle comment" // {
      options.remap = true;
    })
    (iKeymap' "<C-b>" "<ESC>^i" "move beginning of line")
    (iKeymap' "<C-e>" "<End>" "move end of line")
    (iKeymap' "<C-h>" "<Left>" "move left")
    (iKeymap' "<C-l>" "<Right>" "move right")
    (iKeymap' "<C-j>" "<Down>" "move down")
    (iKeymap' "<C-k>" "<Up>" "move up")
    (nKeymap' "<C-h>" "<C-w>h" "switch window left")
    (nKeymap' "<C-l>" "<C-w>l" "switch window right")
    (nKeymap' "<C-j>" "<C-w>j" "switch window down")
    (nKeymap' "<C-k>" "<C-w>k" "switch window up")
    (nKeymap' "<Esc>" "<cmd>noh<CR>" "general clear highlights")
    (nKeymap' "<C-s>" "<cmd>w<CR>" "general save file")
    (nKeymap' "<C-c>" "<cmd>%y+<CR>" "general copy whole file")
    (nKeymap' "<leader>n" "<cmd>set nu!<CR>" "toggle line number")
    (nKeymap' "<leader>rn" "<cmd>set rnu!<CR>" "toggle relative number")
    (nKeymap' "<leader>fm" (mkRawFn ''require("conform").format { lsp_fallback = true }'') "general format file")
    (nKeymap' "<leader>ds" {
      __raw = "vim.diagnostic.setloclist";
    } "LSP diagnostic loclist")
    
    # terminal
    (tKeymap' "<C-x>" "<C-\\><C-N>" "terminal escape terminal mode")

    # nvimtree
  ] ++ lib.optionals nvim-tree.enable [
    (nKeymap' "<C-n>" "<cmd>NvimTreeToggle<CR>" "nvimtree toggle window")
    (nKeymap' "<leader>e" "<cmd>NvimTreeFocus<CR>" "nvimtree focus window")
  ] ++ lib.optionals telescope.enable [
    # telescope
    (nKeymap' "<leader>fw" "<cmd>Telescope live_grep<CR>" "telescope live grep")
    (nKeymap' "<leader>fb" "<cmd>Telescope buffers<CR>" "telescope find buffers")
    (nKeymap' "<leader>fh" "<cmd>Telescope help_tags<CR>" "telescope help page")
    (nKeymap' "<leader>ma" "<cmd>Telescope marks<CR>" "telescope find marks")
    (nKeymap' ("<leader>f"+"o") "<cmd>Telescope oldfiles<CR>" "telescope find oldfiles")
    (nKeymap' "<leader>fz" "<cmd>Telescope current_buffer_fuzzy_find<CR>" "telescope find in current buffer")
    (nKeymap' "<leader>cm" "<cmd>Telescope git_commits<CR>" "telescope git commits")
    (nKeymap' "<leader>gt" "<cmd>Telescope git_status<CR>" "telescope git status")
    (nKeymap' "<leader>pt" "<cmd>Telescope terms<CR>" "telescope pick hidden term")
    (nKeymap' "<leader>ff" "<cmd>Telescope find_files<cr>" "telescope find files")
    (nKeymap' "<leader>fa" "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>" "telescope find all files")
  ] ++ lib.optionals which-key.enable [
    # whichkey
    (nKeymap' "<leader>wK" "<cmd>WhichKey <CR>" "whichkey all keymaps")
    (nKeymap' "<leader>wk" (mkRawFn ''
      vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
    '') "whichkey query lookup")
  ];
}
