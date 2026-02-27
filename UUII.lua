-- // to the 2 peoplee who are constantly watching this repo, get a life yall weird.
-- // to the people who are still forking this unoptimized garbage, if you want a custom optimized rewrite for $, hmu on discord: federal6768 or federal.

local Kavo = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

local Utility = {}
local Objects = {}

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    -- stolen from wally or kiriot, kek
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

local themes = {
    SchemeColor = Color3.fromRGB(74, 99, 135),
    Background = Color3.fromRGB(36, 37, 43),
    Header = Color3.fromRGB(28, 29, 34),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(32, 32, 38)
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255,255,255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0,0,0),
        ElementColor = Color3.fromRGB(224, 224, 224)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    -- ... (outros temas mantidos originais)
}

-- Tema custom RED DARK com vibe agressiva (vermelho sangue + escuro)
local RedDarkTopo = {
    SchemeColor   = Color3.fromRGB(220, 20, 60),     -- Vermelho vivo para acentos/botões/toggles
    Background    = Color3.fromRGB(18, 6, 6),        -- Fundo principal vermelho bem escuro
    Header        = Color3.fromRGB(30, 0, 0),        -- Header e sidebar quase preto com tom vermelho
    TextColor     = Color3.fromRGB(245, 220, 220),   -- Texto claro pra contraste
    ElementColor  = Color3.fromRGB(40, 10, 10)       -- Elementos (botões etc) vermelho escuro médio
}

local oldTheme = ""
local SettingsT = {}
local Name = "KavoConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function Kavo:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

function Kavo.CreateLib(kavName, themeList)
    if not themeList then themeList = themes end
    
    -- Força o tema custom RED DARK
    themeList = RedDarkTopo

    kavName = kavName or "Library"
    table.insert(Kavo, kavName)

    for i,v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == kavName then
            v:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local close = Instance.new("ImageButton")
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")
    local blurFrame = Instance.new("Frame")

    Kavo:DraggingEnabled(MainHeader, Main)

    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.0222222228, 0, -0.0371747203, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.336503863, 0, 0.275485456, 0)
    Main.Size = UDim2.new(0, 525, 0, 318)

    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    -- ... (resto do código original mantido, pulando pra parte final pra adicionar o fundo topográfico)

    -- Após criar a UI, adiciona o fundo topográfico semi-transparente
    spawn(function()
        wait(1.2)  -- Espera UI carregar

        local targetGui = ScreenGui  -- Já temos a ScreenGui

        if targetGui then
            local bg = Instance.new("ImageLabel")
            bg.Name = "TopoBackground"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundTransparency = 1
            bg.ImageTransparency = 0.78  -- Semi-transparente pra não esconder texto/botões
            bg.Image = "rbxassetid://10819100745"  -- ID exemplo topographic. TROQUE POR UM MELHOR (procure "topographic red dark" no Marketplace)
            bg.ImageColor3 = Color3.fromRGB(100, 0, 0)  -- Tint vermelho sangue/escuro
            bg.ScaleType = Enum.ScaleType.Tile  -- Repete como estampa
            bg.TileSize = UDim2.new(0, 512, 0, 512)  -- Ajuste pra pattern ficar bom (maior = menos repetição)
            bg.ZIndex = -20  -- Bem atrás de tudo
            bg.Parent = targetGui

            print("Fundo topográfico vermelho adicionado! Troque o ID se quiser um melhor.")
        end
    end)

    -- Título personalizado
    title.Text = "bh4l pluh hub"  -- Alterado aqui

    -- ... (o resto do código original continua igual, com as funções NewTab, NewSection, NewButton etc)

    return Kavo  -- Retorna a lib modificada
end

-- Uso exemplo no final (cole isso no seu script depois da lib)
local Window = Kavo:CreateLib("bh4l pluh hub", RedDarkTopo)  -- Tema vermelho dark topo

local Tab1 = Window:NewTab("Principal")
local Section = Tab1:NewSection("bh4l pluh hub - Red Dark Topo 🔥")

Section:NewLabel("Estilo vermelho sangue com estampa topográfica no fundo 🩸🗺️")
Section:NewButton("Teste Vermelho", "Clica pra ver", function()
    print("Hub vermelho ativado!")
end)

-- Adicione mais tabs/elementos como quiser
