-- BH4L AutoFarm completo (AutoFarm + UI integrada)
-- Cole este script inteiro no mesmo LocalScript para garantir que a UI interaja diretamente com o AutoFarm.
-- Requer HttpGet habilitado para carregar a Kavo UI Library.

-- =========================
-- AutoFarm (código base)
-- =========================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
            if showLogs then print("[AutoFarm] Equipado:", itemName) end
            return true
        end
    end
    if showLogs then print("[AutoFarm] Item não encontrado:", itemName) end
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
                    if showLogs then print("[AutoFarm] Pressionou E no Cooking Pot") end
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

        elseif farmItems and #farmItems > 0 and farmTimer >= (farmItems[currentIndex] and farmItems[currentIndex].cooldown or 1) then
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
-- UI (Kavo UI Library) - BH4L (preto e vermelho)
-- =========================

-- Carrega Kavo UI Library
local ok, Kavo = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)
if not ok or not Kavo then
    warn("[BH4L UI] Falha ao carregar Kavo UI Library. Verifique HttpGet e URL.")
    return
end

-- Tema BH4L
local BH4LTheme = {
    SchemeColor = Color3.fromRGB(200, 16, 46),  -- vermelho BH4L
    Background  = Color3.fromRGB(10, 10, 10),   -- preto profundo
    Header      = Color3.fromRGB(6, 6, 6),
    TextColor   = Color3.fromRGB(230, 230, 230),
    ElementColor= Color3.fromRGB(20, 20, 20)
}

local Library = Kavo.CreateLib("BH4L AutoFarm", BH4LTheme)

-- Abas e seções
local TabFarm = Library:NewTab("AutoFarm")
local SectionControl = TabFarm:NewSection("Controle")
local SectionItems = TabFarm:NewSection("Itens e Timers")
local SectionQuick = TabFarm:NewSection("Ações Rápidas")
local SectionStatus = TabFarm:NewSection("Status")

-- Estado local da UI
showLogs = true -- variável global usada também pelo AutoFarm para prints

-- Helper seguro
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[BH4L UI] Erro ao chamar função:", res)
        return nil
    end
    return res
end

-- Toggle principal: liga/desliga AutoFarm
SectionControl:NewToggle("Iniciar AutoFarm", "Liga/Desliga o ciclo de farm", function(state)
    autoFarmEnabled = state
    if state then
        currentIndex = 1
        safeCall(startAutoFarm)
        if showLogs then print("[BH4L UI] AutoFarm iniciado!") end
    else
        safeCall(stopAutoFarm)
        if showLogs then print("[BH4L UI] AutoFarm parado!") end
    end
end)

-- Slider para ajustar EQUIP_DELAY
SectionControl:NewSlider("Equip Delay", "Delay entre equipar e usar (segundos)", 5, 0, function(value)
    EQUIP_DELAY = value
    if showLogs then print("[BH4L UI] EQUIP_DELAY ajustado para:", value) end
end)

-- Keybind para alternar UI
SectionControl:NewKeybind("Atalho: Toggle UI", "Alterna a visibilidade da UI", {Name = "RightControl"}, function()
    Library:ToggleUI()
end)

-- Dropdown dinâmico com itens atuais
local function buildItemList()
    local names = {}
    if type(farmItems) == "table" then
        for _, it in ipairs(farmItems) do
            table.insert(names, it.name or "Unknown")
        end
    end
    return names
end

local itemDropdown = SectionItems:NewDropdown("Selecionar Item", "Escolha um item para equipar manualmente", buildItemList(), function(choice)
    if not choice then return end
    local ok = safeCall(equipItem, choice)
    if ok and showLogs then
        print("[BH4L UI] Equipado manualmente:", choice)
    elseif showLogs then
        print("[BH4L UI] Falha ao equipar manualmente:", choice)
    end
end)

-- Caixa para adicionar novo item à lista farmItems
SectionItems:NewTextBox("Adicionar Item", "Formato: Nome,cooldown (ex: Water,0.2)", function(text)
    if not text or text == "" then return end
    local name, cd = string.match(text, "^%s*(.-)%s*,%s*(%d+%.?%d*)%s*$")
    if name and cd then
        if type(farmItems) == "table" then
            table.insert(farmItems, {name = name, cooldown = tonumber(cd)})
            -- atualiza dropdown (Kavo: Refresh pode não existir em todas as versões; tentamos com pcall)
            pcall(function()
                if itemDropdown and itemDropdown.Refresh then
                    itemDropdown:Refresh(buildItemList())
                end
            end)
            if showLogs then print("[BH4L UI] Item adicionado:", name, "cooldown:", cd) end
        else
            warn("[BH4L UI] farmItems não disponível para modificação.")
        end
    else
        warn("[BH4L UI] Formato inválido. Use: Nome,cooldown")
    end
end)

