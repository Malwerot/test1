local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Carregar UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("XFC AutoFarm", "DarkTheme")

-- Variáveis de controle
local autoFarmEnabled = false
local farmConnection = nil

-- Lista de itens e tempos
local farmSteps = {
    {item = "Water", delay = 0},
    {item = "Sugar Block Bag", delay = 20},
    {item = "Gelatin", delay = 20},
    {item = "Empty Bag", delay = 40}
}

-- Função para equipar item
local function equipItem(itemName)
    local character = LocalPlayer.Character
    local tool = LocalPlayer.Backpack:FindFirstChild(itemName)
    if tool and character then
        local hum = character:FindFirstChild("Humanoid")
        if hum then
            hum:EquipTool(tool)
            return true
        end
    end
    return false
end

-- Função para apertar E (Cooking Pot)
local function pressE()
    pcall(function()
        local interior = workspace.Map.Houses.WH1:FindFirstChild("Interior")
        if not interior then return end
        for _, child in ipairs(interior:GetChildren()) do
            if child.Name == "Cooking Pot" then
                local att = child:FindFirstChild("Attachment")
                local pp = att and att:FindFirstChild("ProximityPrompt")
                if pp then fireproximityprompt(pp) return end
            end
        end
    end)
end

-- Função principal de farm
local function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    farmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then
            farmConnection:Disconnect()
            farmConnection = nil
            return
        end

        -- Executa sequência
        task.spawn(function()
            for _, step in ipairs(farmSteps) do
                if not autoFarmEnabled then break end
                if step.delay > 0 then task.wait(step.delay) end
                local success = equipItem(step.item)
                if success then
                    task.wait(0.3) -- delay de equip
                    pressE()
                    print("Usando item:", step.item)
                else
                    print("Item não encontrado:", step.item)
                end
            end
        end)
    end)
end

local function stopAutoFarm()
    autoFarmEnabled = false
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
end

-- UI
local Tab = Window:NewTab("AutoFarm")
local Section = Tab:NewSection("Controle")

Section:NewToggle("Ativar Autofarm", "", function(state)
    autoFarmEnabled = state
    if state then
        startAutoFarm()
    else
        stopAutoFarm()
    end
end)

Section:NewButton("Inventário", "", function()
    for i, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            print(i .. ". " .. item.Name)
        end
    end
end)
