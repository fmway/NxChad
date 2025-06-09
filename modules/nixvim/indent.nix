{
  plugins.indent-blankline = {
    enable = true;
    luaConfig.pre = ''
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    '';
    lazyLoad.enable = true;
    lazyLoad.settings = {
      event = "User FilePost";
      cmd = [ "IBLEnable" "IBLDisable" "IBLEnableScope" "IBLDisableScope" "IBLToggle" "IBLToggleScope" ];
    };
    settings = {
      indent = { char = "│"; highlight = "IblChar"; };
      scope = { char = "│"; highlight = "IblScopeChar"; };
    };
  };
}
