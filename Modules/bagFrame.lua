local addon = LibStub("AceAddon-3.0"):GetAddon("SageLootCouncil")
local SageBagFrame = addon:NewModule("SageBagFrame", "AceTimer-3.0")
local ST = LibStub("ScrollingTable")
local L = LibStub("AceLocale-3.0"):GetLocale("SageLootCouncil")

local ml;
local selectedItems;

function SageBagFrame:OnInitialize()
	
end

function SageBagFrame:OnEnable()
	ml = addon:GetActiveModule("masterlooter")
end

function SageBagFrame:OnDisable()
	self.frame:Hide()
end

function SageBagFrame:Show()
	self.frame = self:GetFrame()
	self.frame:Show()
end

function SageBagFrame:Hide()
	self.frame:Hide()
end

function SageBagFrame:ToggleItem(bag, slot, link)
    local key = bag .. ":" .. slot

    if self.selectedItems[key] then
        self.selectedItems[key] = nil
    else
        self.selectedItems[key] = link
    end
end

function SageBagFrame:Clear()
    wipe(self.selectedItems)
end

function SageBagFrame:Submit()

end
