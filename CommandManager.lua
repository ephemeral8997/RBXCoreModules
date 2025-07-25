local CommandManager = {}
CommandManager.Commands = {}

function CommandManager:Register(args, func)
    assert(type(args) == "table", "Expected table for args")
    assert(type(args.Name) == "string", "args.Name must be a string")
    assert(type(func) == "function", "func must be a function")

    local cmdName = args.Name:lower()

    self.Commands[cmdName] = {
        Info = args,
        Execute = func,
    }

    if args.Aliases and type(args.Aliases) == "table" then
        for _, alias in ipairs(args.Aliases) do
            local aliasName = alias:lower()
            self.Commands[aliasName] = self.Commands[cmdName]
        end
    end
end

function CommandManager:Execute(input)
    local commands = input:split("\\")

    for _, commandStr in ipairs(commands) do
        commandStr = commandStr:match("^%s*(.-)%s*$") -- trim

        local args = commandStr:split(" ")
        local cmd = args[1] and args[1]:lower() or nil
        table.remove(args, 1)

        local entry = self.Commands[cmd]
        if entry and entry.Execute then
            local ok, err = pcall(function()
                entry.Execute(unpack(args))
            end)
            if not ok then
                dev_log(2, "DiddyGui Error executing command '" .. tostring(cmd) .. "':", err)
            end
        else
            dev_log(1, "Unknown command attempted:", tostring(cmd))
        end
    end
end

return CommandManager
