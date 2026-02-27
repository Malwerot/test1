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
    {name = "Water", cooldown = 0.2},
    {name = "Sugar Block Bag", cooldown = 20},
    {name = "Gelatin", cooldown = 2.5},
    {name = "Empty Bag", cooldown = 45},
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

local function equipItem(itemName)
    local character = LocalPlayer.Character
    if not character then return false end
    local tool = LocalPlayer.Backpack:FindFirstChild(itemName)
    if tool then
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            hum:EquipTool(tool)
            print("Equipado:", itemName)
            return true
        end
    end
    print("Item não encontrado:", itemName)
    return false
end

local function pressE()
    pcall(function()
        local interior = Workspace.Map.Houses.WH1:FindFirstChild("Interior")
        if not interior then return end
        for _, child in ipairs(interior:GetChildren()) do
            if child.Name == "Cooking Pot" then
                local att = child:FindFirstChild("Attachment")
                local pp = att and att:FindFirstChild("ProximityPrompt")
                if pp then
                    fireproximityprompt(pp)
                    print("Pressionou E no Cooking Pot")
                    return
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
        print("AutoFarm iniciado!")
    else
        stopAutoFarm()
        print("AutoFarm parado!")
    end
end)

SectionFarm:NewButton("Mostrar Inventário", "Lista os itens atuais", function()
    for i, itemName in ipairs(getInventory()) do
        print(i .. ". " .. itemName)
    end
end)
