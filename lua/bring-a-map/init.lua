local M = {}

local mapBuf = nil
local win = nil

local BMGroup = vim.api.nvim_create_augroup("Bring-a-Map", {})

local data = {
    nodes = {
        _root = {
            filename = "<root>",
            children = {}
        }
    }
}

local prevFile = "<root>"

local function init_buffer()
    if mapBuf ~= nil then
        return
    end

    mapBuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(mapBuf, "Bring a Map")
end

local function update_map()
    --local lines = {
    --    "    ┌ ─ ─ ─ ─ ┐",
    --    "▷ ┬ ▪ ─ ▪ ─ ▪ ┘",
    --    "  └ ▣"
    --}
    local currentFile = vim.api.nvim_buf_get_name(0)

    local seenNodes = {}
    local node = "_root"
    local line = ""

    while node ~= "" and seenNodes[node] == nil do
        seenNodes[node] = true
        local nodeData = data.nodes[node]
        if nodeData.filename == "<root>" then
            line = line .. "▷"
        else
            if nodeData.filename == currentFile then
                line = line .. "▣"
            else
                line = line .. "▪"
            end
        end

        node = ""
        if #nodeData.children > 0 and seenNodes[nodeData.children[1]] == nil then
            node = nodeData.children[1]

            line = line .. " ─ "
        end
    end

    init_buffer()

    local lines = { line }
    vim.api.nvim_set_option_value("modifiable", true, { buf = mapBuf })
    vim.api.nvim_buf_set_lines(mapBuf, 0, #lines, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = mapBuf })

    return #lines
end

local function array_contains_str(arr, str)
    for _, value in ipairs(arr) do
        if value == str then
            return true
        end
    end

    return false
end

function M.print()
    for key, value in pairs(data.nodes) do
        print(key .. ": " .. value.filename)
        for _, child in pairs(value.children) do
            print("  child: " .. child)
        end
    end
end

local function add_file(filename, prevFilename)
    local hash = vim.fn.sha256(filename)
    local prevHash = "_root"

    if prevFilename ~= "<root>" then
        prevHash = vim.fn.sha256(prevFilename)
    end

    if data.nodes[hash] == nil then
        data.nodes[hash] = {
            filename = filename,
            children = {}
        }
    end

    if data.nodes[prevHash] ~= nil and not array_contains_str(data.nodes[prevHash].children, hash) then
        local idx = #data.nodes[prevHash].children
        data.nodes[prevHash].children[idx + 1] = hash
    end

    prevFile = filename

    update_map()
end

function M.record_file()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then
        return
    end
    add_file(filename, "<root>")
end

local recording = false

function M.toggle_recording()
    -- BufEnter
    if not recording then
        print("Recording...")
        recording = true
        M.record_file()
    else
        print("Done recording")
        recording = false
        prevFile = "<root>"
    end
end

function M.toggle_map()
    if win ~= nil then
        vim.api.nvim_win_close(win, false)
        win = nil

        return
    end

    local line_nums = update_map()

    win = vim.api.nvim_open_win(mapBuf, false, {
        split = "above",
        win = -1
    })
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win })
    vim.api.nvim_set_option_value("statusline", "Bring a Map", { win = win })

    vim.api.nvim_win_set_height(win, line_nums)
end

function M.setup()
    vim.api.nvim_create_autocmd({"BufEnter"}, {
        group = BMGroup,
        pattern = "*",
        callback = function(ev)
            if recording == false or ev.file == "" or prevFile == ev.file then
                return
            end

            add_file(ev.file, prevFile)
        end
    })

    vim.api.nvim_create_user_command('BMPrint', M.print, {})
    vim.api.nvim_create_user_command('BMToggle', M.toggle_recording, {})
    vim.api.nvim_create_user_command('BMMap', M.toggle_map, {})
end

return M

