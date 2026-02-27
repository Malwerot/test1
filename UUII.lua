-- UI BH4L (preto e vermelho) que interage com o AutoFarm já existente
-- Cole este bloco depois do seu código base (mesmo script) para que as variáveis/funções sejam acessíveis.

-- Carrega Kavo (ajuste URL se necessário)
local ok, Kavo = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)
if not ok or not Kavo then
    warn("[BH4L UI] Falha ao carregar Kavo UI Library.")
    return
end

-- Tema BH4L
local BH4LTheme = {
    SchemeColor = Color3.fromRGB(200, 16, 46),  -- vermelho BH4L
    Background  = Color3.fromRGB(10, 10, 10),   -- preto
    Header      = Color3.fromRGB(6, 6, 6),
    TextColor   = Color3.fromRGB(230, 230, 230),
    ElementColor= Color3.fromRGB(20, 20, 20)
}

local Library = Kavo.CreateLib("BH4L AutoFarm UI", BH4LTheme)

-- Abas e seções
local Tab = Library:NewTab("AutoFarm")
local SectionControl = Tab:NewSection("Controle")
local SectionItems = Tab:NewSection("Itens")
local SectionQuick = Tab:NewSection("Ações Rápidas")
local SectionStatus = Tab:NewSection("Status")

-- Estado local da UI
local showLogs = true

-- Helper seguro para acessar variáveis/funções do código base
local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[BH4L UI] Erro ao chamar função:", res)
    end
    return res
end

-- Toggle principal: liga/desliga AutoFarm usando as variáveis/funções do base
SectionControl:NewToggle("Iniciar AutoFarm", "Liga/Desliga o ciclo de farm", function(state)
    -- tenta usar as variáveis/funções do script base
    if type(autoFarmEnabled) ~= "nil" then
        autoFarmEnabled = state
    end
    if state then
        if type(startAutoFarm) == "function" then
            safeCall(startAutoFarm)
        end
        if showLogs then print("[BH4L UI] AutoFarm iniciado.") end
    else
        if type(stopAutoFarm) == "function" then
            safeCall(stopAutoFarm)
        end
        if showLogs then print("[BH4L UI] AutoFarm parado.") end
    end
end)

-- Slider para ajustar EQUIP_DELAY (se existir)
SectionControl:NewSlider("Equip Delay", "Delay entre equipar e usar (segundos)", 5, 0, function(value)
    if type(EQUIP_DELAY) ~= "nil" then
        EQUIP_DELAY = value
        if showLogs then print("[BH4L UI] EQUIP_DELAY definido para:", value) end
    else
        warn("[BH4L UI] Variável EQUIP_DELAY não encontrada no escopo.")
    end
end)

-- Dropdown dinâmico com itens atuais (recriado quando itens mudarem)
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
    if type(equipItem) == "function" then
        local ok = safeCall(equipItem, choice)
        if ok and showLogs then
            print("[BH4L UI] Equipado manualmente:", choice)
        elseif showLogs then
            print("[BH4L UI] Falha ao equipar manualmente:", choice)
        end
    else
        warn("[BH4L UI] Função equipItem não encontrada.")
    end
end)

-- Caixa para adicionar novo item à lista farmItems (sem alterar lógica do farm)
SectionItems:NewTextBox("Adicionar Item", "Formato: Nome,cooldown (ex: Water,0.2)", function(text)
    if not text or text == "" then return end
    local name, cd = string.match(text, "^%s*(.-)%s*,%s*(%d+%.?%d*)%s*$")
    if name and cd then
        if type(farmItems) == "table" then
            table.insert(farmItems, {name = name, cooldown = tonumber(cd)})
            -- atualiza dropdown
            local names = buildItemList()
            itemDropdown:Refresh(names)
            if showLogs then print("[BH4L UI] Item adicionado:", name, "cooldown:", cd) end
        else
            warn("[BH4L UI] farmItems não disponível para modificação.")
        end
    else
        warn("[BH4L UI] Formato inválido. Use: Nome,cooldown")
    end
end)

-- Botões rápidos
SectionQuick:NewButton("Mostrar Inventário", "Lista os itens atuais no Output", function()
    if type(getInventory) == "function" then
        local inv = safeCall(getInventory) or {}
        if #inv == 0 then
            print("[BH4L UI] Inventário vazio.")
        else
            for i, v in ipairs(inv) do print(i .. ". " .. v) end
        end
    else
        warn("[BH4L UI] Função getInventory não encontrada.")
    end
end)

SectionQuick:NewButton("Pressionar E (Manual)", "Aciona o ProximityPrompt do Cooking Pot", function()
    if type(pressE) == "function" then
        safeCall(pressE)
        if showLogs then print("[BH4L UI] pressE acionado manualmente.") end
    else
        warn("[BH4L UI] Função pressE não encontrada.")
    end
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

-- Keybind para alternar UI
SectionControl:NewKeybind("Atalho: Toggle UI", "Alterna a visibilidade da UI", {Name = "RightControl"}, function()
    Library:ToggleUI()
end)

-- Status em tempo real (labels atualizados via Heartbeat)
local statusIndexLabel = SectionStatus:NewLabel("Item atual: -")
local statusNextLabel  = SectionStatus:NewLabel("Próximo item: -")
local statusTimerLabel = SectionStatus:NewLabel("Tempo até próxima ação: -")
local statusStateLabel = SectionStatus:NewLabel("Estado: Parado")

-- Atualização segura do status (tenta ler variáveis do base; usa pcall para evitar erros)
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    -- Estado do AutoFarm
    local stateText = "Parado"
    if type(autoFarmEnabled) == "boolean" and autoFarmEnabled then stateText = "Ativo" end
    pcall(function() statusStateLabel:SetText("Estado: " .. stateText) end)

    -- Item atual / próximo (se farmItems e currentIndex existirem)
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

    -- Tempo até próxima ação: tenta estimar usando farmItems[currentIndex].cooldown e uma variável farmTimer (se existir)
    pcall(function()
        local remaining = "-"
        if type(farmItems) == "table" and #farmItems > 0 and type(currentIndex) == "number" then
            local cd = farmItems[currentIndex] and farmItems[currentIndex].cooldown or nil
            if cd and type(farmTimer) == "number" then
                remaining = tostring(math.max(0, cd - farmTimer))
            elseif cd then
                remaining = tostring(cd)
            end
        end
        statusTimerLabel:SetText("Tempo até próxima ação: " .. tostring(remaining))
    end)
end)

-- Mensagem final
print("[BH4L UI] Interface carregada. Tema BH4L aplicado. Use a aba AutoFarm para controlar o bot.")
