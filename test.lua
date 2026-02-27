-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Config
local PROXIMITY_DISTANCE = 12 -- distância em studs para considerar "próximo"

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

-- Função auxiliar: retorna lista de casas WH ordenadas numericamente
local function getOrderedWHHouses(housesFolder)
    local list = {}
    for _, house in ipairs(housesFolder:GetChildren()) do
        if type(house.Name) == "string" and house.Name:sub(1,2) == "WH" then
            table.insert(list, house)
        end
    end
    table.sort(list, function(a,b)
        local na = tonumber(a.Name:match("^WH(%d+)$")) or math.huge
        local nb = tonumber(b.Name:match("^WH(%d+)$")) or math.huge
        return na < nb
    end)
    return list
end

-- pressE sem teleport: escolhe a primeira WH com panelas próximas e interage só nela
local function pressE()
    pcall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        local housesFolder = map:FindFirstChild("Houses")
        if not housesFolder then return end

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local whHouses = getOrderedWHHouses(housesFolder)

        -- procura a primeira casa WH que tenha pelo menos uma panela dentro da distância configurada
        local chosenHouse = nil
        if hrp then
            for _, house in ipairs(whHouses) do
                local interior = house:FindFirstChild("Interior")
                if interior then
                    for _, child in ipairs(interior:GetChildren()) do
                        if child.Name == "Cooking Pot" then
                            local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local dist = (hrp.Position - part.Position).Magnitude
                                if dist <= PROXIMITY_DISTANCE then
                                    chosenHouse = house
                                    break
                                end
                            end
                        end
                    end
                end
                if chosenHouse then break end
            end
        end

        -- se encontrou uma casa próxima, interage com todas as Cooking Pot dessa casa
        if chosenHouse then
            local interior = chosenHouse:FindFirstChild("Interior")
            if interior then
                for _, child in ipairs(interior:GetChildren()) do
                    if child.Name == "Cooking Pot" then
                        local att = child:FindFirstChild("Attachment")
                        local pp = att and att:FindFirstChildWhichIsA("ProximityPrompt")
                        if not pp then
                            for _, desc in ipairs(child:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    pp = desc
                                    break
                                end
                            end
                        end
                        if pp then
                            pcall(function() fireproximityprompt(pp) end)
                            print("Pressionou E na Cooking Pot em:", chosenHouse.Name)
                            wait(0.12)
                        end
                    end
                end
            end
            return
        end

        -- fallback sem teleport: nenhuma casa WH próxima encontrada, aciona remotamente todos os prompts das WH
        for _, house in ipairs(whHouses) do
            local interior = house:FindFirstChild("Interior")
            if interior then
                for _, child in ipairs(interior:GetChildren()) do
                    if child.Name == "Cooking Pot" then
                        local att = child:FindFirstChild("Attachment")
                        local pp = att and att:FindFirstChildWhichIsA("ProximityPrompt")
                        if not pp then
                            for _, desc in ipairs(child:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    pp = desc
                                    break
                                end
                            end
                        end
                        if pp then
                            pcall(function() fireproximityprompt(pp) end)
                            print("Pressionou E remotamente na Cooking Pot em:", house.Name)
                            wait(0.12)
                        end
                    end
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
