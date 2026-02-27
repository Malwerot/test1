-- AutoFarm + UI BH4L (preto e vermelho)
-- Certifique-se de ter HttpGet habilitado no ambiente

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis globais do AutoFarm
local autoFarmEnabled = false
local farmConnection
local currentIndex = 1
local farmTimer = 0
local equipPending = false
local equipTimer = 0
local EQUIP_DELAY = 0.3

-- Lista de itens com cooldowns específicos (padrão)
local farmItems = {
    {name = "Water", cooldown = 0.2},
    {name = "Sugar Block Bag", cooldown = 20},
    {name = "Gelatin", cooldown = 2.5},
    {name = "Empty Bag", cooldown = 45},
}

-- Funções utilitárias
local function getInventory()
    local allItems = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(allItems, item.Name) end
        end
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
    local tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(itemName)
    if tool then
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            hum:EquipTool(tool)
            print("[AutoFarm] Equipado:", itemName)
            return true
        end
    end
    print("[AutoFarm] Item não encontrado:", itemName)
    return false
end

local function pressE()
    pcall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        local houses = map:FindFirstChild("Houses")
        if not houses then return end
        local wh1 = houses:FindFirstChild("WH1")
        if not wh1 then return end
        local interior = wh1:FindFirstChild("Interior")
        if not interior then return end
        for _, child in ipairs(interior:GetChildren()) do
            if child.Name == "Cooking Pot" then
                local att = child:FindFirstChild("Attachment")
                local pp = att and att:FindFirstChild("ProximityPrompt")
                if pp then
                    fireproximityprompt(pp)
                    print("[AutoFarm] Pressionou E no Cooking Pot")
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
            if farmConnection then
                farmConnection:Disconnect()
                farmConnection = nil
            end
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

        elseif farmTimer >= (farmItems[currentIndex] and farmItems[currentIndex].cooldown or 1) then
            local itemName = farmItems[currentIndex] and farmItems[currentIndex].name
            if itemName then
                local success = equipItem(itemName)
                if success then
                    equipPending = true
                    equipTimer = 0
                    currentIndex = currentIndex % #farmItems + 1
                else
                    currentIndex = currentIndex % #farmItems + 1
                end
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

-- =========================
-- UI (Kavo UI Library)
-- =========================

-- Carrega a Kavo UI Library (use o URL que você preferir)
local success, Kavo = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)
if not success or not Kavo then
    warn("[UI] Falha ao carregar Kavo UI Library. Verifique HttpGet e URL.")
    return
end

-- Tema BH4L (preto e vermelho)
local BH4LTheme = {
    SchemeColor = Color3.fromRGB(200, 16, 46),  -- vermelho BH4L
    Background  = Color3.fromRGB(10, 10, 10),   -- preto profundo
    Header      = Color3.fromRGB(8, 8, 8),
    TextColor   = Color3.fromRGB(230, 230, 230),
    ElementColor= Color3.fromRGB(20, 20, 20)
}

local Library = Kavo.CreateLib("BH4L AutoFarm", BH4LTheme)

-- Aba AutoFarm
local TabFarm = Library:NewTab("AutoFarm")
local SectionControl = TabFarm:NewSection("Controle")
local SectionItems = TabFarm:NewSection("Itens e Timers")
local SectionDebug = TabFarm:NewSection("Ações Rápidas")

-- Toggle principal para iniciar/parar AutoFarm
SectionControl:NewToggle("Iniciar AutoFarm", "Liga/Desliga o ciclo de farm", function(state)
    autoFarmEnabled = state
    if state then
        currentIndex = 1
        startAutoFarm()
        print("[UI] AutoFarm iniciado!")
    else
        stopAutoFarm()
        print("[UI] AutoFarm parado!")
    end
end)

-- Slider para ajustar EQUIP_DELAY em tempo real
SectionControl:NewSlider("Equip Delay", "Delay entre equipar e usar (segundos)", 1, 0, function(value)
    EQUIP_DELAY = value
    print("[UI] EQUIP_DELAY ajustado para:", value)
end)

-- Dropdown para selecionar item atual (permite forçar o próximo item)
local itemNames = {}
for _, v in ipairs(farmItems) do table.insert(itemNames, v.name) end
SectionItems:NewDropdown("Selecionar Item", "Escolha um item para equipar manualmente", itemNames, function(choice)
    -- tenta equipar imediatamente o item escolhido
    if choice then
        local ok = equipItem(choice)
        if ok then
            print("[UI] Equipado manualmente:", choice)
        else
            print("[UI] Falha ao equipar manualmente:", choice)
        end
    end
end)

-- Lista de itens com cooldowns editáveis (campo de texto para adicionar novo item)
SectionItems:NewTextBox("Adicionar Item", "Formato: Nome,cooldown (ex: Water,0.2)", function(text)
    if not text or text == "" then return end
    local name, cd = string.match(text, "^%s*(.-)%s*,%s*(%d+%.?%d*)%s*$")
    if name and cd then
        table.insert(farmItems, {name = name, cooldown = tonumber(cd)})
        print("[UI] Item adicionado:", name, "cooldown:", cd)
    else
        print("[UI] Formato inválido. Use: Nome,cooldown")
    end
end)

-- Botão para listar inventário no Output
SectionDebug:NewButton("Mostrar Inventário", "Lista os itens atuais no Output", function()
    local inv = getInventory()
    if #inv == 0 then
        print("[UI] Inventário vazio.")
    else
        for i, itemName in ipairs(inv) do
            print(i .. ". " .. itemName)
        end
    end
end)

-- Botão para pressionar E manualmente (usar Cooking Pot)
SectionDebug:NewButton("Pressionar E (Manual)", "Aciona o ProximityPrompt do Cooking Pot", function()
    pressE()
end)

-- Botão para avançar item (pular para o próximo)
SectionDebug:NewButton("Pular Item Atual", "Avança para o próximo item da lista", function()
    currentIndex = currentIndex % #farmItems + 1
    print("[UI] Próximo item selecionado. Index agora:", currentIndex)
end)

-- Toggle para mostrar logs no Output (simples)
local showLogs = true
SectionDebug:NewToggle("Mostrar Logs", "Ativa/Desativa prints no Output", function(state)
    showLogs = state
    print("[UI] Mostrar Logs:", state and "Ativado" or "Desativado")
end)

-- Keybind para alternar UI (exemplo: RightControl)
SectionControl:NewKeybind("Atalho: Toggle UI", "Pressione para alternar a UI", {Name = "RightControl"}, function()
    Library:ToggleUI()
end)

-- Pequeno wrapper para prints condicionais
local function log(...)
    if showLogs then
        print(...)
    end
end

-- Substitui prints por log onde apropriado (exemplo: equipItem e pressE já imprimem)
-- (Se desejar, substitua prints por log nas funções acima)

-- Atalho de teclado Insert para alternar UI (opcional)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:ToggleUI()
    end
end)

-- Mensagem final
print("[BH4L AutoFarm] UI carregada com tema BH4L. Use a aba AutoFarm para controlar o bot.")
