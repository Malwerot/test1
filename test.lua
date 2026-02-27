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

-- Novas variáveis para panelas
local cookingPots = {}
local potIndex = 1

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

-- Retorna uma lista de instâncias Cooking Pot encontradas no mapa
local function getCookingPots()
    local found = {}
    pcall(function()
        local housesFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Houses")
        if not housesFolder then
            warn("Pasta Houses não encontrada em Workspace.Map")
            return
        end

        for _, house in ipairs(housesFolder:GetChildren()) do
            local interior = house:FindFirstChild("Interior")
            if interior then
                for _, child in ipairs(interior:GetChildren()) do
                    if child.Name == "Cooking Pot" then
                        table.insert(found, child)
                    end
                end
            end
        end
    end)
    return found
end

-- Função segura: apenas lista todas as Cooking Pot no mapa (mantive para debug)
local function listarCookingPots()
    pcall(function()
        local found = getCookingPots()
        if #found == 0 then
            print("Nenhuma Cooking Pot encontrada.")
            return
        end
        for i, pot in ipairs(found) do
            print(string.format("%d. Pot object: %s | Parent: %s", i, pot.Name, pot.Parent and pot.Parent.Name or "nil"))
        end
    end)
end

-- Tenta interagir com uma Cooking Pot (move o personagem e aciona ProximityPrompt se existir)
local function interactWithPot(pot)
    if not pot or not pot.Parent then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Move o personagem para perto da panela (offset para não colidir dentro do modelo)
    local successMove, err = pcall(function()
        local targetCFrame = pot:IsA("BasePart") and pot.CFrame or (pot:FindFirstChildWhichIsA("BasePart") and pot:FindFirstChildWhichIsA("BasePart").CFrame)
        if targetCFrame then
            hrp.CFrame = targetCFrame * CFrame.new(0, 0, -2) -- 2 studs atrás da panela
        end
    end)
    if not successMove then
        warn("Falha ao mover para a panela:", err)
    end

    -- Procura ProximityPrompt nos descendentes
    local prompt
    for _, desc in ipairs(pot:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            prompt = desc
            break
        end
    end

    if prompt then
        -- Tenta acionar o prompt de forma segura
        local ok, e = pcall(function()
            -- Alguns jogos aceitam InputHoldBegin/InputHoldEnd; outros têm FireServer em RemoteEvent
            if typeof(prompt.InputHoldBegin) == "function" then
                prompt:InputHoldBegin()
                wait(0.1)
                prompt:InputHoldEnd()
            else
                -- Tenta chamar :Trigger if available
                if typeof(prompt.Trigger) == "function" then
                    prompt:Trigger()
                end
            end
        end)
        if not ok then
            -- Tenta FireServer se existir
            local fired = false
            for _, desc in ipairs(pot:GetDescendants()) do
                if desc:IsA("RemoteEvent") then
                    pcall(function() desc:FireServer() end)
                    fired = true
                end
            end
            if not fired then
                warn("Não foi possível acionar ProximityPrompt ou RemoteEvent na panela:", e)
            end
        end
        return true
    else
        -- Se não houver prompt, tenta tocar na panela (alguns jogos detectam Touched)
        local part = pot:IsA("BasePart") and pot or pot:FindFirstChildWhichIsA("BasePart")
        if part then
            local okTouch, errTouch = pcall(function()
                hrp.CFrame = part.CFrame * CFrame.new(0, 0, -2)
            end)
            if okTouch then
                return true
            else
                warn("Falha ao posicionar para tocar na panela:", errTouch)
            end
        end
    end

    return false
end

-- Autofarm
local function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    farmTimer = 0
    equipPending = false
    currentIndex = 1
    potIndex = 1

    -- Preenche a lista de panelas no início
    cookingPots = getCookingPots()
    if #cookingPots == 0 then
        warn("Nenhuma Cooking Pot encontrada. Use listarCookingPots() para debug.")
        return
    end

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
                -- Após equipar, interage com a panela atual
                local pot = cookingPots[potIndex]
                local interacted = false
                if pot then
                    local ok, err = pcall(function()
                        interacted = interactWithPot(pot)
                    end)
                    if not ok then
                        warn("Erro ao interagir com panela:", err)
                    end
                end

                -- Avança para a próxima panela (mesmo se a interação falhar)
                potIndex = (potIndex % #cookingPots) + 1

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

SectionFarm:NewButton("Listar Cooking Pots", "Lista as Cooking Pots encontradas", function()
    listarCookingPots()
end)
