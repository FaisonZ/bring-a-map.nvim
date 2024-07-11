local M = {}

function M.setup()
    vim.api.nvim_create_user_command('BMTest', 'echo "BM Test"', {})
end

return M

