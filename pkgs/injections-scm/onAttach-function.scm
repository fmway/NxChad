; to lua type if keys is onAttach.function
(binding
  attrpath: (attrpath
    (identifier) @namespace
    (identifier) @name)
  expression: [
    (string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "lua")))
    (indented_string_expression
      ((string_fragment) @injection.content
        (#set! injection.language "lua")))
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
  (#match? @namespace "^onAttach$")
  (#match? @name "^function$"))

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
            (string_expression
              ((string_fragment) @injection.content
                (#set! injection.language "lua")))
            (indented_string_expression
              ((string_fragment) @injection.content
                (#set! injection.language "lua")))
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
          (#match? @_nested_path "^function$"))))
  ]
  (#match? @_path "^onAttach$"))
