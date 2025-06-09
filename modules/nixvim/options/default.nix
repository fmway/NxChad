{ internal, lib, inputs, helpers ? lib.nixvim, ... }:
let
  inherit (helpers) mkRawFn toLuaObject nKeymap' ntKeymap' toLuaObject';
in
{ pkgs, config, lib,... }:
let
  cfg = config.nvchad;
  chadrc = cfg.config // {
    base46 = removeAttrs cfg.config.base46 [ "second_theme" ];
  };
  base46-cache = inputs.self.packages.${pkgs.system}.base46-cache.override {
    inherit chadrc;
  };
in
{
  _file = ./default.nix;
  imports = [
    ./option.nix
    (lib.mkAliasOptionModule [ "nvchad" ] [ "nxchad" ])
  ];
  config = lib.mkIf cfg.enable {
    plugins.lz-n.enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      inputs.self.packages.${pkgs.system}.base46-patch
      nvchad-ui
      (pkgs.vimUtils.buildVimPlugin {
        name = "chadrc";
        src = pkgs.writeTextFile {
          name = "chadrc.lua";
          text = /* lua */ ''
            local M = ${toLuaObject chadrc}
            return M
          '';
          destination = "/lua/chadrc.lua";
        };
      })
    ];
    extraConfigLuaPre = lib.mkBefore /* lua */ ''
      -- disable some plugins
      vim.g.loaded_netrwPlugin = 1
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwSettings = 1
      vim.g.loaded_netrwFileHandlers = 1
      vim.g.loaded_netrw_gitignore = 1
      vim.g.loaded_zip = 1
      vim.g.loaded_zipPlugin = 1
      vim.g.loaded_2html_plugin = 1
      vim.g.loaded_gzip = 1
      vim.g.loaded_tarPlugin = 1

      vim.g.base46_cache = "${base46-cache}/"

      pcall(function()
        dofile(vim.g.base46_cache .. "syntax")
        dofile(vim.g.base46_cache .. "treesitter")
        dofile(vim.g.base46_cache .. "nvimtree")
        dofile(vim.g.base46_cache .. "devicons")
      end)
      -- for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
      --   dofile(vim.g.base46_cache .. v)
      -- end
    '';
    extraConfigLua = ''
      -- go to previous/next line with h,l,left arrow and right arrow
      -- when cursor reaches end/beginning of line
      vim.opt.whichwrap:append "<>[]hl"
    '';

    extraConfigLuaPost = ''
      vim.opt.shortmess:append "sI"

      require "nvchad"
      
      require("nvim-web-devicons").setup {
        override = require "nvchad.icons.devicons",
      }
    '';
    plugins.telescope = {
      luaConfig.pre = ''
        dofile(vim.g.base46_cache .. "telescope")
      '';
      enabledExtensions = [
        "themes"
        "terms"
      ];
    };

    plugins.gitsigns.luaConfig.pre = ''
      dofile(vim.g.base46_cache .. "git")
    '';

    plugins.indent-blankline.luaConfig.pre = ''
      dofile(vim.g.base46_cache .. "blankline")
    '';

    plugins.which-key.luaConfig.pre = ''
      dofile(vim.g.base46_cache .. "whichkey")
    '';

    plugins.web-devicons.enable = true;

    plugins.lsp.luaConfig.pre = ''
      dofile(vim.g.base46_cache .. "lsp")
      require("nvchad.lsp").diagnostic_config()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          M.on_attach(_, args.buf)
        end,
      })
    '';
    plugins.lsp.lazyLoad.settings.before = mkRawFn ''
      require('lz.n').trigger_load('blink.cmp')
    '';
    plugins.lsp.keymaps.extra = [
      (nKeymap' "<leader>ra" {
        __raw = ''require "nvchad.lsp.renamer"'';
      } "NVRenamer")
    ];

    plugins.blink-cmp.luaConfig.content = lib.mkOverride 60 /* lua */ ''
      ${toLuaObject' config.plugins.blink-cmp.luaConfig.pre}
      --
      local default = ${toLuaObject config.plugins.blink-cmp.settings}
      local opts = vim.tbl_deep_extend("force", default, require "nvchad.blink.config")
      require("blink-cmp").setup(opts)
      --
      ${toLuaObject' config.plugins.blink-cmp.luaConfig.post}
    '';

    plugins.blink-cmp.lazyLoad.settings.before = mkRawFn ''
      local lz = require('lz.n')
      lz.trigger_load('nvim-autopairs')
      lz.trigger_load('luasnip')
      lz.trigger_load('blink.compat')
    '';
    keymaps = [
      (nKeymap' "<leader>ch" "<cmd>NvCheatsheet<CR>" "toggle nvcheatsheet")

      # tabufline
      (nKeymap' "<leader>b" ("<cmd>en" + "ew<CR>") "buffer new")
      (nKeymap' "<tab>" (mkRawFn ''require("nvchad.tabufline").next()'') "buffer goto next")
      (nKeymap' "<S-tab>" (mkRawFn ''require("nvchad.tabufline").prev()'') "buffer goto prev")
      (nKeymap' "<leader>x" (mkRawFn ''require("nvchad.tabufline").close_buffer()'') "buffer close")
      (nKeymap' "<leader>th" (mkRawFn ''require("nvchad.themes").open()'') "telescope nvchad themes")
       # new terminals
      (nKeymap' "<leader>h" (mkRawFn ''require("nvchad.term").new { pos = "sp" }'') "terminal new horizontal term")
      (nKeymap' "<leader>v" (mkRawFn ''require("nvchad.term").new { pos = "vsp" }'') "terminal new vertical term")

      # toggleable
      (ntKeymap' "<A-v>" (mkRawFn ''require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }'') "terminal toggleable vertical term")
      (ntKeymap' "<A-h>" (mkRawFn ''require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }'') "terminal toggleable horizontal term")
      (ntKeymap' "<A-i>" (mkRawFn ''require("nvchad.term").toggle { pos = "float", id = "floatTerm" }'') "terminal toggle floating term")
    ];
    colorscheme = "nvchad";
  };
}
