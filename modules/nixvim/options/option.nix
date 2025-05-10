{ config, lib, ... }: let
  mkFloatOption = desc: default:
    lib.mkOption {
      type = with lib.types; nullOr float;
      inherit default;
    };
  mkStrOption = desc: default:
    lib.mkOption {
      type = with lib.types; nullOr str;
      inherit default;
    };
  cfg = config.nxchad;
  generated = import ./generated.nix { inherit lib; };
in {
  _file = ./option.nix;
  options = {
    nxchad.enable = lib.mkEnableOption "Enable NvChad" // { default = true; };
    nxchad.config = with lib; {
      base46 = {
        theme = mkOption {
          type = generated.ThemeName;
          description = "Default themes";
          default = "onedark";
          example = ''"chocolate"'';
        };
        second_theme = mkOption {
          type = generated.ThemeName;
          description = "Second theme";
          default = "one_light";
          example = ''"catppuccin"'';
        };
        theme_toggle = mkOption {
          type = let
            type = types.listOf generated.ThemeName;
          in type // {
            name = "list of the 2 string, one of them must be the default theme";
            check = list: type.check list && lib.length list == 2;
          };
          description = "list themes to toggle theme";
          apply = value:
            lib.take 2 value;
          default = [ cfg.config.base46.theme cfg.config.base46.second_theme ];
        };
        inherit (generated.Base46Config.getSubOptions []) hl_add hl_override integrations changed_themes;
        transparency = mkEnableOption "enable transparency";
      };
      ui.cmp = {
        icons_left = mkEnableOption "Only has effect when the style  is default";
        icons = mkEnableOption "Whether to add colors to icons in nvim-cmp popup menu";
        lspkind_text = mkEnableOption "Whether to also the lsp kind highlighted with the icon as well or not" // { default = true; };
        style = mkOption {
          type = types.enum [ "default" "flat_light" "flat_dark" "atom" "atom_colored" ];
          description = "nvim-cmp style";
          default = "default";
        };
        format_colors.icon =  mkOption {
          type = types.str;
          description = "Icon to use for color swatches";
          default = "󱓻";
        };
        format_colors.tailwind = mkEnableOption "Show colors from tailwind/css/astro in lsp menu";
      };
      ui.telescope.style = mkOption {
        type = types.enum [ "borderless" "bordered" ];
        description = "Telescope style";
        default = "borderless";
      };
      ui.statusline = {
        enabled = mkEnableOption "enable statusline" // { default = true; };
        theme = mkOption {
          type = types.enum [ "default" "vscode" "vscode_colored" "minimal" ];
          description = "Statusline theme";
          default = "default";
        };
        separator_style = mkOption {
          type = types.enum [ "default" "round" "block" "arrow" ];
          default = "default";
          description = "separators work only for default statusline theme round and block will work for minimal theme only";
        };
        order = mkOption {
          type = with types; nullOr (listOf str);
          description = "The list of module names from default modules + your modules";
          default = null;
        };
        modules = mkOption {
          type = types.anything; # TODO function that return string, nill, or string
          default.__raw = "nil";
        };
      };
      ui.tabufline = {
        enabled = mkEnableOption "enable tabufline" // { default = true; };
        lazyload = mkEnableOption "lazyload it when there are 1+ buffers" // { default = true; };
        order = mkOption {
          type = with types; listOf (oneOf [ (enum [ "treeOffset" "buffers" "tabs" "btns" ]) str ]);
          default = [ "treeOffset" "buffers" "tabs" "btns" ];
          description = "The order is a list of module names from default modules + your modules";
        };
        modules = mkOption {
          type = types.anything; # TODO function that return string, nill, or string
          default.__raw = "nil";
        };
      };
      nvdash = {
        load_on_startup = mkEnableOption "enable nvdash" // { default = true; };
        header = mkOption {
          type = with types; listOf str;
          description = "header nvdash";
          default = [
            "                            "
            "     ▄▄         ▄ ▄▄▄▄▄▄▄   "
            "   ▄▀███▄     ▄██ █████▀    "
            "   ██▄▀███▄   ███           "
            "   ███  ▀███▄ ███           "
            "   ███    ▀██ ███           "
            "   ███      ▀ ███           "
            "   ▀██ █████▄▀█▀▄██████▄    "
            "     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   "
            "                            "
            "     Powered By  eovim    "
            "                            "
          ];
        };

        buttons = mkOption {
          type = with types; listOf
            (oneOf [
              (attrsOf anything)
              (types.submodule {
                options = {
                  txt = lib.mkOption {
                    type = str; # TODO str or raw that a function return a string
                    description = "Description of the buttons";
                  };
                  hl = lib.mkOption {
                    type = nullOr str;
                    default = null;
                    description = "Name of the highlight group";
                  };
                  rep = lib.mkEnableOption "Used to repeat txt till space available, use only when txt is 1 char";
                  no_gap = lib.mkEnableOption "Wont make next line empty" // { default = true; };
                };
              })
            ])
          ;
          default = [
            { txt = "  Find File"; keys = "ff"; cmd = "Telescope find_files"; }
            { txt = "  Recent Files"; keys = "f"+"o"; cmd = "Telescope oldfiles"; }
            { txt = "󰈭  Find Word"; keys = "fw"; cmd = "Telescope live_grep"; }
            { txt = "󱥚  Themes"; keys = "th"; cmd = ":lua require('nvchad.themes').open()"; }
            { txt = "  Mappings"; keys = "ch"; cmd = "NvCheatsheet"; }
          ];
        };
      };
      term = {
        winopts = mkOption {
          type = with types; attrsOf anything;
          default = {
            number = false;
            relativenumber = false;
          };
        };
        sizes = {
          sp = mkFloatOption "" 0.3;
          vsp = mkFloatOption "" 0.2;
          "bo sp" = mkFloatOption "" 0.3;
          "bo vsp" = mkFloatOption "" 0.2;
        };
        float = {
          relative =  mkStrOption "" "editor";
          row = mkFloatOption "" 0.3;
          col = mkFloatOption "" 0.25;
          width = mkFloatOption "" 0.5;
          height = mkFloatOption "" 0.4;
          border = mkStrOption "" "single";
        };
      };
      lsp.signature = mkEnableOption "Showing LSP function signature as you type" // { default = true; };
      cheatsheet = {
        theme = mkOption {
          type = types.enum [ "simple" "grid" ];
          default = "grid";
        };
        excluded_groups = mkOption {
          type = with types; listOf str;
          default = [ "terminal (t)" "autopairs" "Nvim" "Opens" ];
          description = "can add group name or with mode";
        };
      };
      # mason.pkgs = mkOption {
      #   description = "list of installed package by mason";
      #   type = with types; listOf str;
      #   default = [];
      # };
      # mason.command = mkEnableOption "";
      colorify = {
        enabled = mkEnableOption "enable colorify" // { default = true; };
        mode = mkOption {
          type = types.enum [ "fg" "bg" "virtual" ];
          default = "virtual";
        };
        virt_text = mkStrOption "" "󱓻 ";
        highlight.hex = mkEnableOption "" // { default = true; };
        highlight.lspvars = mkEnableOption "" // { default = true; };
      };
    };
  };
}
