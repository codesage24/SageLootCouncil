local addonName = "SageLootCouncil"
SLC = CreateFrame("Frame", addonName)

SLC.selectedItems = {}

-- Toggle item selection
function SLC:ToggleItem(bag, slot, link)
    local key = bag .. ":" .. slot

    if self.selectedItems[key] then
        self.selectedItems[key] = nil
    else
        self.selectedItems[key] = link
    end
end

function SLC:RunSlashCommand(command, args)
    command = command:lower()

    for name, func in pairs(SlashCmdList) do
        local i = 1
        while _G["SLASH_" .. name .. i] do
            if _G["SLASH_" .. name .. i]:lower() == command then
                func(args or "")
                return true
            end
            i = i + 1
        end
    end

    return false
end

-- Submit selected items to RCLootCouncil
function SLC:Submit()
    for _, link in pairs(self.selectedItems) do
        if link then
            local ok = self:RunSlashCommand("/rc", "add " .. link)

            if not ok then
                print("SLC: Could not find /rc slash command.")
            end
        end
    end
end

-- Clear selection
function SLC:Clear()
    wipe(self.selectedItems)
end

-- Slash command to open UI
SLASH_SLC1 = "/slc"
SlashCmdList["SLC"] = function()
    if SLC and SLC.ToggleUI then
        SLC:ToggleUI()
    else
        print("SLC: UI not loaded yet.")
    end
end
