local M = {}

function M.refactor_perform(command, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)

  local prompt
  local default
  local kind = command.arguments[1]
  if kind == "EXTRACT_METHOD" then
    prompt = "Enter a name for the method: "
    default = "newMethod"
  elseif kind == "EXTRACT_WIDGET" then
    prompt = "Enter a name for the widget: "
    default = "NewWidget"
  elseif kind == "EXTRACT_LOCAL_VARIABLE" then
    prompt = "Enter a name for the variable: "
    default = "newVariable"
  else
    client.request("workspace/executeCommand", command)
    return
  end

  local opts = {
    prompt = prompt,
    default = default,
  }

  local on_confirm = function(name)
    if name == nil then
      return
    end

    -- The 6th argument is the additional options of the refactor command.
    -- For the extract method/local variable/widget commands, we can specify an optional `name` option.
    -- see more: https://github.com/dart-lang/sdk/blob/e995cb5f7cd67d39c1ee4bdbe95c8241db36725f/pkg/analysis_server/lib/src/lsp/handlers/commands/perform_refactor.dart#L53
    local optionsIndex = 6
    command.arguments[optionsIndex] = {
      name = name,
    }

    client.request("workspace/executeCommand", command)
  end

  if vim.ui and vim.ui.input then
    vim.ui.input(opts, on_confirm)
  else
    local input = vim.fn.input(opts)
    if #input > 0 then
      on_confirm(input)
    end
  end
end

return M
