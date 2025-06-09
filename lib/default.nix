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
  toKeymaps = key: action: { ... } @ options:
    lib.pipe [ key action ] [
      lib.nixvim.listToUnkeyedAttrs
      (x: x // options)
      lib.nixvim.toLuaObject
      (__raw: { inherit __raw; })
    ];
  toKeymaps' =
    key: action: { mode ? "n", ... } @ options: {
      inherit key action mode;
      options = removeAttrs options [ "mode" ];
    };
  genToKeymaps' = lib.listToAttrs (map (x: {
    name = "${x}Keymap'";
    value = a: b: desc:
      toKeymaps' a b {
        mode = lib.stringToCharacters x;
        inherit desc;
      };
  }) (lib.splices [ "n" "v" "i" "t" "x" ]));
in {
  nixvim = inputs.nixvim.lib.nixvim.extend (self: super: {
    mkLuaFn' = template false;
    mkLuaFn = self.mkLuaFn' "";
    mkRawFn' = template true;
    mkRawFn = self.mkRawFn' "";
    inherit toKeymaps toKeymaps';
    toLuaObject' = x: if isNull x then "" else self.toLuaObject x;
  } // genToKeymaps');
  splices = arr:
    if arr == [] then []
    else
      lib.foldl' (acc: curr: let
        exclude = lib.filter (x: curr != x) arr;
      in acc ++ [
        curr
      ] ++ map (x: curr + x) (lib.splices exclude)) [] arr;
}
