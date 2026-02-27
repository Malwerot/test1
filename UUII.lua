-- bh4l pluh hub - Auto Farm UI (Red Dark Camouflage Theme)
-- Base: Kavo UI modificada

local Kavo = {}
local input = game:GetService("UserInputService")

-- Função para arrastar UI
function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = inp.Position
            framePos = parent.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = inp
        end
    end)

    input.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local delta = inp.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                        framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Tema custom Red Dark Camuflado
local RedDarkCamouflage = {
    SchemeColor   = Color3.fromRGB(200, 30, 30),
    Background    = Color3.fromRGB(25, 10, 10),
    Header        = Color3.fromRGB(40, 0, 0),
    TextColor     = Color3.fromRGB(255, 230, 230),
    ElementColor  = Color3.fromRGB(50, 15, 15)
}

local LibName = "Bh4lPluhHub_" .. math.random(1000,9999)

function Kavo:CreateLib(kavName, themeList)
    themeList = RedDarkCamouflage
    kavName = kavName or "bh4l pluh hub"

    -- Remove UI antiga
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
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.Position = UDim2.new(0.3, 0, 0.25, 0)
    Main.Size = UDim2.new(0, 600, 0, 400)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local Header = Instance.new("Frame")
    Header.Parent = Main
    Header.BackgroundColor3 = themeList.Header
    Header.Size = UDim2.new(1, 0, 0, 40)

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.02, 0, 0.15, 0)
    Title.Size = UDim2.new(0.5, 0, 0.7, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = kavName .. " 🔥"
    Title.TextColor3 = themeList.TextColor
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton")
    Close.Parent = Header
    Close.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    Close.Position = UDim2.new(0.94, 0, 0.15, 0)
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Font = Enum.Font.Gotham
    Close.Text = "X"
    Close.TextColor3 = Color3.new(1,1,1)
    Close.TextSize = 20
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    Kavo:DraggingEnabled(Header, Main)

    -- Fundo camuflado/topográfico
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.ImageTransparency = 0.8
    bg.Image = "rbxassetid://10819100745" -- ID exemplo
    bg.ImageColor3 = Color3.fromRGB(120, 0, 0)
    bg.ScaleType = Enum.ScaleType.Tile
    bg.TileSize = UDim2.new(0, 600, 0, 600)
    bg.ZIndex = -1
    bg.Parent = Main

    -- Tabs container
    local Tabs = Instance.new("Frame")
    Tabs.Parent = Main
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0, 0, 0, 45)
    Tabs.Size = UDim2.new(1, 0, 1, -45)

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = Tabs
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)

    -- AutoFarm Tab
    local AutoFarmTab = Instance.new("TextButton")
    AutoFarmTab.Parent = Tabs
    AutoFarmTab.BackgroundColor3 = themeList.SchemeColor
    AutoFarmTab.Size = UDim2.new(0, 150, 0, 40)
    AutoFarmTab.Font = Enum.Font.GothamSemibold
    AutoFarmTab.Text = "Auto Farm"
    AutoFarmTab.TextColor3 = themeList.TextColor
    AutoFarmTab.TextSize = 18

    -- Config Tab
    local ConfigTab = Instance.new("TextButton")
    ConfigTab.Parent = Tabs
    ConfigTab.BackgroundColor3 = themeList.SchemeColor
    ConfigTab.Size = UDim2.new(0, 150, 0, 40)
    ConfigTab.Font = Enum.Font.GothamSemibold
    ConfigTab.Text = "Configurações"
    ConfigTab.TextColor3 = themeList.TextColor
    ConfigTab.TextSize = 18

    -- Extras Tab
    local ExtrasTab = Instance.new("TextButton")
    ExtrasTab.Parent = Tabs
    ExtrasTab.BackgroundColor3 = themeList.SchemeColor
    ExtrasTab.Size = UDim2.new(0, 150, 0, 40)
    ExtrasTab.Font = Enum.Font.GothamSemibold
    ExtrasTab.Text = "Extras"
    ExtrasTab.TextColor3 = themeList.TextColor
    ExtrasTab.TextSize = 18

    -- Conteúdo AutoFarm
    local Content = Instance.new("ScrollingFrame")
    Content.Parent = Main
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 10, 0, 90)
    Content.Size = UDim2.new(1, -20, 1, -100)
    Content.ScrollBarThickness = 6

    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = Content
    ContentList.Padding = UDim.new(0, 8)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Toggle AutoFarm
    local ToggleAuto = Instance.new("TextButton")
    ToggleAuto.Parent = Content
    ToggleAuto.BackgroundColor3 = themeList.ElementColor
    ToggleAuto.Size = UDim2.new(1, 0, 0, 50)
    ToggleAuto.Font = Enum.Font.Gotham
    ToggleAuto.Text = "Auto Farm: OFF"
    ToggleAuto.TextColor3 = themeList.TextColor
    ToggleAuto.TextSize = 20

    local toggled = false
    ToggleAuto.MouseButton1Click:Connect(function()
        toggled = not toggled
        ToggleAuto.Text = "Auto Farm: "
