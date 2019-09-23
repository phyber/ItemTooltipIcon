-- Blizzard API locals
local GetItemInfoInstant = GetItemInfoInstant

-- Lua function locals
local select = select

-- Stores a reference to an item icon per tooltip type so we don't trash
-- ItemRefTooltip icons while mousing over GameTooltip icons, etc.
local itemIcons = {}

-- Create a frame and texture for the item icon, per tooltip.
local function CreateIcon(tooltip)
    local icon = {}
    icon.frame = CreateFrame("Frame", nil, UIParent)

    local frame = icon.frame
    frame:SetWidth(40)
    frame:SetHeight(40)

    icon.texture = frame:CreateTexture(nil, "ARTWORK")
    itemIcons[tooltip] = icon

    -- Return the newly created icon so we can use it immediately without
    -- having to index into the itemIcons table.
    return icon
end

-- Show an item's icon to the upper left side of the tooltip.
local function ShowItemIcon(tooltip)
    local name, link = tooltip:GetItem() -- luacheck: ignore 211/name
    if not link then
        return
    end

    -- Get the fileID of the item's icon
    local fileID = select(5, GetItemInfoInstant(link))
    if not fileID then
        return
    end

    -- Create an icon frame for the tooltip if we didn't yet
    local icon = itemIcons[tooltip]
    if not icon then
        -- Create and grab a reference to the newly created icon
        icon = CreateIcon(tooltip)
    end

    -- Some references to avoid indexing into the itemIcons table for each
    -- thing below
    local frame = icon.frame
    local texture = icon.texture

    -- We want to set the icon frame to the same level as the tooltip,
    -- otherwise it can be hidden behind things like the character frame when
    -- mousing over equipped items.
    frame:SetFrameStrata(tooltip:GetFrameStrata())
    frame:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", 0, -1)
    texture:SetAllPoints(frame)
    texture:SetTexture(fileID)
    texture:Show()
    frame:Show()
end

-- Hide the item icon when the tooltip closes.
local function HideItemIcon(tooltip)
    -- Abort if no icon was created for the tooltip type yet.
    local icon = itemIcons[tooltip]
    if not icon then
        return
    end

    -- Try to get a reference to the frame, should always succeed if the above
    -- check was successful
    local frame = icon.frame
    if not frame then
        return
    end

    frame:Hide()
end

-- Handlers for each type of tooltip to add item icons to.
GameTooltip:HookScript("OnTooltipCleared", HideItemIcon)
GameTooltip:HookScript("OnTooltipSetItem", ShowItemIcon)
ItemRefTooltip:HookScript("OnTooltipCleared", HideItemIcon)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowItemIcon)
