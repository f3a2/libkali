local KaliUI = {}
KaliUI.__index = KaliUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Viewport = workspace.CurrentCamera.ViewportSize

-- Constants
local COLORS = {
    Background = Color3.fromRGB(20, 20, 30),
    DarkBackground = Color3.fromRGB(15, 15, 25),
    LightBackground = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(180, 180, 200),
    Accent = Color3.fromRGB(130, 50, 255),
    AccentDark = Color3.fromRGB(100, 40, 200),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 70),
    Error = Color3.fromRGB(255, 70, 70),
    Highlight = Color3.fromRGB(40, 40, 60)
}

local FONTS = {
    Regular = Enum.Font.Gotham,
    SemiBold = Enum.Font.GothamSemibold,
    Bold = Enum.Font.GothamBold,
    Medium = Enum.Font.GothamMedium
}

-- Utility Functions
local function createTween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    return tween
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function createShadow(parent, size, position, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = size or UDim2.new(1, 12, 1, 12)
    shadow.Position = position or UDim2.new(0, -6, 0, -6)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or COLORS.Background),
        ColorSequenceKeypoint.new(1, color2 or COLORS.DarkBackground)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function makeDraggable(dragObject, dragTarget)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Main UI Creation
function KaliUI.new(options)
    options = options or {}
    
    local name = options.Name or "Kali Hub"
    local version = options.Version or "1.0"
    local theme = options.Theme or "Dark"
    local sizeX = options.SizeX or 650
    local sizeY = options.SizeY or 400
    
    -- Check if UI already exists
    if game:GetService("CoreGui"):FindFirstChild("KaliUILibrary") then
        game:GetService("CoreGui"):FindFirstChild("KaliUILibrary"):Destroy()
    end
    
    -- Create main UI container
    local KaliUILibrary = Instance.new("ScreenGui")
    KaliUILibrary.Name = "KaliUILibrary"
    KaliUILibrary.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KaliUILibrary.ResetOnSpawn = false
    
    -- Try to set parent to CoreGui
    local success, err = pcall(function()
        KaliUILibrary.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        KaliUILibrary.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, sizeX, 0, sizeY)
    MainFrame.Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = KaliUILibrary
    
    createCorner(MainFrame, 8)
    createShadow(MainFrame)
    
    -- Create background gradient
    local BackgroundGradient = createGradient(MainFrame, COLORS.Background, COLORS.DarkBackground, 135)
    
    -- Create title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = COLORS.DarkBackground
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = MainFrame
    
    createCorner(TitleBar, 8)
    
    -- Create bottom cover to fix corners
    local BottomCover = Instance.new("Frame")
    BottomCover.Name = "BottomCover"
    BottomCover.Size = UDim2.new(1, 0, 0.5, 0)
    BottomCover.Position = UDim2.new(0, 0, 0.5, 0)
    BottomCover.BackgroundColor3 = COLORS.DarkBackground
    BottomCover.BorderSizePixel = 0
    BottomCover.ZIndex = 2
    BottomCover.Parent = TitleBar
    
    -- Create title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = COLORS.Text
    Title.TextSize = 16
    Title.Font = FONTS.Bold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.Parent = TitleBar
    
    -- Create version label
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Name = "VersionLabel"
    VersionLabel.Size = UDim2.new(0, 50, 1, 0)
    VersionLabel.Position = UDim2.new(0, 200, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v" .. version
    VersionLabel.TextColor3 = COLORS.Accent
    VersionLabel.TextSize = 14
    VersionLabel.Font = FONTS.SemiBold
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.ZIndex = 3
    VersionLabel.Parent = TitleBar
    
    -- Create close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = COLORS.Error
    CloseButton.BackgroundTransparency = 0.8
    CloseButton.Text = "×"
    CloseButton.TextColor3 = COLORS.Text
    CloseButton.TextSize = 20
    CloseButton.Font = FONTS.Bold
    CloseButton.ZIndex = 3
    CloseButton.Parent = TitleBar
    
    createCorner(CloseButton, 6)
    
    -- Create minimize button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -80, 0, 5)
    MinimizeButton.BackgroundColor3 = COLORS.Warning
    MinimizeButton.BackgroundTransparency = 0.8
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = COLORS.Text
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = FONTS.Bold
    MinimizeButton.ZIndex = 3
    MinimizeButton.Parent = TitleBar
    
    createCorner(MinimizeButton, 6)
    
    -- Create content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 2
    ContentContainer.Parent = MainFrame
    
    -- Create tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 160, 1, 0)
    TabContainer.BackgroundColor3 = COLORS.DarkBackground
    TabContainer.BackgroundTransparency = 0.4
    TabContainer.BorderSizePixel = 0
    TabContainer.ZIndex = 2
    TabContainer.Parent = ContentContainer
    
    -- Create tab list
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, -10)
    TabList.Position = UDim2.new(0, 0, 0, 10)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = COLORS.Accent
    TabList.ZIndex = 2
    TabList.Parent = TabContainer
    
    -- Create tab list layout
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    -- Create tab list padding
    local TabListPadding = Instance.new("UIPadding")
    TabListPadding.PaddingTop = UDim.new(0, 5)
    TabListPadding.PaddingBottom = UDim.new(0, 5)
    TabListPadding.Parent = TabList
    
    -- Create tab content container
    local TabContentContainer = Instance.new("Frame")
    TabContentContainer.Name = "TabContentContainer"
    TabContentContainer.Size = UDim2.new(1, -160, 1, 0)
    TabContentContainer.Position = UDim2.new(0, 160, 0, 0)
    TabContentContainer.BackgroundTransparency = 1
    TabContentContainer.ZIndex = 2
    TabContentContainer.Parent = ContentContainer
    
    -- Create floating button for minimized state
    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = "FloatingButton"
    FloatingButton.Size = UDim2.new(0, 50, 0, 50)
    FloatingButton.Position = UDim2.new(0, 20, 0, 20)
    FloatingButton.BackgroundColor3 = COLORS.Accent
    FloatingButton.Image = "rbxassetid://7733658504" -- Placeholder icon
    FloatingButton.ImageColor3 = COLORS.Text
    FloatingButton.ImageTransparency = 0.2
    FloatingButton.Visible = false
    FloatingButton.ZIndex = 10
    FloatingButton.Parent = KaliUILibrary
    
    createCorner(FloatingButton, 25)
    createShadow(FloatingButton)
    
    -- Make UI draggable
    makeDraggable(TitleBar, MainFrame)
    
    -- Button hover effects
    local function applyButtonEffects(button, baseColor, hoverColor)
        button.MouseEnter:Connect(function()
            createTween(button, {BackgroundTransparency = 0.6}, 0.2):Play()
        end)
        
        button.MouseLeave:Connect(function()
            createTween(button, {BackgroundTransparency = 0.8}, 0.2):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            createTween(button, {BackgroundTransparency = 0.4}, 0.1):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            createTween(button, {BackgroundTransparency = 0.6}, 0.1):Play()
        end)
    end
    
    applyButtonEffects(CloseButton, COLORS.Error, COLORS.Error)
    applyButtonEffects(MinimizeButton, COLORS.Warning, COLORS.Warning)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        createTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        wait(0.3)
        KaliUILibrary:Destroy()
    end)
    
    -- Minimize button functionality
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- Save position before minimizing
            local currentPos = MainFrame.Position
            
            -- Minimize animation
            createTween(MainFrame, {Size = UDim2.new(0, sizeX, 0, 0), Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset + sizeY/2)}, 0.3, Enum.EasingStyle.Quint):Play()
            
            -- Show floating button
            wait(0.3)
            MainFrame.Visible = false
            FloatingButton.Position = UDim2.new(0, 20, 0, 20)
            FloatingButton.Visible = true
            
            -- Floating button animation
            createTween(FloatingButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
        else
            -- Hide floating button
            createTween(FloatingButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
            wait(0.2)
            FloatingButton.Visible = false
            
            -- Show main frame
            MainFrame.Visible = true
            
            -- Restore animation
            createTween(MainFrame, {Size = UDim2.new(0, sizeX, 0, sizeY), Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2)}, 0.3, Enum.EasingStyle.Quint):Play()
        end
    end)
    
    -- Floating button functionality
    FloatingButton.MouseButton1Click:Connect(function()
        -- Hide floating button
        createTween(FloatingButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
        wait(0.2)
        FloatingButton.Visible = false
        
        -- Show main frame
        MainFrame.Visible = true
        minimized = false
        
        -- Restore animation
        createTween(MainFrame, {Size = UDim2.new(0, sizeX, 0, sizeY), Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2)}, 0.3, Enum.EasingStyle.Quint):Play()
    end)
    
    -- Make floating button draggable
    makeDraggable(FloatingButton, FloatingButton)
    
    -- Library object
    local library = setmetatable({
        ScreenGui = KaliUILibrary,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        TabList = TabList,
        TabContentContainer = TabContentContainer,
        Tabs = {},
        ActiveTab = nil
    }, KaliUI)
    
    -- Create notification system
    library.Notifications = library:CreateNotifications()
    
    return library
