{ lib, inputs, ... }: let
  generator = { name ? "", args ? [], lua ? "", ... }: ''
    function${lib.optionalString (lib.trim name != "") " ${name}"}(${lib.concatStringsSep ", " args})
    ${lib.fmway.addIndent "  " (lib.trim lua)}
    end
  '';
  template = luainline: name: x: let
    toRes = __raw: if luainline then { inherit __raw; } else __raw;
  in if lib.isList x then
    lua: toRes (generator { inherit name lua; args = x; })
  else toRes (generator { inherit name; args = []; lua = x; });
  op = {
    keymap' = key: action: x:
      if lib.isString x then modFn (op.keymap' key action) (r: r // {
        desc = r.desc or x;
      }) else lib.nixvim.toLuaObject {
          __raw = lib.nixvim.listToUnkeyedAttrs [ key action ] // x;
      };
    keymap = key: action: x:
      if lib.isString x then modFn (op.keymap key action) (r: r // {
        options = r.options or {} // { desc = r.options.desc or x; };
      }) else {
        inherit key action;
        mode = x.mode or "n";
        options = removeAttrs x [ "mode" ];
      };
  };
  isFunction = x: builtins.isFunction x || x ? __functor;
  modFn = fn: fn': x: let
    r = fn x;
  in if isFunction r then modFn r fn' else fn' r;
  mkFn = list: m: fn: lib.listToAttrs (map (x: let
    exc = lib.filter (y: x != y) list;
    m' = m ++ [x];
  in {
    name = x;
    value = let
      f = modFn fn (res: res // {
        mode = m';
      });
      f' = {
        __functor = _: f;
      } // mkFn exc m' fn;
    in if exc == [] then f else f';
  }) list);
  modes = [ "n" "v" "i" "t" "x" ];
  setsMap = lib.listToAttrs (lib.mapAttrsToList (name: fn: {
    inherit name;
    value = mkFn modes [] op.${name} // {
      __functor = _: setsMap.${name}.n;
    };
  }) op);
in {
  nixvim = inputs.nixvim.lib.nixvim.extend (self: super: setsMap // {
    mkLuaFn' = template false;
    mkLuaFn = self.mkLuaFn' "";
    mkRawFn' = template true;
    mkRawFn = self.mkRawFn' "";
    toLuaObject' = x: if isNull x then "" else self.toLuaObject x;
  });
}
