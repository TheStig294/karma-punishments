surface.CreateFont("KPDesc", {
    font = "Arial",
    extended = false,
    size = 16,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = true,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

-- Manually define player:IsAdmin() for TTT2
local function IsAdmin(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local userGroup = ply:GetNWString("UserGroup", "user")

    if userGroup == "superadmin" or userGroup == "admin" then
        return true
    else
        return false
    end
end

local function OptionsMenu(PUNISHMENT)
    if not IsAdmin(LocalPlayer()) then return end
    -- Main window frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 350)
    frame:SetTitle("Punishment Options")
    frame:MakePopup()
    frame:Center()

    frame.Paint = function(_, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
    end

    -- Scrollbar
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    -- Name
    local name = vgui.Create("DLabel", layout)
    local nameText = ""

    if PUNISHMENT.name then
        nameText = "       " .. PUNISHMENT.name
    end

    name:SetText(nameText)
    name:SetFont("Trebuchet24")
    name:SetTextColor(COLOR_WHITE)
    name:SizeToContents()
    -- Description
    local desc = vgui.Create("DLabel", layout)
    local descText = ""

    if PUNISHMENT.desc then
        descText = "       " .. PUNISHMENT.desc
    end

    desc:SetText(descText)
    desc:SetFont("KPDesc")
    desc:SetTextColor(COLOR_WHITE)
    desc:SizeToContents()

    -- Convar list
    for _, cvarInfo in ipairs(PUNISHMENT.convars) do
        if not ConVarExists(cvarInfo.name) then return end
        -- Padding
        local padding = layout:Add("DPanel")
        padding:SetBackgroundColor(COLOR_BLACK)
        padding:SetHeight(10)
        local cvar = GetConVar(cvarInfo.name)
        local helpText = cvar:GetHelpText() or ""

        -- Checkbox boolean convars
        if cvarInfo.type == "bool" then
            local checkbox = layout:Add("DCheckBoxLabel")
            checkbox:SetText(helpText)
            checkbox:SetChecked(cvar:GetBool())
            checkbox:SizeToContents()
            checkbox:SetIndent(10)

            function checkbox:OnChange()
                net.Start("TTTKPChangeConvar")
                net.WriteString(cvarInfo.name)

                if checkbox:GetChecked() then
                    net.WriteString("1")
                else
                    net.WriteString("0")
                end

                net.SendToServer()
            end
        elseif cvarInfo.type == "int" or cvarInfo.type == "float" then
            -- Slider integer convars
            local slider = layout:Add("DNumSlider")
            slider:SetSize(300, 100)
            slider:SetText(helpText)
            slider:SetMin(cvar:GetMin() or 0)
            slider:SetMax(cvar:GetMax() or 100)

            if cvarInfo.type == "int" then
                slider:SetDecimals(0)
            else
                slider:SetDecimals(cvarInfo.decimals or 2)
            end

            slider:SetValue(cvar:GetFloat())
            slider:SetHeight(25)

            slider.OnValueChanged = function(self, value)
                timer.Create("TTTKPChangeConvarDelay", 0.5, 1, function()
                    value = math.Round(value, self:GetDecimals())
                    net.Start("TTTKPChangeConvar")
                    net.WriteString(cvarInfo.name)
                    net.WriteString(tostring(value))
                    net.SendToServer()
                end)
            end
        elseif cvarInfo.type == "string" then
            -- Textbox string convars
            local text = layout:Add("DLabel")
            text:SetText(helpText)
            text:SizeToContents()
            local textBox = layout:Add("DTextEntry")
            textBox:SetSize(450, 25)
            textBox:SetText(cvar:GetString())

            textBox.OnEnter = function(_, value)
                net.Start("TTTKPChangeConvar")
                net.WriteString(cvarInfo.name)
                net.WriteString(value)
                net.SendToServer()
            end
        end
    end
end

local function DrawPunishmentBar(list, PUNISHMENT)
    -- Background box
    local background = list:Add("DPanel")
    background:SetSize(480, 64)
    background:DockPadding(10, 0, 10, 5)
    -- Enabled cvar
    local alpha = 255
    local enabledCvarName = "ttt_kp_" .. PUNISHMENT.id
    local enabledCvar = GetConVar(enabledCvarName)

    if not enabledCvar:GetBool() then
        alpha = 100
    end

    background.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(40, 40, 40, alpha))
    end

    -- Name
    local name = vgui.Create("DLabel", background)
    local nameText = PUNISHMENT.name or "Punishment"
    name:SetText(nameText)
    name:SetPos(12, 2)
    name:SetFont("Trebuchet24")
    name:SizeToContents()
    -- Description
    local desc = vgui.Create("DLabel", background)
    desc:SetText(PUNISHMENT.extDesc or PUNISHMENT.desc or "")
    desc:Dock(BOTTOM)
    desc:SetFont("KPDesc")
    desc:SetTextColor(COLOUR_WHITE)
    desc:SizeToContents()
    -- Enabled/disabled checkbox
    local enabledBox = vgui.Create("DCheckBoxLabel", background)
    enabledBox:SetText("Enabled")
    enabledBox:SetChecked(enabledCvar:GetBool())
    enabledBox:SetIndent(10)
    enabledBox:SizeToContents()
    enabledBox:SetPos(400, 5)

    function enabledBox:OnChange()
        net.Start("TTTKPChangeConvar")
        net.WriteString(enabledCvarName)

        if enabledBox:GetChecked() then
            alpha = 255
            net.WriteString("1")
        else
            alpha = 100
            net.WriteString("0")
        end

        net.SendToServer()
    end

    -- Options button
    if PUNISHMENT.convars then
        local optionsButton = vgui.Create("DButton", background)
        optionsButton:SetText("Options")
        optionsButton:SizeToContents()
        optionsButton:SetPos(350, 4)

        function optionsButton:DoClick()
            OptionsMenu(PUNISHMENT)
        end
    end
end

local punishmentList = {}

-- Sorts the punishments by name in alphabetical order
local function DrawPunishmentsList(list, searchQuery)
    searchQuery = searchQuery or ""

    -- Only build the punishments table if needed
    if table.IsEmpty(punishmentList) then
        for id, PUNISHMENT in pairs(TTTKP.punishments) do
            -- If a punishment doesn't have a human-readable name, just use the punishment's id instead
            punishmentList[PUNISHMENT.name or id] = PUNISHMENT
        end
    end

    -- If there is a search query, search the punishment's name and description
    for name, PUNISHMENT in SortedPairs(punishmentList) do
        local description = PUNISHMENT.extDesc or PUNISHMENT.desc or ""

        if string.find(string.lower(name), string.lower(searchQuery), 1, true) or string.find(string.lower(description), string.lower(searchQuery), 1, true) then
            DrawPunishmentBar(list, PUNISHMENT)
        end
    end
end

local function CreateOptionsMenu()
    -- Base panel
    local basePnl = vgui.Create("DPanel")
    basePnl:Dock(FILL)
    basePnl:SetBackgroundColor(COLOR_BLACK)
    -- List outside the scrollbar
    local nonScrollList = vgui.Create("DIconLayout", basePnl)
    nonScrollList:Dock(TOP)
    -- Sets the space between the image and text boxes
    nonScrollList:SetSpaceY(8)
    nonScrollList:SetSpaceX(10)
    -- Sets the space between the edge of the window and the edges of the tab's contents
    nonScrollList:SetBorder(5)

    nonScrollList.Paint = function(_, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
    end

    -- Title text
    local titleText = nonScrollList:Add("DLabel")
    titleText:SetText("                             Karma Punishment Admin Options")
    titleText:SetFont("Trebuchet24")
    titleText:SizeToContents()
    -- Int slider for changing the threshold of karma when players get punished
    local thresholdCvar = GetConVar("ttt_kp_low_karma_threshold")
    -- Slider integer convars
    local slider = nonScrollList:Add("DNumSlider")
    slider:SetSize(300, 100)
    slider:SetText(thresholdCvar:GetHelpText())
    slider:SetMin(thresholdCvar:GetMin())
    slider:SetMax(thresholdCvar:GetMax())
    slider:SetDecimals(0)
    slider:SetValue(thresholdCvar:GetInt())
    slider:SetHeight(25)

    slider.OnValueChanged = function(self, value)
        timer.Create("TTTKPChangeConvarDelay", 0.5, 1, function()
            value = math.Round(value, self:GetDecimals())
            net.Start("TTTKPChangeConvar")
            net.WriteString(thresholdCvar:GetName())
            net.WriteString(tostring(value))
            net.SendToServer()
        end)
    end

    -- Search bar
    local searchBar = nonScrollList:Add("DTextEntry")
    searchBar:SetSize(570, 20)
    searchBar:SetPlaceholderText("Search...")
    searchBar:SetUpdateOnType(true)
    -- Scrollbar
    local scroll = vgui.Create("DScrollPanel", basePnl)
    scroll:Dock(FILL)
    -- Punishments list
    local list = vgui.Create("DIconLayout", scroll)
    list:Dock(FILL)
    -- Sets the space between text boxes
    list:SetSpaceY(10)
    list:SetSpaceX(10)
    -- Sets the space between the edge of the window and the edges of the tab's contents
    list:SetBorder(10)

    list.Paint = function(_, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
    end

    DrawPunishmentsList(list)

    -- Refreshes the punishments list according to what is typed in the search bar
    searchBar.OnValueChange = function(_, value)
        list:Clear()
        scroll:Rebuild()
        DrawPunishmentsList(list, value)
    end

    return basePnl
end

hook.Add("OnPlayerChat", "TTTKPTTT2OptionsMenu", function(ply, text)
    if not TTT2 then return end
    if not IsAdmin(LocalPlayer()) or ply ~= LocalPlayer() or string.lower(text) ~= "/KarmaPunishments" then return end
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 480)
    frame:Center()
    frame:SetTitle("KP Admin Options Menu")
    frame:ShowCloseButton(true)
    frame:MakePopup()
    local basePnl = CreateOptionsMenu()
    basePnl:SetParent(frame)

    return true
end)

hook.Add("TTTBeginRound", "TTTKPTTT2OptionsMessage", function()
    if TTT2 and IsAdmin(LocalPlayer()) then
        LocalPlayer():ChatPrint("Type /KarmaPunishments to open options window")
    end

    hook.Remove("TTTBeginRound", "TTTKPTTT2OptionsMessage")
end)

hook.Add("TTTSettingsTabs", "TTTKPPunishmentsList", function(dtabs)
    if TTT2 or not IsAdmin(LocalPlayer()) then return end
    local basePnl = CreateOptionsMenu()
    -- Adds the tab panel to TTT's F1 menu
    dtabs:AddSheet("KPs", basePnl, "vgui/ttt/icon_kp_16.png", false, false, "Enable/disable individual punishments for the Karma Punishments mod")
end)