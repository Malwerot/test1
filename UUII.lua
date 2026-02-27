local Kavo = {}
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
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

-- Tema custom Red Dark
local RedDarkTopo = {
    SchemeColor   = Color3.fromRGB(220, 20, 60),
    Background    = Color3.fromRGB(18, 6, 6),
    Header        = Color3.fromRGB(30, 0, 0),
    TextColor     = Color3.fromRGB(245, 220, 220),
    ElementColor  = Color3.fromRGB(40, 10, 10)
}

-- Criação da Lib
function Kavo:CreateLib(kavName, themeList)
    themeList = themeList or RedDarkTopo
    kavName = kavName or "CustomHub"

    -- Remove UI antiga
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end

    -- ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = kavName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Frame principal
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 525, 0, 318)
    Main.Position = UDim2.new(0.3, 0, 0.3, 0)
    Main.BackgroundColor3 = themeList.Background
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = themeList.Header
    Header.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = kavName
    Title.TextColor3 = themeList.TextColor
    Title.Font = Enum.Font.SourceSansBold
    Title.TextScaled = true
    Title.Parent = Header

    -- Botão fechar
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 40, 1, 0)
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.Text = "X"
    Close.TextColor3 = themeList.TextColor
    Close.BackgroundColor3 = themeList.ElementColor
    Close.Parent = Header
    Close.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)

    -- Fundo topográfico
    local bg = Instance.new("ImageLabel")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.ImageTransparency = 0.8
    bg.Image = "rbxassetid://10819100745" -- ID exemplo
    bg.ImageColor3 = Color3.fromRGB(100, 0, 0)
    bg.ScaleType = Enum.ScaleType.Tile
    bg.TileSize = UDim2.new(0, 512, 0, 512)
    bg.ZIndex = -1
    bg.Parent = Main

    -- Permite arrastar
    self:DraggingEnabled(Header, Main)

    -- Retorna objeto com funções
    local Lib = {}
    function Lib:NewTab(name)
        local Tab = Instance.new("Frame")
        Tab.Size = UDim2.new(1, 0, 1, -40)
        Tab.Position = UDim2.new(0, 0, 0, 40)
        Tab.BackgroundTransparency = 1
        Tab.Name = name
        Tab.Parent = Main
        return {
            NewSection = function(_, secName)
                local Section = Instance.new("TextLabel")
                Section.Size = UDim2.new(1, 0, 0, 30)
                Section.Text = secName
                Section.TextColor3 = themeList.TextColor
                Section.BackgroundTransparency = 1
                Section.Parent = Tab
                return {
                    NewLabel = function(_, txt)
                        local Label = Instance.new("TextLabel")
                        Label.Size = UDim2.new(1, 0, 0, 25)
                        Label.Text = txt
                        Label.TextColor3 = themeList.TextColor
                        Label.BackgroundTransparency = 1
                        Label.Parent = Tab
                    end,
                    NewButton = function(_, txt, desc, callback)
                        local Btn = Instance.new("TextButton")
                        Btn.Size = UDim2.new(1, 0, 0, 30)
                        Btn.Text = txt
                        Btn.TextColor3 = themeList.TextColor
                        Btn.BackgroundColor3 = themeList.ElementColor
                        Btn.Parent = Tab
                        Btn.MouseButton1Click:Connect(callback)
                    end
                }
            end
        }
    end

    return Lib
end

-- Exemplo de uso
local Window = Kavo:CreateLib("bh4l pluh hub", RedDarkTopo)
local Tab1 = Window:NewTab("Principal")
local Section = Tab1:NewSection("UI Custom 🔥")

Section:NewLabel("Estilo vermelho sangue com fundo topográfico 🩸")
Section:NewButton("Teste", "Clique aqui", function()
    print("Botão custom funcionando!")
end)
