-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis globais
local autoFarmEnabled = false
local farmConnection
local currentIndex = 1
local farmTimer = 0
local equipPending = false
local equipTimer = 0
local EQUIP_DELAY = 0.3

-- Lista de itens com cooldowns específicos
local farmItems = {
    {name = "Water", cooldown = 0.5},
    {name = "Sugar Block Bag", cooldown = 22},
    {name = "Gelatin", cooldown = 2.8},
    {name = "Empty Bag", cooldown = 47},
}

-- Funções utilitárias
local function getInventory()
    local allItems = {}
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then table.insert(allItems, item.Name) end
    end
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then table.insert(allItems, item.Name) end
        end
    end
    return allItems
end

local function countItems(itemName)
    local count = 0
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == itemName then
            count = count + 1
        end
    end
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name == itemName then
                count = count + 1
            end
        end
    end
    return count
end

local function equipItem(itemName)
    local character = LocalPlayer.Character
    if not character then return false end
    local tool = LocalPlayer.Backpack:FindFirstChild(itemName)
    if tool then
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            hum:EquipTool(tool)
            return true
        end
    end
    return false
end

-- Interagir com todos os Cooking Pots (WH1 e Home 2)
local function pressE()
    pcall(function()
        -- Cooking Pots da WH1
        local interiorWH1 = Workspace.Map.Houses.WH1:FindFirstChild("Interior")
        if interiorWH1 then
            for _, child in ipairs(interiorWH1:GetChildren()) do
                if child.Name == "Cooking Pot" then
                    local att = child:FindFirstChild("Attachment")
                    local pp = att and att:FindFirstChild("ProximityPrompt")
                    if pp then
                        fireproximityprompt(pp)
                    end
                end
            end
        end

        -- Cooking Pot da Home 2 (Apartments)
        local home2 = Workspace.Map.Locations.Apartments:FindFirstChild("Home 2")
        if home2 then
            local cookpot = home2:FindFirstChild("Cooking Pot")
            if cookpot then
                local att = cookpot:FindFirstChild("Attachment")
                local pp = att and att:FindFirstChild("ProximityPrompt")
                if pp then
                    fireproximityprompt(pp)
                end
            end
        end
    end)
end

-- Autofarm
local function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    farmTimer = 0
    equipPending = false
    currentIndex = 1

    farmConnection = RunService.Heartbeat:Connect(function(dt)
        if not autoFarmEnabled then
            farmConnection:Disconnect()
            farmConnection = nil
            return
        end

        farmTimer = farmTimer + dt

        if equipPending then
            equipTimer = equipTimer + dt
            if equipTimer >= EQUIP_DELAY then
                pressE()
                equipPending = false
                equipTimer = 0
                farmTimer = 0
            end

        elseif farmTimer >= farmItems[currentIndex].cooldown then
            local success = equipItem(farmItems[currentIndex].name)
            if success then
                equipPending = true
                equipTimer = 0
                currentIndex = currentIndex % #farmItems + 1
            else
                currentIndex = currentIndex % #farmItems + 1
            end
            farmTimer = 0
        end
    end)
end

local function stopAutoFarm()
    autoFarmEnabled = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end

-- contador de marshmallows possíveis
local function countMarshmallows()
    local sugarCount = countItems("Sugar Block Bag")
    local waterCount = countItems("Water")
    local gelatinCount = countItems("Gelatin")
    local marshmallowPossible = math.min(sugarCount, waterCount, gelatinCount)
    return marshmallowPossible
end

-- UI (depois que tudo está pronto)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Malwerot/test1/refs/heads/main/UUII.lua"))()
local Window = Library.CreateLib("XFC AutoFarm", "DarkTheme")

local TabFarm = Window:NewTab("AutoFarm")
local SectionFarm = TabFarm:NewSection("Controle")

SectionFarm:NewToggle("Iniciar AutoFarm", "Liga/Desliga o ciclo de farm", function(state)
    autoFarmEnabled = state
    if state then
        currentIndex = 1
        startAutoFarm()
    else
        stopAutoFarm()
    end
end)

SectionFarm:NewButton("Mostrar Inventário", "Lista os itens atuais", function()
    local inv = getInventory()
    for i, itemName in ipairs(inv) do
        -- Aqui você pode adaptar para mostrar na UI se quiser
    end
end)

-- Barrinha de marshmallows
local marshmallowBar = SectionFarm:NewSlider("Marshmallows possíveis", "Quantidade que pode ser produzida", 0, 100, 0, function() end)

SectionFarm:NewButton("Contar Marshmallows", "Atualiza a barrinha com o valor", function()
    local marshmallowCount = countMarshmallows()
    marshmallowBar:Update(marshmallowCount)
end)
