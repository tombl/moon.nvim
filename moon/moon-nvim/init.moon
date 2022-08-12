import lint_code from require "moonscript.cmd.lint"
null_ls = require "null-ls"

setup = (options) ->
    globals = if options.globals == nil
        [key for key, _ in pairs _G]
    else
        options.globals
    globals = { name, true for name in *globals }
    with globals
        .nil = true
        .true = true
        .false = true

    null_ls.register
        name: "moon"
        method: null_ls.methods.DIAGNOSTICS
        filetypes: {"moon"}
        generator:
            fn: (params) ->
                lints, err = lint_code (table.concat params.content, "\n"), "", globals
                if err
                    row = tonumber err\match "\n %[(%d+)] >>"
                    {{
                        :row
                        source: "moon"
                        message: "Syntax error"
                        severity: vim.diagnostic.severity.ERROR
                    }}
                elseif lints
                    diagnostics = {}
                    for line in lints\gmatch "([^\n]*)\n?"
                        row, message = line\match "line (%d+): (.*)"
                        if row
                            row = tonumber row
                            if message\match "assigned but unused"
                                for var in message\gmatch "`([^`]*)`"
                                    col, end_col = params.content[row]\find var, 1, true
                                    table.insert diagnostics,
                                        :row
                                        :col
                                        end_col: end_col + 1
                                        message: string.format "assigned but unused `%s`", var
                                        source: "moon"
                                        severity: vim.diagnostic.severity.WARN
                            elseif var = message\match "accessing global `(.*)`"
                                col, end_col = params.content[row]\find var, 1, true
                                table.insert diagnostics,
                                    :row
                                    :col
                                    end_col: end_col + 1
                                    message: string.format "accessing global `%s`", var
                                    source: "moon"
                                    severity: vim.diagnostic.severity.WARN
                            else
                                table.insert diagnostics,
                                    :row
                                    :message
                                    source: "moon"
                                    severity: vim.diagnostic.severity.WARN
                    diagnostics
                else
                    {}

{ :setup }