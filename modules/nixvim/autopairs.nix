{
  plugins.nvim-autopairs = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "InsertEnter";
    settings = {
      disable_filetype = [
        "TelescopePrompt"
        "vim"
      ];
      fast_wrap = {};
    };
  };
}
