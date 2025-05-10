{ lib, ... }: let
  Base46Config = lib.types.submodule {
    options = {
      hl_add = lib.mkOption {
        description = ''
          List of highlights group to add.
          Should be highlights that is not a part of base46 default integrations
          (The default is all hlgroup that can be found from `hl_override`)
          see https://github.com/NvChad/base46/tree/master/lua/base46/integrations
        '';
        type = lib.types.nullOr HLTable;
        example = lib.literalExpression /* nix */ ''
          {
            "HLName" = { fg = "red"; };
          }
        '';
        default = null;
      };
      hl_override = lib.mkOption {
        description = ''
          List of highlight groups that is part of base46 default integration that you want to change
          see https://github.com/NvChad/base46/tree/master/lua/base46/integrations
        '';
        type = lib.types.nullOr Base46HLGroupsList;
        example = lib.literalExpression /* nix */ ''
          {
            "HLName" = { fg = "red"; };
          }
        '';
        default = null;
      };
      changed_themes = lib.mkOption {
        description = ''
          see https://github.com/NvChad/base46/tree/master/lua/base46/themes for the colors of each theme
          Also accept a special key `all` to change a base46 key to a specific color for all themes
        '';
        type = lib.types.nullOr ChangedTheme;
        default = null;
      };
      theme_toggle = lib.mkOption {
        description = "";
        # TODO only two selected
        type = with lib.types; nullOr (listOf ThemeName);
        example = lib.literalExpression /* nix */ ''
          [ "onedark" "one_light" ]
        '';
        default = null;
      };
      transparency = lib.mkOption {
        description = "Enable transparency or not";
        type = with lib.types; nullOr bool;
        default = null;
      };
      # TODO
      theme = lib.mkOption {
        description = ''
          Theme to use.
          You can try out the theme by executing `:Telescope themes`
          see https://github.com/NvChad/base46/tree/master/lua/base46/themes
        '';
        type = with lib.types; nullOr ThemeName;
        default = null;
      };
      integrations = mkNulled "" (lib.types.listOf Base46Integrations);
    };
  };
  UIConfig = lib.types.submodule {
    options = {
      cmp = mkNulled ''
        Whether to enable LSP Semantic Tokens highlighting
        List of extras themes for other plugins not in NvChad that you want to compile

        Options for stylings of nvim-cmp
      '' NvCmpConfig;
      telescope = mkNulled "" NvTelescopeConfig;
      statusline = mkNulled "" NvStatusLineConfig;
      tabufline = mkNulled ''
        Maximum length for the progress messages section
        Options for NvChad Tabufline
      '' NvTabLineConfig;
    };
  };
  NvLspConfig = lib.types.submodule {
    options.signature = mkNulled "showing LSP function signatures as you type" lib.types.bool;
  };
  TermConfig = lib.types.submodule {
    options = {
      base46_colors = mkNulled "" lib.types.bool;
      winopts = mkNulled "" lib.types.attrs;
      sizes = mkNulled "" TermSizes;
      float = mkNulled "" TermFloat;
    };
  };
  NvCheatsheetConfig = lib.types.submodule {
    options = {
      theme = mkNulled "Cheatseet theme" (lib.types.enum [ "grid" "simple" ]);
      excluded_groups = mkNulled "" (with lib.types; listOf str);
    };
  };
  MasonConfig = lib.types.submodule {
    options = with lib.types; {
      command = mkNulled "" bool;
      pkgs = mkNulled "" (listOf str);
    };
  };
  ColorifyConfig = lib.types.submodule {
    options = with lib.types; {
      enabled = mkNulled "" bool;
      mode = mkNulled "" (enum [ "fg" "bg" "virtual" ]);
      virt_text = mkNulled "" str;
      highlight = mkNulled "" ColorifyHL;
    };
  };
  ColorifyHL = lib.types.submodule {
    options = with lib.types; {
      hex = mkNulled "" bool;
      lspvars = mkNulled "" bool;
    };
  };
  NvDashConfig = lib.types.submodule {
    options = {
      load_on_startup = mkNulled "Whether to open dashboard on opening nvim" lib.types.bool;
      # TODO fun lua => str
      header = mkNulled ''
        Your ascii art
        Each str is one line
      '' (with lib.types; listOf str);
      buttons = mkNulled "List of buttons to show on the dashboard" (lib.types.listOf NvDashButtonConfig);
    };
  };
  NvDashButtonConfig = lib.types.submodule { options = {
    txt = mkNulled "Description of the button" lib.types.str; # TODO fun lua => str
    hl = mkNulled "name of the highlight group" lib.types.str;
    no_gap = mkNulled "true by default, this wont make next line empty" lib.types.bool;
    rep = mkNulled "used to repeat txt till space available, use only when txt is 1 char" lib.types.bool;
  }; };
  HLTable = lib.types.attrsOf Base46HLGroups;
  Base46HLGroups = with lib.types; submodule {
    options = {
      fg = mkNulled ''
        Color name or Hex code of foreground
        if fg is "NONE", remove the foreground color
        '' (oneOf [ str (enum [ "NONE" ]) MixedColor Base46Colors ]);
      bg = mkNulled ''
        Color name or Hex code of background
        if fg is "NONE", remove the background color
        '' (oneOf [ str (enum [ "NONE" ]) MixedColor Base46Colors ]);
      sp = mkNulled ''
        Color name or hex code that will be used for underline colors
        - If sp is `NONE`, use transparent color for special
        - If sp is `bg` or `background`, use normal background color
        - If sp is `fg` or `foreground`, use normal foreground color
        See :h guisp for more information
      '' (oneOf [ str MixedColor Base46Colors (enum [ "NONE" "bg" "background" "foreground" ]) ]);
      blend = mkNulled ''
        integer between 0 and 100, level of opacity
        Only applied for floating windows, popupmenu
        Check `:h highlight-blend` for more information'' int;
      bold = mkNulled "bolded text or not" bool;
      standout = mkNulled "decorations" bool;
      underline = mkNulled "decorations" bool;
      undercurl = mkNulled "decorations" bool;
      underdouble = mkNulled "decorations" bool;
      underdotted = mkNulled "" bool;
      underdashed = mkNulled "" bool;
      strikethrough = mkNulled "" bool;
      italic = mkNulled "italicized text" bool;
      reverse = mkNulled "" bool;
      nocombine = mkNulled "" bool;
      link = mkNulled ''
        name of another highlight group to link to, see `:h hi-link` for more information.
        When this is not null, all attributes will be overridden if the linked group has such attribute defined
        To unlink a hlgroup, do `link = "NONE"`
      '' (oneOf [(enum [ "NONE" ]) str]);
      default = mkNulled "Don't override existing definition if true" bool;
      ctermfg = mkNulled "Sets foreground of cterm color" number;
      ctermbg = mkNulled "Sets background of cterm color" number;
      cterm = mkNulled "comma-separated list of cterm opts. For more information, check `:h highlight-args`" str;
    };
  };
  Base46Colors = lib.types.enum (Base30Colors ++ Base16Colors);
  Base30Colors = [
    "white"
    "darker_black"
    "black"
    "black2"
    "one_bg"
    "one_bg2"
    "one_bg3"
    "grey"
    "grey_fg"
    "grey_fg2"
    "light_grey"
    "red"
    "baby_pink"
    "pink"
    "line"
    "green"
    "vibrant_green"
    "blue"
    "nord_blue"
    "yellow"
    "sun"
    "purple"
    "dark_purple"
    "teal"
    "orange"
    "cyan"
    "statusline_bg"
    "lightbg"
    "pmenu_bg"
    "folder_bg"
  ];
  Base16Colors = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  # TODO tuple
  MixedColor = with lib.types; listOf (oneOf [ Base46Colors Base46Colors int ]);
  all_hl_groups = import ./all_hl_groups.nix { inherit Base46HLGroups lib mkNulled mkNoNulled; };
  inherit (all_hl_groups) Base46HLGroupsList Base46Integrations;
  ChangedTheme = lib.types.submodule {
    options = {
      all = mkNoNulled "changes for all themes. Has lower precedence than theme-specific changes" ThemeTable;
      aquarium = mkNulled "Changes for aquarium theme" ThemeTable;
      ashes = mkNulled "Changes for ashes theme" ThemeTable;
      aylin = mkNulled "Changes for aylin theme" ThemeTable;
      ayu_dark = mkNulled "Changes for ayu_dark theme" ThemeTable;
      ayu_light = mkNulled "Changes for ayu_light theme" ThemeTable;
      bearded-arc = mkNulled "Changes for bearded-arc theme" ThemeTable;
      blossom_light = mkNulled "Changes for blossom_light theme" ThemeTable;
      carbonfox = mkNulled "Changes for carbonfox theme" ThemeTable;
      catppuccin = mkNulled "Changes for catppuccin theme" ThemeTable;
      chadracula-evondev = mkNulled "Changes for chadracula-evondev theme" ThemeTable;
      chadracula = mkNulled "Changes for chadracula theme" ThemeTable;
      chadtain = mkNulled "Changes for chadtain theme" ThemeTable;
      chocolate = mkNulled "Changes for chocolate theme" ThemeTable;
      darcula-dark = mkNulled "Changes for darcula-dark theme" ThemeTable;
      dark_horizon = mkNulled "Changes for dark_horizon theme" ThemeTable;
      decay = mkNulled "Changes for decay theme" ThemeTable;
      default-dark = mkNulled "Changes for default-dark theme" ThemeTable;
      default-light = mkNulled "Changes for default-light theme" ThemeTable;
      doomchad = mkNulled "Changes for doomchad theme" ThemeTable;
      eldritch = mkNulled "Changes for eldritch theme" ThemeTable;
      embark = mkNulled "Changes for embark theme" ThemeTable;
      everblush = mkNulled "Changes for everblush theme" ThemeTable;
      everforest = mkNulled "Changes for everforest theme" ThemeTable;
      everforest_light = mkNulled "Changes for everforest_light theme" ThemeTable;
      falcon = mkNulled "Changes for falcon theme" ThemeTable;
      flex-light = mkNulled "Changes for flex-light theme" ThemeTable;
      flexoki-light = mkNulled "Changes for flexoki-light theme" ThemeTable;
      flexoki = mkNulled "Changes for flexoki theme" ThemeTable;
      flouromachine = mkNulled "Changes for flouromachine theme" ThemeTable;
      gatekeeper = mkNulled "Changes for gatekeeper theme" ThemeTable;
      github_dark = mkNulled "Changes for github_dark theme" ThemeTable;
      github_light = mkNulled "Changes for github_light theme" ThemeTable;
      gruvbox = mkNulled "Changes for gruvbox theme" ThemeTable;
      gruvbox_light = mkNulled "Changes for gruvbox_light theme" ThemeTable;
      gruvchad = mkNulled "Changes for gruvchad theme" ThemeTable;
      hiberbee = mkNulled "Changes for hiberbee theme" ThemeTable;
      horizon = mkNulled "Changes for horizon theme" ThemeTable;
      jabuti = mkNulled "Changes for jabuti theme" ThemeTable;
      jellybeans = mkNulled "Changes for jellybeans theme" ThemeTable;
      kanagawa-dragon = mkNulled "Changes for kanagawa-dragon theme" ThemeTable;
      kanagawa = mkNulled "Changes for kanagawa theme" ThemeTable;
      material-darker = mkNulled "Changes for material-darker theme" ThemeTable;
      material-deep-ocean = mkNulled "Changes for material-deep-ocean theme" ThemeTable;
      material-lighter = mkNulled "Changes for material-lighter theme" ThemeTable;
      melange = mkNulled "Changes for melange theme" ThemeTable;
      mito-laser = mkNulled "Changes for mito-laser theme" ThemeTable;
      monekai = mkNulled "Changes for monekai theme" ThemeTable;
      monochrome = mkNulled "Changes for monochrome theme" ThemeTable;
      mountain = mkNulled "Changes for mountain theme" ThemeTable;
      nano-light = mkNulled "Changes for nano-light theme" ThemeTable;
      neofusion = mkNulled "Changes for neofusion theme" ThemeTable;
      nightfox = mkNulled "Changes for nightfox theme" ThemeTable;
      nightlamp = mkNulled "Changes for nightlamp theme" ThemeTable;
      nightowl = mkNulled "Changes for nightowl theme" ThemeTable;
      nord = mkNulled "Changes for nord theme" ThemeTable;
      obsidian-ember = mkNulled "Changes for obsidian-ember theme" ThemeTable;
      oceanic-light = mkNulled "Changes for oceanic-light theme" ThemeTable;
      oceanic-next = mkNulled "Changes for oceanic-next theme" ThemeTable;
      one_light = mkNulled "Changes for one_light theme" ThemeTable;
      onedark = mkNulled "Changes for onedark theme" ThemeTable;
      onenord = mkNulled "Changes for onenord theme" ThemeTable;
      onenord_light = mkNulled "Changes for onenord_light theme" ThemeTable;
      oxocarbon = mkNulled "Changes for oxocarbon theme" ThemeTable;
      palenight = mkNulled "Changes for palenight theme" ThemeTable;
      pastelDark = mkNulled "Changes for pastelDark theme" ThemeTable;
      pastelbeans = mkNulled "Changes for pastelbeans theme" ThemeTable;
      penumbra_dark = mkNulled "Changes for penumbra_dark theme" ThemeTable;
      penumbra_light = mkNulled "Changes for penumbra_light theme" ThemeTable;
      poimandres = mkNulled "Changes for poimandres theme" ThemeTable;
      radium = mkNulled "Changes for radium theme" ThemeTable;
      rosepine-dawn = mkNulled "Changes for rosepine-dawn theme" ThemeTable;
      rosepine = mkNulled "Changes for rosepine theme" ThemeTable;
      rxyhn = mkNulled "Changes for rxyhn theme" ThemeTable;
      scaryforest = mkNulled "Changes for scaryforest theme" ThemeTable;
      seoul256_dark = mkNulled "Changes for seoul256_dark theme" ThemeTable;
      seoul256_light = mkNulled "Changes for seoul256_light theme" ThemeTable;
      solarized_dark = mkNulled "Changes for solarized_dark theme" ThemeTable;
      solarized_light = mkNulled "Changes for solarized_light theme" ThemeTable;
      solarized_osaka = mkNulled "Changes for solarized_osaka theme" ThemeTable;
      starlight = mkNulled "Changes for starlight theme" ThemeTable;
      sweetpastel = mkNulled "Changes for sweetpastel theme" ThemeTable;
      tokyodark = mkNulled "Changes for tokyodark theme" ThemeTable;
      tokyonight = mkNulled "Changes for tokyonight theme" ThemeTable;
      tomorrow_night = mkNulled "Changes for tomorrow_night theme" ThemeTable;
      tundra = mkNulled "Changes for tundra theme" ThemeTable;
      vesper = mkNulled "Changes for vesper theme" ThemeTable;
      vscode_dark = mkNulled "Changes for vscode_dark theme" ThemeTable;
      vscode_light = mkNulled "Changes for vscode_light theme" ThemeTable;
      wombat = mkNulled "Changes for wombat theme" ThemeTable;
      yoru = mkNulled "Changes for yoru theme" ThemeTable;
      zenburn = mkNulled "Changes for zenburn theme" ThemeTable;
    };
  };
  NvCmpConfig = lib.types.submodule {
    options = {
      icons = lib.mkOption {
        description = "Whether to add colors to icons in nvim-cmp popup menu";
        type = with lib.types; nullOr bool;
        default = null;
      };
      style = lib.mkOption {
        description = "Whether to also have the lsp kind highlighted with the icons as well or not nvim-cmp style";
        type = with lib.types; nullOr (enum ["default" "flat_light" "flat_dark" "atom" "atom_colored"]);
        default = null;
      };
      abbr_maxwidth = lib.mkOption {
        description = "Only has effects when the style is `default` Max width of main completion text in cmp";
        type = with lib.types; nullOr int;
        default = null;
      };
      icons_left = mkNulled ""  lib.types.bool;
      format_colors = lib.mkOption {
        description = "places lspkind icons to the left, only for non-atom styles";
        type = lib.types.nullOr NvCmpFormatColors;
      };
    };
  };
  NvTelescopeConfig = lib.types.submodule {
    options = {
      style = lib.mkOption {
        description = "Telescope style";
        type = with lib.types; nullOr (enum [ "borderless" "bordered" ]);
        default = null;
      };
    };
  };
  NvStatusLineConfig = lib.types.submodule {
    options = {
      enabled = mkNulled "" lib.types.bool;
      theme = lib.mkOption {
        description = "statusline theme";
        type = with lib.types; nullOr (enum [ "default" "vscode" "vscode_colored" "minimal" ]);
        default = null;
      };
      separator_style = lib.mkOption {
        description = "Separator style for NvChad statusline (only when `theme` is `minimal`, `round`, or `block` will be having effect)";
        type = with lib.types; nullOr (enum ["default" "round" "block" "arrow" ]);
      };
      order = lib.mkOption {
        description = ''
          The list of module names from default modules + your modules
          Check https://github.com/NvChad/ui/blob/v2.5/lua/nvchad/stl/utils.lua#L12 for the modules of each statusline theme
        '';
        type = with lib.types; nullOr str;
        default = null;
      };
      # TODO fun lua => str
      modules = lib.mkOption {
        description = "Your modules to be added to the statusline";
        type = with lib.types; nullOr (attrsOf str);
        example = lib.literalExpression /* nix */ ''
          abc.__raw = "function() return 'hi' end"
        '';
        default = null;
      };
    };
  };
  NvTabLineConfig = lib.types.submodule {
    options = {
      enabled = mkNulled "Whether to use/load tabufline or not" lib.types.bool;
      # TODO
      lazyload = mkNulled ''
        If false, load tabufline on startup
        If true, load tabufline when there is at least 2 buffers opened
      '' lib.types.bool;
      bufwidth = mkNulled "" lib.types.int;
      # TODO check module
      order = mkNulled "The order is a list of module names from default modules + your modules" (with lib.types; listOf (oneOf [(enum [ "treeOffset" "buffers" "tabs" "btns" ])]));
      # TODO fun lua => str
      modules = lib.mkOption {
        description = "Your modules to be added to the statusline";
        type = with lib.types; nullOr (attrsOf str);
        example = lib.literalExpression /* nix */ ''
          abc.__raw = "function() return 'hi' end"
        '';
        default = null;
      };
    };
  };
  TermSizes = lib.types.submodule {
    options = {
      sp = mkNulled "" lib.types.int;
      vsp = mkNulled "" lib.types.int;
      "bo sp" = mkNulled "" lib.types.int;
      "bo vsp" = mkNulled "" lib.types.int;
    };
  };
  TermFloat = lib.types.submodule {
    options = with lib.types; {
      relative = mkNulled "" str;
      row = mkNulled "" int;
      col = mkNulled "" int;
      width = mkNulled "" int;
      height = mkNulled "" int;
      border = mkNulled "" str;
    };
  };
  ThemeName = lib.types.enum [
    "zenburn"
    "yoru"
    "wombat"
    "vscode_light"
    "vscode_dark"
    "vesper"
    "tundra"
    "tomorrow_night"
    "tokyonight"
    "tokyodark"
    "sweetpastel"
    "starlight"
    "solarized_osaka"
    "solarized_light"
    "solarized_dark"
    "seoul256_light"
    "seoul256_dark"
    "scaryforest"
    "rxyhn"
    "rosepine"
    "rosepine-dawn"
    "radium"
    "poimandres"
    "penumbra_light"
    "penumbra_dark"
    "pastelbeans"
    "pastelDark"
    "palenight"
    "oxocarbon"
    "onenord_light"
    "onenord"
    "onedark"
    "one_light"
    "oceanic-next"
    "oceanic-light"
    "obsidian-ember"
    "nord"
    "nightowl"
    "nightlamp"
    "nightfox"
    "neofusion"
    "nano-light"
    "mountain"
    "monochrome"
    "monekai"
    "mito-laser"
    "melange"
    "material-lighter"
    "material-deep-ocean"
    "material-darker"
    "kanagawa"
    "kanagawa-dragon"
    "jellybeans"
    "jabuti"
    "horizon"
    "hiberbee"
    "gruvchad"
    "gruvbox_light"
    "gruvbox"
    "github_light"
    "github_dark"
    "gatekeeper"
    "flouromachine"
    "flexoki"
    "flexoki-light"
    "flex-light"
    "falcon"
    "everforest_light"
    "everforest"
    "everblush"
    "embark"
    "eldritch"
    "doomchad"
    "default-light"
    "default-dark"
    "decay"
    "dark_horizon"
    "darcula-dark"
    "chocolate"
    "chadtain"
    "chadracula"
    "chadracula-evondev"
    "catppuccin"
    "carbonfox"
    "blossom_light"
    "bearded-arc"
    "ayu_light"
    "ayu_dark"
    "aylin"
    "ashes"
    "aquarium"
  ];
  Base16Table = with lib.types; submodule {
    options = {
      base00 = mkNoNulled "Neovim Default Background" str;
      base01 = mkNoNulled "Lighter Background (Used for status bars, line number and folding marks)" str;
      base02 = mkNoNulled "Selection Background (Visual Mode)" str;
      base03 = mkNoNulled "Comments, Invisibles, Line Highlighting, Special Keys, Sings, Fold bg" str;
      base04 = mkNoNulled "Dark Foreground, Dnf Underline (Used for status bars)" str;
      base05 = mkNoNulled "Default Foreground (for text), Var, References Caret, Delimiters, Operators" str;
      base06 = mkNoNulled "Light Foreground (Not often used)" str;
      base07 = mkNoNulled "Light Foreground, Cmp Icons (Not often used)" str;
      base08 = mkNoNulled "Variables, Identifiers, Filed, Name Space, Error, Spell XML Tags, Markup Link Text, Markup Lists, Diff Deleted" str;
      base09 = mkNoNulled "Integers, bool, Constants, XML Attributes, Markup Link Url, Inc Search" str;
      base0A = mkNoNulled "Classes, Attribute, Type, Repeat, Tag, Todo, Markup Bold, Search Text Background" str;
      base0B = mkNoNulled "strs, Symbols, Inherited Class, Markup Code, Diff Inserted" str;
      base0C = mkNoNulled "Constructor,Special, Fold Column, Support, Regular Expressions, Escape Characters, Markup Quotes" str;
      base0D = mkNoNulled "Functions, Methods, Attribute IDs, Headings" str;
      base0E = mkNoNulled "Keywords, Storage, Selector, Markup Italic, Diff Changed" str;
      base0F = mkNoNulled "Delimiters, Special Char, Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>" str;
    };
  };
  Base30Table = with lib.types; submodule {
    options = {
      white = mkNoNulled "" str;
      darker_black = mkNoNulled "LSP/CMP Pop-ups, Tree BG" str;
      black = mkNoNulled "CMP BG, Icons/Headers FG" str;
      black2 = mkNoNulled "Tabline BG, Cursor Lines, Selections" str;
      one_bg = mkNoNulled "Pop-up Menu BG, Statusline Icon FG" str;
      one_bg2 = mkNoNulled "Tabline Inactive BG, Indent Line Context Start" str;
      one_bg3 = mkNoNulled "Tabline Toggle/New Btn, Borders" str;
      grey = mkNoNulled "Line Nr, Scrollbar, Indent Line Hover" str;
      grey_fg = mkNoNulled "Comment" str;
      grey_fg2 = mkNoNulled "Unused" str;
      light_grey = mkNoNulled "Diff Change, Tabline Inactive FG" str;
      red = mkNoNulled "Diff Delete, Diag Error" str;
      baby_pink = mkNoNulled "Some Dev Icons" str;
      pink = mkNoNulled "Indicators" str;
      line = mkNoNulled "Win Sep, Indent Line" str;
      green = mkNoNulled "Diff Add, Diag Info, Indicators" str;
      vibrant_green = mkNoNulled "Some Dev Icons" str;
      blue = mkNoNulled "UI Elements, Dev/CMP Icons" str;
      nord_blue = mkNoNulled "Indicators" str;
      yellow = mkNoNulled "Diag Warn" str;
      sun = mkNoNulled "Dev Icons" str;
      purple = mkNoNulled "Diag Hint, Dev/CMP Icons" str;
      dark_purple = mkNoNulled "Some Dev Icons" str;
      teal = mkNoNulled "Dev/CMP Icons" str;
      orange = mkNoNulled "Diff Mod" str;
      cyan = mkNoNulled "Dev/CMP Icons" str;
      statusline_bg = mkNoNulled "Statusline" str;
      lightbg = mkNoNulled "Statusline Components" str;
      pmenu_bg = mkNoNulled "Pop-up Menu Selection" str;
      folder_bg = mkNoNulled "Nvimtree Items" str;
    };
  };
  ThemeTable = with lib.types; submodule {
    options = {
      base_16 = mkNoNulled "base00-base0F colors" Base16Table;
      base_30 = mkNoNulled "extra colors to use" Base30Table;
    };
  };
  Base46Table = with lib.types; submodule {
    options = {
      base_16 = mkNoNulled "base00-base0F colors" Base16Table;
      base_30 = mkNoNulled "extra colors to use" Base30Table;
      add_hl = mkNoNulled "" HLTable;
      polish_hl = mkNoNulled "highlight groups to be changed from the default color" HLTable;
      type = mkNoNulled "Denoting value to set for `vim.opt.bg`" (enum ["dark" "light"]);
    };
  };
  
  NvCmpFormatColors = with lib.types; submodule {
    options = {
      icon = mkNulled "icon to use for color swatches" str;
      lsp = mkNulled "show colors from tailwind/css/astro lsp in menu" bool;
    };
  };
  mkNulled = description: type: mkNoNulled description (lib.types.nullOr type);
  mkNoNulled = description: type: lib.mkOption {
    inherit type;
    default = null;
  } // lib.optionalAttrs (description != "") {
    inherit description;
  };
in {
  inherit Base46Config ThemeName;
  # options.nvchad.enable = lib.mkEnableOption "Enable NvChad" // { default = true; };
  # options.nvchad.config = {
  #   ui = mkNulled ''
  #     UI related configuration
  #     e.g. statusline, cmp themes, dashboard
  #   '' UIConfig;
  #   base46 = mkNulled "" Base46Config;
  #   lsp = mkNulled "Options for NvChad/ui lsp configuration" NvLspConfig;
  #   term = mkNulled "" TermConfig;
  #   cheatsheet = mkNulled "" NvCheatsheetConfig;
  #   mason = mkNulled "" MasonConfig;
  #   colorify = mkNulled "" ColorifyConfig;
  #   nvdash = mkNulled "" NvDashConfig;
  # };
}
