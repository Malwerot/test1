-- Copilot UI usando Kavo-UI-Library (carrega a library do URL que você forneceu)
-- Ajuste o URL se você já tiver o source.lua localmente
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Tema personalizado com "identidade" do assistente (teal / azul suave)
local CopilotTheme = {
    SchemeColor = Color3.fromRGB(26, 189, 158),   -- cor principal (teal)
    Background  = Color3.fromRGB(18, 20, 25),    -- fundo escuro
    Header      = Color3.fromRGB(14, 16, 20),    -- header
    TextColor   = Color3.fromRGB(235, 241, 246), -- texto claro
    ElementColor= Color3.fromRGB(28, 30, 36)     -- elementos
}

-- Cria a biblioteca (janela principal)
local Library = Kavo.CreateLib("Copilot — Assistente", CopilotTheme)

-- Aba Sobre
local aboutTab = Library:NewTab("Sobre")
local aboutSection = aboutTab:NewSection("Apresentação")

aboutSection:NewLabel("Olá — eu sou o Copilot")
aboutSection:NewLabel("Interface demonstrativa com identidade visual do assistente.")
aboutSection:NewButton("Mostrar saudação", "Clique para ver uma saudação no output", function()
    print("[Copilot UI] Olá, Pedro! Esta é uma demonstração da UI com minha identidade.")
end)

-- Aba Ações (exemplos de controles)
local actionsTab = Library:NewTab("Ações")
local actionsSection = actionsTab:NewSection("Controles")

actionsSection:NewTextBox("Enviar mensagem", "Digite algo e pressione Enter", function(text)
    print("[Copilot UI] Mensagem enviada:", text)
end)

local toggleState = false
actionsSection:NewToggle("Modo assistente", "Ativa respostas automáticas (demo)", function(state)
    toggleState = state
    print("[Copilot UI] Modo assistente:", state and "Ativado" or "Desativado")
end)

actionsSection:NewSlider("Volume (demo)", "Ajuste o volume de feedback (demo)", 100, 0, function(value)
    print("[Copilot UI] Volume ajustado para:", value)
end)

actionsSection:NewDropdown("Estilo de resposta", "Escolha um estilo de resposta", {"Conciso","Detalhado","Criativo"}, function(choice)
    print("[Copilot UI] Estilo selecionado:", choice)
end)

actionsSection:NewKeybind("Atalho: Toggle UI", "Pressione para alternar a UI", {Name = "RightControl"}, function()
    Library:ToggleUI()
end)

-- Aba Configurações (personalização)
local configTab = Library:NewTab("Configurações")
local configSection = configTab:NewSection("Aparência")

-- ColorPicker que altera a SchemeColor em tempo real
configSection:NewColorPicker("Cor principal", "Muda a cor de destaque da UI", CopilotTheme.SchemeColor, function(color)
    -- atualiza cor principal via API da library
    Kavo:ChangeColor("SchemeColor", color)
    print("[Copilot UI] SchemeColor atualizada para:", color)
end)

configSection:NewButton("Restaurar tema Copilot", "Restaura as cores iniciais", function()
    Kavo:ChangeColor("SchemeColor", CopilotTheme.SchemeColor)
    Kavo:ChangeColor("Background", CopilotTheme.Background)
    Kavo:ChangeColor("Header", CopilotTheme.Header)
    Kavo:ChangeColor("TextColor", CopilotTheme.TextColor)
    Kavo:ChangeColor("ElementColor", CopilotTheme.ElementColor)
    print("[Copilot UI] Tema restaurado.")
end)

-- Pequeno atalho para fechar/abrir a UI com a tecla Insert (exemplo)
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:ToggleUI()
    end
end)

-- Mensagem final no output para confirmar carregamento
print("[Copilot UI] Interface carregada com sucesso. Use as abas para testar os controles.")