end

-- Create Tab
function KaliUI:Tab(name, icon)
    local tabIndex = #self.Tabs + 1
    
    -- Create tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 140, 0, 36)
    TabButton.BackgroundColor3 = COLORS.Background
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.ZIndex = 3
    TabButton.LayoutOrder = tabIndex
    TabButton.Parent = self.TabList
    
    createCorner(TabButton, 6)
    
    -- Create tab icon
    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 20, 0, 20)
    TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = icon or "rbxassetid://7733715400" -- Placeholder icon
    TabIcon.ImageColor3 = COLORS.SubText
    TabIcon.ZIndex = 4
    TabIcon.Parent = TabButton
    
    -- Create tab label
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Name = "Label"
    TabLabel.Size = UDim2.new(1, -40, 1, 0)
    TabLabel.Position = UDim2.new(0, 40, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = name
    TabLabel.TextColor3 = COLORS.SubText
    TabLabel.TextSize = 14
    TabLabel.Font = FONTS.SemiBold
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.ZIndex = 4
    TabLabel.Parent = TabButton
    
    -- Create tab content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 2
    TabContent.ScrollBarImageColor3 = COLORS.Accent
    TabContent.Visible = false
    TabContent.ZIndex = 2
    TabContent.Parent = self.TabContentContainer
    
    -- Create content layout
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = TabContent
    
    -- Create content padding
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 5)
    ContentPadding.PaddingBottom = UDim.new(0, 5)
    ContentPadding.Parent = TabContent
    
    -- Tab object
    local tab = {
        Button = TabButton,
        Icon = TabIcon,
        Label = TabLabel,
        Content = TabContent,
        Sections = {},
        Library = self
    }
    
    -- Tab button functionality
    TabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Add tab to library
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    -- Update tab list canvas size
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    
    -- Section function
    function tab:Section(name)
        local sectionIndex = #self.Sections + 1
        
        -- Create section container
        local SectionContainer = Instance.new("Frame")
        SectionContainer.Name = name .. "Section"
        SectionContainer.Size = UDim2.new(1, 0, 0, 36) -- Initial size, will be updated
        SectionContainer.BackgroundColor3 = COLORS.LightBackground
        SectionContainer.BackgroundTransparency = 0.2
        SectionContainer.BorderSizePixel = 0
        SectionContainer.ZIndex = 3
        SectionContainer.LayoutOrder = sectionIndex
        SectionContainer.Parent = self.Content
        
        createCorner(SectionContainer, 6)
        createStroke(SectionContainer, COLORS.Accent, 1, 0.9)
        
        -- Create section title
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Title"
        SectionTitle.Size = UDim2.new(1, -20, 0, 30)
        SectionTitle.Position = UDim2.new(0, 10, 0, 0)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Text = name
        SectionTitle.TextColor3 = COLORS.Text
        SectionTitle.TextSize = 14
        SectionTitle.Font = FONTS.Bold
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.ZIndex = 4
        SectionTitle.Parent = SectionContainer
        
        -- Create section content
        local SectionContent = Instance.new("Frame")
        SectionContent.Name = "Content"
        SectionContent.Size = UDim2.new(1, -20, 1, -36)
        SectionContent.Position = UDim2.new(0, 10, 0, 36)
        SectionContent.BackgroundTransparency = 1
        SectionContent.ZIndex = 4
        SectionContent.Parent = SectionContainer
        
        -- Create content layout
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Padding = UDim.new(0, 8)
        SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Parent = SectionContent
        
        -- Create content padding
        local SectionPadding = Instance.new("UIPadding")
        SectionPadding.PaddingTop = UDim.new(0, 5)
        SectionPadding.PaddingBottom = UDim.new(0, 5)
        SectionPadding.Parent = SectionContent
        
        -- Section object
        local section = {
            Container = SectionContainer,
            Content = SectionContent,
            Layout = SectionLayout,
            Elements = {},
            Tab = self
        }
        
        -- Update section size based on content
        local function updateSectionSize()
            SectionContainer.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 46)
            
            -- Update tab content canvas size
            self.Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end
        
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
        
        -- Button function
        function section:Button(text, description, callback)
            local elementIndex = #self.Elements + 1
            
            -- Create button container
            local ButtonContainer = Instance.new("Frame")
            ButtonContainer.Name = text .. "Button"
            ButtonContainer.Size = UDim2.new(1, 0, 0, description and 60 or 36)
            ButtonContainer.BackgroundTransparency = 1
            ButtonContainer.ZIndex = 5
            ButtonContainer.LayoutOrder = elementIndex
            ButtonContainer.Parent = self.Content
            
            -- Create button
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Size = UDim2.new(1, 0, 0, 36)
            Button.BackgroundColor3 = COLORS.Accent
            Button.BackgroundTransparency = 0.8
            Button.Text = ""
            Button.ZIndex = 6
            Button.Parent = ButtonContainer
            
            createCorner(Button, 6)
            
            -- Create button label
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Name = "Label"
            ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = text
            ButtonLabel.TextColor3 = COLORS.Text
            ButtonLabel.TextSize = 14
            ButtonLabel.Font = FONTS.SemiBold
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.ZIndex = 7
            ButtonLabel.Parent = Button
            
            -- Create description if provided
            if description then
                local Description = Instance.new("TextLabel")
                Description.Name = "Description"
                Description.Size = UDim2.new(1, 0, 0, 20)
                Description.Position = UDim2.new(0, 0, 0, 40)
                Description.BackgroundTransparency = 1
                Description.Text = description
                Description.TextColor3 = COLORS.SubText
                Description.TextSize = 12
                Description.Font = FONTS.Regular
                Description.TextXAlignment = Enum.TextXAlignment.Left
                Description.TextWrapped = true
                Description.ZIndex = 6
                Description.Parent = ButtonContainer
            end
            
            -- Button functionality
            Button.MouseEnter:Connect(function()
                createTween(Button, {BackgroundTransparency = 0.6}, 0.2):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                createTween(Button, {BackgroundTransparency = 0.8}, 0.2):Play()
            end)
            
            Button.MouseButton1Down:Connect(function()
                createTween(Button, {BackgroundTransparency = 0.4}, 0.1):Play()
            end)
            
            Button.MouseButton1Up:Connect(function()
                createTween(Button, {BackgroundTransparency = 0.6}, 0.1):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            -- Add to elements
            table.insert(self.Elements, ButtonContainer)
            updateSectionSize()
            
            return ButtonContainer
            end 
        
        -- Toggle function
        function section:Toggle(text, default, callback)
            local elementIndex = #self.Elements + 1
            local toggled = default or false
            
            -- Create toggle container
            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Name = text .. "Toggle"
            ToggleContainer.Size = UDim2.new(1, 0, 0, 36)
            ToggleContainer.BackgroundTransparency = 1
            ToggleContainer.ZIndex = 5
            ToggleContainer.LayoutOrder = elementIndex
            ToggleContainer.Parent = self.Content
            
            -- Create toggle button
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Text = ""
            ToggleButton.ZIndex = 6
            ToggleButton.Parent = ToggleContainer
            
            -- Create toggle label
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = COLORS.Text
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = FONTS.SemiBold
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.ZIndex = 7
            ToggleLabel.Parent = ToggleButton
            
            -- Create toggle indicator
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "Indicator"
            ToggleIndicator.Size = UDim2.new(0, 40, 0, 20)
            ToggleIndicator.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleIndicator.BackgroundColor3 = toggled and COLORS.Accent or COLORS.LightBackground
            ToggleIndicator.ZIndex = 7
            ToggleIndicator.Parent = ToggleButton
            
            createCorner(ToggleIndicator, 10)
            
            -- Create toggle knob
            local ToggleKnob = Instance.new("Frame")
            ToggleKnob.Name = "Knob"
            ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
            ToggleKnob.Position = UDim2.new(toggled and 1 or 0, toggled and -18 or 2, 0.5, -8)
            ToggleKnob.BackgroundColor3 = COLORS.Text
            ToggleKnob.ZIndex = 8
            ToggleKnob.Parent = ToggleIndicator
            
            createCorner(ToggleKnob, 8)
            
            -- Toggle functionality
            local function updateToggle()
                createTween(ToggleIndicator, {BackgroundColor3 = toggled and COLORS.Accent or COLORS.LightBackground}, 0.2):Play()
                createTween(ToggleKnob, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2):Play()
                
                if callback then
                    callback(toggled)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
            end)
            
            -- Add to elements
            table.insert(self.Elements, ToggleContainer)
            updateSectionSize()
            
            -- Return toggle object
            local toggleObj = {
                Container = ToggleContainer,
                Button = ToggleButton,
                Indicator = ToggleIndicator,
                Knob = ToggleKnob,
                Value = toggled,
                Set = function(self, value)
                    toggled = value
                    self.Value = value
                    updateToggle()
                end
            }
            
            return toggleObj
        end
        
        -- Slider function
        function section:Slider(text, min, max, default, callback)
            local elementIndex = #self.Elements + 1
            local default = default or min
            local value = default
            
            -- Create slider container
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = text .. "Slider"
            SliderContainer.Size = UDim2.new(1, 0, 0, 60)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.ZIndex = 5
            SliderContainer.LayoutOrder = elementIndex
            SliderContainer.Parent = self.Content
            
            -- Create slider label
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, -60, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 0)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text
            SliderLabel.TextColor3 = COLORS.Text
            SliderLabel.TextSize = 14
            SliderLabel.Font = FONTS.SemiBold
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.ZIndex = 6
            SliderLabel.Parent = SliderContainer
            
            -- Create value label
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -50, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = COLORS.Accent
            ValueLabel.TextSize = 14
            ValueLabel.Font = FONTS.Bold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.ZIndex = 6
            ValueLabel.Parent = SliderContainer
            
            -- Create slider background
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Name = "Background"
            SliderBackground.Size = UDim2.new(1, 0, 0, 10)
            SliderBackground.Position = UDim2.new(0, 0, 0, 30)
            SliderBackground.BackgroundColor3 = COLORS.LightBackground
            SliderBackground.ZIndex = 6
            SliderBackground.Parent = SliderContainer
            
            createCorner(SliderBackground, 5)
            
            -- Create slider fill
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = COLORS.Accent
            SliderFill.ZIndex = 7
            SliderFill.Parent = SliderBackground
            
            createCorner(SliderFill, 5)
            
            -- Create slider knob
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Size = UDim2.new(0, 16, 0, 16)
            SliderKnob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
            SliderKnob.BackgroundColor3 = COLORS.Text
            SliderKnob.ZIndex = 8
            SliderKnob.Parent = SliderBackground
            
            createCorner(SliderKnob, 8)
            
            -- Slider functionality
            local dragging = false
            
            local function updateSlider(input)
                local pos = input.Position.X
                local relativePos = math.clamp((pos - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(min + (relativePos * (max - min)))
                
                if newValue ~= value then
                    value = newValue
                    ValueLabel.Text = tostring(value)
                    
                    createTween(SliderFill, {Size = UDim2.new(relativePos, 0, 1, 0)}, 0.1):Play()
                    createTween(SliderKnob, {Position = UDim2.new(relativePos, -8, 0.5, -8)}, 0.1):Play()
                    
                    if callback then
                        callback(value)
                    end
                end
            end
            
            SliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            SliderBackground.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            -- Add to elements
            table.insert(self.Elements, SliderContainer)
            updateSectionSize()
            
            -- Return slider object
            local sliderObj = {
                Container = SliderContainer,
                Background = SliderBackground,
                Fill = SliderFill,
                Knob = SliderKnob,
                Value = value,
                Set = function(self, newValue)
                    value = math.clamp(newValue, min, max)
                    self.Value = value
                    ValueLabel.Text = tostring(value)
                    
                    local relativePos = (value - min) / (max - min)
                    createTween(SliderFill, {Size = UDim2.new(relativePos, 0, 1, 0)}, 0.1):Play()
                    createTween(SliderKnob, {Position = UDim2.new(relativePos, -8, 0.5, -8)}, 0.1):Play()
                    
                    if callback then
                        callback(value)
                    end
                end
            }
            
            return sliderObj
        end
        
        -- TextBox function
        function section:TextBox(text, placeholder, callback)
            local elementIndex = #self.Elements + 1
            
            -- Create textbox container
            local TextBoxContainer = Instance.new("Frame")
            TextBoxContainer.Name = text .. "TextBox"
            TextBoxContainer.Size = UDim2.new(1, 0, 0, 60)
            TextBoxContainer.BackgroundTransparency = 1
            TextBoxContainer.ZIndex = 5
            TextBoxContainer.LayoutOrder = elementIndex
            TextBoxContainer.Parent = self.Content
            
            -- Create textbox label
            local TextBoxLabel = Instance.new("TextLabel")
            TextBoxLabel.Name = "Label"
            TextBoxLabel.Size = UDim2.new(1, 0, 0, 20)
            TextBoxLabel.Position = UDim2.new(0, 10, 0, 0)
            TextBoxLabel.BackgroundTransparency = 1
            TextBoxLabel.Text = text
            TextBoxLabel.TextColor3 = COLORS.Text
            TextBoxLabel.TextSize = 14
            TextBoxLabel.Font = FONTS.SemiBold
            TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextBoxLabel.ZIndex = 6
            TextBoxLabel.Parent = TextBoxContainer
            
            -- Create textbox background
            local TextBoxBackground = Instance.new("Frame")
            TextBoxBackground.Name = "Background"
            TextBoxBackground.Size = UDim2.new(1, 0, 0, 30)
            TextBoxBackground.Position = UDim2.new(0, 0, 0, 25)
            TextBoxBackground.BackgroundColor3 = COLORS.LightBackground
            TextBoxBackground.ZIndex = 6
            TextBoxBackground.Parent = TextBoxContainer
            
            createCorner(TextBoxBackground, 6)
            
            -- Create textbox
            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBox"
            TextBox.Size = UDim2.new(1, -20, 1, -6)
            TextBox.Position = UDim2.new(0, 10, 0, 3)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder or "Enter text..."
            TextBox.TextColor3 = COLORS.Text
            TextBox.PlaceholderColor3 = COLORS.SubText
            TextBox.TextSize = 14
            TextBox.Font = FONTS.Regular
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.ClearTextOnFocus = false
            TextBox.ZIndex = 7
            TextBox.Parent = TextBoxBackground
            
            -- TextBox functionality
            TextBox.Focused:Connect(function()
                createTween(TextBoxBackground, {BackgroundColor3 = COLORS.Highlight}, 0.2):Play()
            end)
            
            TextBox.FocusLost:Connect(function(enterPressed)
                createTween(TextBoxBackground, {BackgroundColor3 = COLORS.LightBackground}, 0.2):Play()
                
                if callback then
                    callback(TextBox.Text, enterPressed)
                end
            end)
            
            -- Add to elements
            table.insert(self.Elements, TextBoxContainer)
            updateSectionSize()
            
            -- Return textbox object
            local textboxObj = {
                Container = TextBoxContainer,
                Background = TextBoxBackground,
                TextBox = TextBox,
                Value = TextBox.Text,
                Set = function(self, value)
                    TextBox.Text = value
                    self.Value = value
                    
                    if callback then
                        callback(value, false)
                    end
                end
            }
            
            return textboxObj
        end
        
        -- KeyBind function
        function section:KeyBind(text, default, callback)
            local elementIndex = #self.Elements + 1
            local keyCode = default and Enum.KeyCode[default] or Enum.KeyCode.Unknown
            local listening = false
            
            -- Create keybind container
            local KeyBindContainer = Instance.new("Frame")
            KeyBindContainer.Name = text .. "KeyBind"
            KeyBindContainer.Size = UDim2.new(1, 0, 0, 36)
            KeyBindContainer.BackgroundTransparency = 1
            KeyBindContainer.ZIndex = 5
            KeyBindContainer.LayoutOrder = elementIndex
            KeyBindContainer.Parent = self.Content
            
            -- Create keybind label
            local KeyBindLabel = Instance.new("TextLabel")
            KeyBindLabel.Name = "Label"
            KeyBindLabel.Size = UDim2.new(1, -110, 1, 0)
            KeyBindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeyBindLabel.BackgroundTransparency = 1
            KeyBindLabel.Text = text
            KeyBindLabel.TextColor3 = COLORS.Text
            KeyBindLabel.TextSize = 14
            KeyBindLabel.Font = FONTS.SemiBold
            KeyBindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyBindLabel.ZIndex = 6
            KeyBindLabel.Parent = KeyBindContainer
            
            -- Create keybind button
            local KeyBindButton = Instance.new("TextButton")
            KeyBindButton.Name = "Button"
            KeyBindButton.Size = UDim2.new(0, 100, 0, 30)
            KeyBindButton.Position = UDim2.new(1, -100, 0.5, -15)
            KeyBindButton.BackgroundColor3 = COLORS.LightBackground
            KeyBindButton.Text = keyCode ~= Enum.KeyCode.Unknown and keyCode.Name or "None"
            KeyBindButton.TextColor3 = COLORS.Text
            KeyBindButton.TextSize = 12
            KeyBindButton.Font = FONTS.SemiBold
            KeyBindButton.ZIndex = 6
            KeyBindButton.Parent = KeyBindContainer
            
            createCorner(KeyBindButton, 6)
            
            -- KeyBind functionality
            KeyBindButton.MouseButton1Click:Connect(function()
                if listening then return end
                
                listening = true
                KeyBindButton.Text = "..."
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keyCode = input.KeyCode
                        KeyBindButton.Text = keyCode.Name
                        listening = false
                        
                        if callback then
                            callback(keyCode)
                        end
                        
                        connection:Disconnect()
                    end
                end)
            end)
            
            -- Add to elements
            table.insert(self.Elements, KeyBindContainer)
            updateSectionSize()
            
            -- Return keybind object
            local keybindObj = {
                Container = KeyBindContainer,
                Button = KeyBindButton,
                KeyCode = keyCode,
                Set = function(self, key)
                    if type(key) == "string" then
                        keyCode = Enum.KeyCode[key]
                    else
                        keyCode = key
                    end
                    
                    self.KeyCode = keyCode
                    KeyBindButton.Text = keyCode.Name
                    
                    if callback then
                        callback(keyCode)
                    end
                end
            }
            
            return keybindObj
        end
        
        -- Add section to tab
        table.insert(self.Tab.Sections, section)
        
        return section
    end
    
    return tab
end

-- Select Tab
function KaliUI:SelectTab(name)
    for _, tab in pairs(self.Tabs) do
        if tab.Label.Text == name then
            -- Activate tab
            createTween(tab.Button, {BackgroundTransparency = 0.8}, 0.2):Play()
            createTween(tab.Label, {TextColor3 = COLORS.Text}, 0.2):Play()
            createTween(tab.Icon, {ImageColor3 = COLORS.Accent}, 0.2):Play()
            tab.Content.Visible = true
            self.ActiveTab = tab
        else
            -- Deactivate tab
            createTween(tab.Button, {BackgroundTransparency = 1}, 0.2):Play()
            createTween(tab.Label, {TextColor3 = COLORS.SubText}, 0.2):Play()
            createTween(tab.Icon, {ImageColor3 = COLORS.SubText}, 0.2):Play()
            tab.Content.Visible = false
        end
    end
end

-- Toggle UI
function KaliUI:ToggleUI()
    if self.MainFrame.Visible then
        -- Save position before minimizing
        local currentPos = self.MainFrame.Position
        
        -- Minimize animation
        createTween(self.MainFrame, {Size = UDim2.new(0, self.MainFrame.Size.X.Offset, 0, 0), Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset + self.MainFrame.Size.Y.Offset/2)}, 0.3, Enum.EasingStyle.Quint):Play()
        
        -- Show floating button
        wait(0.3)
        self.MainFrame.Visible = false
        self.ScreenGui.FloatingButton.Position = UDim2.new(0, 20, 0, 20)
        self.ScreenGui.FloatingButton.Visible = true
        
        -- Floating button animation
        createTween(self.ScreenGui.FloatingButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
    else
        -- Hide floating button
        createTween(self.ScreenGui.FloatingButton, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
        wait(0.2)
        self.ScreenGui.FloatingButton.Visible = false
        
        -- Show main frame
        self.MainFrame.Visible = true
        
        -- Restore animation
        createTween(self.MainFrame, {Size = UDim2.new(0, self.MainFrame.Size.X.Offset, 0, self.MainFrame.Size.Y.Offset), Position = UDim2.new(0.5, -self.MainFrame.Size.X.Offset/2, 0.5, -self.MainFrame.Size.Y.Offset/2)}, 0.3, Enum.EasingStyle.Quint):Play()
    end
end

-- Create Notifications
function KaliUI:CreateNotifications()
    -- Create notifications container
    local NotificationsContainer = Instance.new("Frame")
    NotificationsContainer.Name = "NotificationsContainer"
    NotificationsContainer.Size = UDim2.new(0, 300, 1, 0)
    NotificationsContainer.Position = UDim2.new(1, -310, 0, 0)
    NotificationsContainer.BackgroundTransparency = 1
    NotificationsContainer.ZIndex = 10
    NotificationsContainer.Parent = self.ScreenGui
    
    -- Create notifications layout
    local NotificationsLayout = Instance.new("UIListLayout")
    NotificationsLayout.Padding = UDim.new(0, 10)
    NotificationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    NotificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotificationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationsLayout.Parent = NotificationsContainer
    
    -- Create notifications padding
    local NotificationsPadding = Instance.new("UIPadding")
    NotificationsPadding.PaddingBottom = UDim.new(0, 10)
    NotificationsPadding.Parent = NotificationsContainer
    
    -- Notifications object
    local notifications = {
        Container = NotificationsContainer,
        Layout = NotificationsLayout,
        Queue = {},
        Library = self
    }
    
    -- Notification function
    function notifications:Notification(title, message, type, duration)
        local notificationIndex = #self.Queue + 1
        local duration = duration or 3
        
        -- Create notification frame
        local NotificationFrame = Instance.new("Frame")
        NotificationFrame.Name = "Notification_" .. notificationIndex
        NotificationFrame.Size = UDim2.new(1, -20, 0, 80)
        NotificationFrame.BackgroundColor3 = COLORS.Background
        NotificationFrame.BackgroundTransparency = 0.1
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.ClipsDescendants = true
        NotificationFrame.ZIndex = 11
        NotificationFrame.LayoutOrder = -notificationIndex -- Reverse order
        NotificationFrame.Parent = self.Container
        
        createCorner(NotificationFrame, 8)
        createShadow(NotificationFrame)
        
        -- Create notification accent
        local NotificationAccent = Instance.new("Frame")
        NotificationAccent.Name = "Accent"
        NotificationAccent.Size = UDim2.new(0, 4, 1, 0)
        NotificationAccent.BackgroundColor3 = type == "Error" and COLORS.Error or type == "Warning" and COLORS.Warning or COLORS.Success
        NotificationAccent.BorderSizePixel = 0
        NotificationAccent.ZIndex = 12
        NotificationAccent.Parent = NotificationFrame
        
        createCorner(NotificationAccent, 8)
        
        -- Create notification title
        local NotificationTitle = Instance.new("TextLabel")
        NotificationTitle.Name = "Title"
        NotificationTitle.Size = UDim2.new(1, -20, 0, 24)
        NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
        NotificationTitle.BackgroundTransparency = 1
        NotificationTitle.Text = title
        NotificationTitle.TextColor3 = COLORS.Text
        NotificationTitle.TextSize = 16
        NotificationTitle.Font = FONTS.Bold
        NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotificationTitle.ZIndex = 12
        NotificationTitle.Parent = NotificationFrame
        
        -- Create notification message
        local NotificationMessage = Instance.new("TextLabel")
        NotificationMessage.Name = "Message"
        NotificationMessage.Size = UDim2.new(1, -20, 0, 40)
        NotificationMessage.Position = UDim2.new(0, 10, 0, 30)
        NotificationMessage.BackgroundTransparency = 1
        NotificationMessage.Text = message
        NotificationMessage.TextColor3 = COLORS.SubText
        NotificationMessage.TextSize = 14
        NotificationMessage.Font = FONTS.Regular
        NotificationMessage.TextXAlignment = Enum.TextXAlignment.Left
        NotificationMessage.TextYAlignment = Enum.TextYAlignment.Top
        NotificationMessage.TextWrapped = true
        NotificationMessage.ZIndex = 12
        NotificationMessage.Parent = NotificationFrame
        
        -- Create notification close button
        local NotificationClose = Instance.new("TextButton")
        NotificationClose.Name = "Close"
        NotificationClose.Size = UDim2.new(0, 24, 0, 24)
        NotificationClose.Position = UDim2.new(1, -30, 0, 5)
        NotificationClose.BackgroundTransparency = 1
        NotificationClose.Text = "×"
        NotificationClose.TextColor3 = COLORS.SubText
        NotificationClose.TextSize = 20
        NotificationClose.Font = FONTS.Bold
        NotificationClose.ZIndex = 12
        NotificationClose.Parent = NotificationFrame
        
        -- Create notification progress bar
        local NotificationProgress = Instance.new("Frame")
        NotificationProgress.Name = "Progress"
        NotificationProgress.Size = UDim2.new(1, 0, 0, 2)
        NotificationProgress.Position = UDim2.new(0, 0, 1, -2)
        NotificationProgress.BackgroundColor3 = type == "Error" and COLORS.Error or type == "Warning" and COLORS.Warning or COLORS.Success
        NotificationProgress.BorderSizePixel = 0
        NotificationProgress.ZIndex = 12
        NotificationProgress.Parent = NotificationFrame
        
        -- Animation functions
        local function animateIn()
            NotificationFrame.Position = UDim2.new(1, 0, 0, 0)
            createTween(NotificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint):Play()
        end
        
        local function animateOut()
            createTween(NotificationFrame, {Position = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint):Play()
            wait(0.3)
            NotificationFrame:Destroy()
            
            -- Remove from queue
            for i, notification in pairs(self.Queue) do
                if notification == NotificationFrame then
                    table.remove(self.Queue, i)
                    break
                end
            end
        end
        
        -- Progress bar animation
        local progressTween = createTween(NotificationProgress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
        
        -- Close button functionality
        NotificationClose.MouseButton1Click:Connect(function()
            progressTween:Cancel()
            animateOut()
        end)
        
        -- Add to queue and animate
        table.insert(self.Queue, NotificationFrame)
        animateIn()
        
        -- Start progress bar
        progressTween:Play()
        
        -- Auto close after duration
        spawn(function()
            wait(duration)
            if NotificationFrame and NotificationFrame.Parent then
                animateOut()
            end
        end)
        
        return NotificationFrame
    end
    
    return notifications
end

-- Return the library
return KaliUI
