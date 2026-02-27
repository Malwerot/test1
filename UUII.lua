--// CopilotUI Library
--// Uma recriação inspirada no Kavo, mas com identidade própria
--// Focada em clareza, estilo moderno e modularidade

local CopilotUI = {}
local Utility = {}
local Objects = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")

-- Função para arrastar janelas
function CopilotUI:EnableDragging(frame, parent)
    parent = parent or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

    frame.InputBegan:Connect(function(uInput)
        if uInput.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = uInput.Position
            framePos = parent.Position
            uInput.Changed:Connect(function()
                if uInput.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(uInput)
        if uInput.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = uInput
        end
    end)

    input.InputChanged:Connect(function(uInput)
        if uInput == dragInput and dragging then
            local delta = uInput.Position - mousePos
            parent.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Função utilitária para tween
function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- Temas modernos
local themes = {
    SchemeColor = Color3.fromRGB(80, 120, 200),
    Background = Color3.fromRGB(35, 40, 50),
    Header = Color3.fromRGB(25, 30, 40),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(45, 50, 60)
}

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(30, 30, 30)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255,255,255),
        Header = Color3.fromRGB(220, 220, 220),
        TextColor = Color3.fromRGB(0,0,0),
        ElementColor = Color3.fromRGB(240, 240, 240)
    },
    CyberTheme = {
        SchemeColor = Color3.fromRGB(0, 255, 200),
        Background = Color3.fromRGB(10, 15, 20),
        Header = Color3.fromRGB(0, 40, 40),
        TextColor = Color3.fromRGB(200,255,255),
        ElementColor = Color3.fromRGB(20, 40, 50)
    },
    NeonTheme = {
        SchemeColor = Color3.fromRGB(255, 0, 200),
        Background = Color3.fromRGB(30, 0, 40),
        Header = Color3.fromRGB(50, 0, 70),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(60, 0, 90)
    }
}

-- Configuração inicial
local SettingsT = {}
local Name = "CopilotConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = "CopilotUI_"..tostring(math.random(1000,9999))

-- Função para alternar visibilidade
function CopilotUI:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

-- Criação da biblioteca
function CopilotUI.CreateLib(uiName, themeList)
    uiName = uiName or "Copilot Library"
    themeList = themeList or themes

    if type(themeList) == "string" and themeStyles[themeList] then
        themeList = themeStyles[themeList]
    end

    -- Garantir valores padrão
    themeList.SchemeColor = themeList.SchemeColor or Color3.fromRGB(80,120,200)
    themeList.Background = themeList.Background or Color3.fromRGB(35,40,50)
    themeList.Header = themeList.Header or Color3.fromRGB(25,30,40)
    themeList.TextColor = themeList.TextColor or Color3.fromRGB(255,255,255)
    themeList.ElementColor = themeList.ElementColor or Color3.fromRGB(45,50,60)

    -- Criar elementos principais
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.Position = UDim2.new(0.3, 0, 0.3, 0)
    Main.Size = UDim2.new(0, 550, 0, 350)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = Main

    local Header = Instance.new("Frame")
    Header.Parent = Main
    Header.BackgroundColor3 = themeList.Header
    Header.Size = UDim2.new(1, 0, 0, 35)

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.Text = uiName
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = themeList.TextColor
    Title.Position = UDim2.new(0.02,0,0,0)
    Title.Size = UDim2.new(0.5,0,1,0)
    Title.BackgroundTransparency = 1

    CopilotUI:EnableDragging(Header, Main)

    -- Tabs container
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = Main
    TabContainer.Position = UDim2.new(0,0,0.1,0)
    TabContainer.Size = UDim2.new(0,150,0,315)
    TabContainer.BackgroundColor3 = themeList.Header

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local Pages = Instance.new("Frame")
    Pages.Parent = Main
    Pages.Position = UDim2.new(0.28,0,0.1,0)
    Pages.Size = UDim2.new(0.72,0,0.9,0)
    Pages.BackgroundTransparency = 1

    local FolderPages = Instance.new("Folder")
    FolderPages.Parent = Pages
    FolderPages.Name = "Pages"

    -- Função para criar tabs
    local Tabs = {}
    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = TabContainer
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(1,0,0,30)
        tabButton.BackgroundColor3 = themeList.SchemeColor
        tabButton.TextColor3 = themeList.TextColor
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14

        local page = Instance.new("ScrollingFrame")
        page.Parent = FolderPages
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.ScrollBarThickness = 6
        page.BackgroundTransparency = 1

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Parent = page
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0,5)

        tabButton.MouseButton1Click:Connect(function()
            for _,p in pairs(FolderPages:GetChildren()) do
                p.Visible = false
            end
            page.Visible = true
        end)

        local Sections = {}
        function Sections:NewSection(secName)
            secName = secName
