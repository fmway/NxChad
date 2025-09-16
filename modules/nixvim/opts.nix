{
  _file = ./opts.nix;

  opts = {
    laststatus = 3;
    showmode = false;
    splitkeep = "screen";
    cursorlineopt = "number";
    cursorline = true;
    clipboard = "unnamedplus";

    expandtab = true;
    shiftwidth = 2;
    smartindent = true;
    cindent = true;
    breakindent = true;
    tabstop = 2;
    softtabstop = 2;

    number = true;
    mouse = "a";
    ignorecase = true;
    smartcase = true;
    fillchars.eob = " ";
    numberwidth = 2;
    ruler = false;
    # relativenumber = true;

    signcolumn = "yes";
    splitbelow = true;
    splitright = true;
    timeoutlen = 400;
    undofile = true;

    updatetime = 250;
  };

  globals.mapleader = " ";

  # disable some default providers
  globals.loaded_node_provider = 0;
  globals.loaded_python3_provider = 0;
  globals.loaded_perl_provider = 0;
  globals.loaded_ruby_provider = 0;
}
