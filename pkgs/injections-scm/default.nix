{ inputs
, from ? "${inputs.nixvim}/plugins/by-name/treesitter/injections.scm"
, result ? null
, writeText
, lib
}: let
  ctx =
    if lib.isPath from || lib.pathIsRegularFile from then
      builtins.readFile from
    else if lib.isString from then
      "${from}\n"
    else throw "(injections-scm)"
  ;

  res =
    # add mkRawFn, mkLuaFn highlight
    lib.replaceStrings ["mkRaw" "__raw"] ["(mkRaw|mkRawFn|mkLuaFn)" "__raw|capabilities"] ctx
  + lib.concatStrings (map builtins.readFile list-scm)
  ;

  list-scm = let
    folder = ./.;
    toPath = name: value: folder + "/${name}";
    filterNotDefault = key: value: value == "regular" && key != "default.nix";
  in lib.mapAttrsToList toPath (lib.filterAttrs filterNotDefault (builtins.readDir folder));

  finalResult =
    if isNull result then
      res
    else if lib.isString result then
      result
    else if lib.isFunction result then
      result res
    else "(injections-scm): unknown type ${builtins.typeOf result} in result"
  ;
in 
writeText "injections.scm" finalResult
