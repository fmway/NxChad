(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (apply_expression
      function: (_) @_func
      argument: [
        (string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "lua")))
        (indented_string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "lua")))
      ]
      (#match? @_func "(^|\\.)(mkBefore|mkAfter)$"))
  ]
  (#match? @_path "(^(extraConfigLua(Pre|Post)?|capabilities))$"))


(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (apply_expression
      function: (_) @_func
      argument: [
        (string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "vim")))
        (indented_string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "vim")))
      ]
      (#match? @_func "(^|\\.)(mkBefore|mkAfter)$"))
  ]
  (#match? @_path "(^extraConfigVim(Pre|Post)?)$"))

(binding
  attrpath: (attrpath
    (identifier) @namespace
    (identifier) @name)
  expression: [
    (apply_expression
      function: (_) @_func
      argument: [
        (string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "lua")))
        (indented_string_expression
          ((string_fragment) @injection.content
            (#set! injection.language "lua")))
      ]
      (#match? @_func "(^|\\.)(mkBefore|mkAfter)$"))
  ]
  (#match? @namespace "^luaConfig$")
  (#match? @name "^(pre|post|content)$"))

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (attrset_expression
      (binding_set
        (binding
          attrpath: (attrpath
            (identifier) @_nested_path)
          expression: [
            (apply_expression
              function: (_) @_func
              argument: [
                (string_expression
                  ((string_fragment) @injection.content
                    (#set! injection.language "lua")))
                (indented_string_expression
                  ((string_fragment) @injection.content
                    (#set! injection.language "lua")))
              ]
              (#match? @_func "(^|\\.)(mkBefore|mkAfter)$"))
          ]
          (#match? @_nested_path "^(pre|post|content)$"))))
  ]
  (#match? @_path "^luaConfig$"))
