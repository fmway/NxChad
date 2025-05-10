{
  plugins.conform-nvim = {
    enable = true;
    settings.formatters_by_ft = {
      lua = [ "stylua" ];
    };
  };
}
