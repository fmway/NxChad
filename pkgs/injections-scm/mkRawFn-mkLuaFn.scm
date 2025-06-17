(apply_expression
  (apply_expression
    function: ((_) @_func))
    argument: [
      (indented_string_expression (string_fragment) @injection.content)
      (string_expression (string_fragment) @injection.content)
    ]
  (#match? @_func "(^|\\.)(mkRawFn|mkLuaFn)$")
  (#set! injection.language "lua")
  (#set! injection.combined))

(apply_expression
  (apply_expression
    function: [
      ((_) @_func)
      (apply_expression
        function: ((_) @_func))
    ])
    argument: [
      (indented_string_expression (string_fragment) @injection.content)
      (string_expression (string_fragment) @injection.content)
    ]
  (#match? @_func "(^|\\.)(mkRawFn|mkLuaFn)[']$")
  (#set! injection.language "lua")
  (#set! injection.combined))
