-- Autofarm Script
-- Coloque em StarterPlayerScripts para rodar no cliente

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ativo = true -- controle para desligar quando quiser

-- Função para simular apertar E
local function apertarE()
    UserInputService.InputBegan:Fire({
        KeyCode = Enum.KeyCode.E,
        UserInputType = Enum.UserInputType.Keyboard
    }, false)
end

-- Função para pegar item
local function pegarItem(nomeItem)
    local mochila = player.Backpack
    local item = mochila:FindFirstChild(nomeItem)
    if item then
        print("Pegando item:", nomeItem)
        apertarE()
    else
        print("Item não encontrado:", nomeItem)
    end
end

-- Loop principal
task.spawn(function()
    while ativo do
        -- 0 segundos: pegar Water
        pegarItem("water")
        apertarE()

        -- Espera 20 segundos
        task.wait(20)

        -- Pegar Sugar e Gelatin
        pegarItem("sugar")
        apertarE()
        pegarItem("gelatin")
        apertarE()

        -- Espera mais 20 segundos (total 40)
        task.wait(20)

        -- Pegar Empty Bag
        pegarItem("empty bag")
        apertarE()
    end
end)
