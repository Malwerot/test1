local Kavo = {}
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}

-- Função de arrastar
function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                         framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- Tema vermelho topográfico
local BH4LTheme = {
    SchemeColor = Color3.fromRGB(200, 30, 30),
    Background = Color3.fromRGB(255, 70, 70),
    Header = Color3.fromRGB(150, 20, 20),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(180, 40, 40)
}

local LibName = "BH4L UI"

function Kavo:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

-- Criação da biblioteca
function Kavo.CreateLib(kavName, themeList)
    kavName = "BH4L UI"
    themeList = BH4LTheme

    -- Remove instâncias antigas
    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.Position = UDim2.new(0.336, 0, 0.275, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)

    -- Overlay topográfico
    local topoOverlay = Instance.new("ImageLabel")
    topoOverlay.Parent = Main
    topoOverlay.Size = UDim2.new(1,0,1,0)
    topoOverlay.Image = "rbxassetid://<ID_DA_TEXTURA_TOPOGRAFICA>"
    topoOverlay.ImageTransparency = 0.85
    topoOverlay.ZIndex = 0

    -- Cabeçalho
    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    MainHeader.Size = UDim2.new(0, 525, 0, 29)

    local title = Instance.new("TextLabel")
    title.Parent = MainHeader
    title.Text = kavName
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = themeList.TextColor
    title.Size = UDim2.new(0, 200, 0, 29)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão de fechar
    local close = Instance.new("ImageButton")
    close.Parent = MainHeader
    close.Position = UDim2.new(0.95, 0, 0.1, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.Image = "rbxassetid://3926305904"
    close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tabs e seções seguem a mesma lógica original
    -- (mantendo animações, botões, callbacks etc.)
end
