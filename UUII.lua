-- // bh4l pluh hub - Auto Farm UI (Red Dark Topographic Theme)
-- Base: Kavo UI modificada

local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}

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
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- Tema custom RED DARK agressivo com fundo topo
local RedDarkTopo = {
    SchemeColor   = Color3.fromRGB(220, 20, 60),     -- Vermelho vivo (botões, toggles, etc)
    Background    = Color3.fromRGB(18, 6, 6),        -- Fundo principal vermelho escuro
    Header        = Color3.fromRGB(30, 0, 0),        -- Header/sidebar quase preto-vermelho
    TextColor     = Color3.fromRGB(245, 220, 220),   -- Texto claro
    ElementColor  = Color3.fromRGB(40, 10, 10)       -- Elementos fundo
}

local LibName = "Bh4lPluhHub_" .. math.random(1000,9999)

function Kavo:ToggleUI()
    local gui = game.CoreGui:FindFirstChild(LibName)
    if gui then
        gui.Enabled = not gui.Enabled
    end
end

function Kavo:CreateLib(kavName, themeList)
    themeList = RedDarkTopo  -- Força o tema vermelho

    kavName = kavName or "bh4l pluh hub"

    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == LibName then
            v:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = LibName
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.3, 0, 0.25, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    MainHeader.Size = UDim2.new(1, 0, 0, 40)

    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0.02, 0, 0.15, 0)
    title.Size = UDim2.new(0.5, 0, 0.7, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = "bh4l pluh hub"
    title.TextColor3 = themeList.TextColor
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    close.Position = UDim2.new(0.94, 0, 0.15, 0)
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Font = Enum.Font.Gotham
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextSize = 20

    close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    Kavo:DraggingEnabled(MainHeader, Main)

    -- Fundo topográfico (estampa)
    spawn(function()
        wait(1.5)
        if ScreenGui then
            local bg = Instance.new("ImageLabel")
            bg.Name = "TopoBG"
            bg.Size = UDim2.new(1,0,1,0)
            bg.Position = UDim2.new(0,0,0,0)
            bg.BackgroundTransparency = 1
            bg.ImageTransparency = 0.75  -- Ajuste se ficar muito forte (0.6 ~ 0.85)
            bg.Image = "rbxassetid://10819100745"  -- TROQUE POR UM ID VERMELHO/TOPO MELHOR!
            bg.ImageColor3 = Color3.fromRGB(120, 0, 0)  -- Tint vermelho sangue
            bg.ScaleType = Enum.ScaleType.Tile
            bg.TileSize = UDim2.new(0, 600, 0, 600)  -- Ajuste o tamanho do repeat
            bg.ZIndex = -50
            bg.Parent = ScreenGui
            print("Fundo topográfico vermelho aplicado!")
        end
    end)

    -- Aqui você pode adicionar o resto da estrutura da Kavo (tabs, sections, etc)
    -- Exemplo simples de tab para auto farm

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "Tabs"
    TabContainer.Parent = Main
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.Size = UDim2.new(1, 0, 1, -45)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Tab de Auto Farm (exemplo)
    local AutoFarmTab = Instance.new("TextButton")
    AutoFarmTab.Name = "AutoFarmTab"
    AutoFarmTab.Parent = TabContainer
    AutoFarmTab.BackgroundColor3 = themeList.SchemeColor
    AutoFarmTab.Size = UDim2.new(0, 150, 0, 40)
    AutoFarmTab.Font = Enum.Font.GothamSemibold
    AutoFarmTab.Text = "Auto Farm"
    AutoFarmTab.TextColor3 = themeList.TextColor
    AutoFarmTab.TextSize = 18

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "Content"
    ContentFrame.Parent = Main
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 10, 0, 90)
    ContentFrame.Size = UDim2.new(1, -20, 1, -100)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.ScrollBarThickness = 6

    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = ContentFrame
    ContentList.Padding = UDim.new(0, 8)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Função para atualizar canvas size
    local function updateCanvas()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
    end

    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

    -- Elementos de Auto Farm (exemplos)

    local ToggleAuto = Instance.new("TextButton")
    ToggleAuto.Name = "ToggleAuto"
    ToggleAuto.Parent = ContentFrame
    ToggleAuto.BackgroundColor3 = themeList.ElementColor
    ToggleAuto.Size = UDim2.new(1, 0, 0, 50)
    ToggleAuto.Font = Enum.Font.Gotham
    ToggleAuto.Text = "Auto Farm: OFF"
    ToggleAuto.TextColor3 = themeList.TextColor
    ToggleAuto.TextSize = 20

    local toggled = false
    ToggleAuto.MouseButton1Click:Connect(function()
        toggled = not toggled
        ToggleAuto.Text = "Auto Farm: " .. (toggled and "ON" or "OFF")
        -- Coloque aqui a lógica real do seu auto farm
        print("Auto Farm " .. (toggled and "ativado" or "desativado"))
    end)

    local SliderSpeed = Instance.new("TextLabel")  -- Placeholder simples para slider (você pode expandir)
    SliderSpeed.Parent = ContentFrame
    SliderSpeed.BackgroundColor3 = themeList.ElementColor
    SliderSpeed.Size = UDim2.new(1, 0, 0, 40)
    SliderSpeed.Text = "Farm Speed: 1x"
    SliderSpeed.TextColor3 = themeList.TextColor
    SliderSpeed.TextSize = 18

    -- Mais elementos: buttons, toggles, etc para seu auto farm

    local ButtonTeleport = Instance.new("TextButton")
    ButtonTeleport.Parent = ContentFrame
    ButtonTeleport.BackgroundColor3 = themeList.SchemeColor
    ButtonTeleport.Size = UDim2.new(1, 0, 0, 50)
    ButtonTeleport.Text = "Teleport to Farm Zone"
    ButtonTeleport.TextColor3 = Color3.new(1,1,1)
    ButtonTeleport.TextSize = 20

    ButtonTeleport.MouseButton1Click:Connect(function()
        -- Lógica de teleport aqui
        print("Teleport executado!")
    end)

    updateCanvas()

    print("bh4l pluh hub - Auto Farm UI carregada (Red Topo Style)")
    return Kavo
end

-- Inicializa a UI
Kavo:CreateLib("bh4l pluh hub", RedDarkTopo)

-- Para toggle com tecla (ex: Insert)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Kavo:ToggleUI()
    end
end)
