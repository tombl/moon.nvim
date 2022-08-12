local lint_code
lint_code = require("moonscript.cmd.lint").lint_code
local null_ls = require("null-ls")
local setup
setup = function(options)
  local globals
  if options.globals == nil then
    do
      local _accum_0 = { }
      local _len_0 = 1
      for key, _ in pairs(_G) do
        _accum_0[_len_0] = key
        _len_0 = _len_0 + 1
      end
      globals = _accum_0
    end
  else
    globals = options.globals
  end
  do
    local _tbl_0 = { }
    for _index_0 = 1, #globals do
      local name = globals[_index_0]
      _tbl_0[name] = true
    end
    globals = _tbl_0
  end
  do
    globals["nil"] = true
    globals["true"] = true
    globals["false"] = true
  end
  return null_ls.register({
    name = "moon",
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = {
      "moon"
    },
    generator = {
      fn = function(params)
        local lints, err = lint_code((table.concat(params.content, "\n")), "", globals)
        if err then
          local row = tonumber(err:match("\n %[(%d+)] >>"))
          return {
            {
              row = row,
              source = "moon",
              message = "Syntax error",
              severity = vim.diagnostic.severity.ERROR
            }
          }
        elseif lints then
          local diagnostics = { }
          for line in lints:gmatch("([^\n]*)\n?") do
            local row, message = line:match("line (%d+): (.*)")
            if row then
              row = tonumber(row)
              if message:match("assigned but unused") then
                for var in message:gmatch("`([^`]*)`") do
                  local col, end_col = params.content[row]:find(var, 1, true)
                  table.insert(diagnostics, {
                    row = row,
                    col = col,
                    end_col = end_col + 1,
                    message = string.format("assigned but unused `%s`", var),
                    source = "moon",
                    severity = vim.diagnostic.severity.WARN
                  })
                end
              else
                do
                  local var = message:match("accessing global `(.*)`")
                  if var then
                    local col, end_col = params.content[row]:find(var, 1, true)
                    table.insert(diagnostics, {
                      row = row,
                      col = col,
                      end_col = end_col + 1,
                      message = string.format("accessing global `%s`", var),
                      source = "moon",
                      severity = vim.diagnostic.severity.WARN
                    })
                  else
                    table.insert(diagnostics, {
                      row = row,
                      message = message,
                      source = "moon",
                      severity = vim.diagnostic.severity.WARN
                    })
                  end
                end
              end
            end
          end
          return diagnostics
        else
          return { }
        end
      end
    }
  })
end
return {
  setup = setup
}