-- Caixa para remover item por nome
SectionItems:NewTextBox("Remover Item", "Digite o nome exato do item para remover", function(text)
    if not text or text == "" then return end
    if type(farmItems) ~= "table" then return end
    for i = #farmItems, 1, -1 do
        if farmItems[i].name == text then
            table.remove(farmItems, i)
            pcall(function()
                if itemDropdown and itemDropdown.Refresh then
                    itemDropdown:Refresh(buildItemList())
                end
            end)
            if showLogs then print("[BH4L UI] Item removido:", text) end
            return
        end
    end
    warn("[BH4L UI] Item não encontrado para remoção:", text)
end)

-- Botões rápidos
SectionQuick:NewButton("Mostrar Inventário", "Lista os itens atuais no Output", function()
    local inv = safeCall(getInventory) or {}
    if #inv == 0 then
        print("[BH4L UI] Inventário vazio.")
    else
        for i, itemName in ipairs(inv) do
            print(i .. ". " .. itemName)
        end
    end
end)

SectionQuick:NewButton("Pressionar E (Manual)", "Aciona o ProximityPrompt do Cooking Pot", function()
    safeCall(pressE)
    if showLogs then print("[BH4L UI] pressE acionado manualmente.") end
end)

SectionQuick:NewButton("Pular Item Atual", "Avança para o próximo item da lista", function()
    if type(currentIndex) == "number" and type(farmItems) == "table" and #farmItems > 0 then
        currentIndex = currentIndex % #farmItems + 1
        if showLogs then print("[BH4L UI] currentIndex agora:", currentIndex) end
    else
        warn("[BH4L UI] currentIndex ou farmItems não acessíveis.")
    end
end)

SectionQuick:NewToggle("Mostrar Logs", "Ativa/Desativa prints no Output", function(state)
    showLogs = state
    print("[BH4L UI] Mostrar Logs:", state and "Ativado" or "Desativado")
end)

-- Status em tempo real (labels)
local statusIndexLabel = SectionStatus:NewLabel("Item atual: -")
local statusNextLabel  = SectionStatus:NewLabel("Próximo item: -")
local statusTimerLabel = SectionStatus:NewLabel("Tempo até próxima ação: -")
local statusStateLabel = SectionStatus:NewLabel("Estado: Parado")
local statusEquipDelay = SectionStatus:NewLabel("Equip Delay: " .. tostring(EQUIP_DELAY))

-- Atualização do status via Heartbeat
RunService.Heartbeat:Connect(function()
    -- Estado do AutoFarm
    local stateText = "Parado"
    if autoFarmEnabled then stateText = "Ativo" end
    pcall(function() statusStateLabel:SetText("Estado: " .. stateText) end)

    -- Item atual / próximo
    pcall(function()
        if type(farmItems) == "table" and #farmItems > 0 and type(currentIndex) == "number" then
            local cur = farmItems[currentIndex] and farmItems[currentIndex].name or "-"
            local nexti = farmItems[currentIndex % #farmItems + 1] and farmItems[currentIndex % #farmItems + 1].name or "-"
            statusIndexLabel:SetText("Item atual: " .. tostring(cur))
            statusNextLabel:SetText("Próximo item: " .. tostring(nexti))
        else
            statusIndexLabel:SetText("Item atual: -")
            statusNextLabel:SetText("Próximo item: -")
        end
    end)

    -- Tempo até próxima ação
    pcall(function()
        local remaining = "-"
        if type(farmItems) == "table" and #farmItems > 0 and type(currentIndex) == "number" then
            local cd = farmItems[currentIndex] and farmItems[currentIndex].cooldown or nil
            if cd and type(farmTimer) == "number" then
                remaining = string.format("%.2f", math.max(0, cd - farmTimer))
            elseif cd then
                remaining = tostring(cd)
            end
        end
        statusTimerLabel:SetText("Tempo até próxima ação: " .. tostring(remaining))
    end)

    -- Equip delay label
    pcall(function()
        statusEquipDelay:SetText("Equip Delay: " .. tostring(EQUIP_DELAY))
    end)
end)

-- Atalho Insert para alternar UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:ToggleUI()
    end
end)

-- Mensagem final
print("[BH4L AutoFarm] Script carregado. UI BH4L pronta — use a aba AutoFarm para controlar o bot.")
