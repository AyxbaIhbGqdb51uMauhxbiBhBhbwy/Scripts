task.spawn(function()
    coroutine.wrap(function()
    local nowprediction = true
    local auto_parry_enabled = false
    local anti_lag_enabled = false
    local personnel_detector_enabled = false
    local ball_trial_Enabled = false
    local spam_speed = 1
    local spam_sensetive = 1
    local lastBetweentarget = 0
    local lastTarget = os.clock()
    local strength = 0
    local gravity_enabled = false
    local current_curve = nil
    local ai_Enabled = false
    local tp_hit = false
    local dymanic_curve_check_enabled = false
    local visualize_Enabled = false
    local parry_mode = "Nothing"
    local target_Ball_Distance = 0
    local auto_pary_enabled=false
    local pry_cur=0.548
    local sense=0.8
    local mul=2.583
    local farm_method = "Controlled"
    local selected_axis = "Y"
    local selected_speed = 100
    function getgelp()
    local nurysium_module = {}
    
    local Players = game:GetService("Players")
    
    local Services = {
        game:GetService('AnimationFromVideoCreatorService'),
        game:GetService('AdService')
    }
    
    function nurysium_module.isAlive(Entity)
        return Entity.Character and workspace.Alive:FindFirstChild(Entity.Name) and workspace.Alive:FindFirstChild(Entity.Name).Humanoid.Health > 0
    end
    
    function nurysium_module.getBall()
        for index, ball in workspace:WaitForChild("Balls"):GetChildren() do
            if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
                return ball
            end
        end
    end
    
    return nurysium_module;
    end
    local Helper = getgelp()
    local RobloxReplicatedStorage = cloneref(game:GetService('RobloxReplicatedStorage'))
    local RbxAnalyticsService = cloneref(game:GetService('RbxAnalyticsService'))
    local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
    local UserInputService = cloneref(game:GetService('UserInputService'))
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local NetworkClient = cloneref(game:GetService("NetworkClient"))
    local TweenService = cloneref(game:GetService('TweenService'))
    local VirtualUser = cloneref(game:GetService('VirtualUser'))
    local HttpService = cloneref(game:GetService('HttpService'))
    local RunService = cloneref(game:GetService('RunService'))
    local LogService = cloneref(game:GetService('LogService'))
    local Lighting = cloneref(game:GetService('Lighting'))
    local CoreGui = cloneref(game:GetService('CoreGui'))
    local Players = cloneref(game:GetService('Players'))
    local Debris = cloneref(game:GetService('Debris'))
    local Stats = cloneref(game:GetService('Stats'))
    local workspace = cloneref(game:GetService('Workspace'))
    local uis = game:GetService("UserInputService")
    local chance="100%"
    local function chancer(chance)
        local number = tonumber(chance:match("%d+")) -- Extract the number from the string like "100%"
        
        if number then
            local randomValue = math.random(1, 100) -- Generate a random number between 1 and 100
            if randomValue <= number then
                return true
            else
                return false
            end
        else
            error("Invalid chance format")
        end
    end
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    setfpscap(60)
    
    local LocalPlayer = Players.LocalPlayer
    local client_id = RbxAnalyticsService:GetClientId()
    local RunTime = workspace.Runtime
    local Alive = workspace.Alive
    local Dead = workspace.Dead
    
    local AutoParry = {
        ball = nil,
        target = nil,
        entity_properties = nil
    }
    
    local Player = {
        Entity = nil,
    
        properties = {
            grab_animation = nil
        }
    }
    
    Player.Entity = {
        properties = {
            sword = '',
            server_position = Vector3.zero,
            velocity = Vector3.zero,
            position = Vector3.zero,
            is_moving = false,
            speed = 0,
            ping = 0
        }
    }
    
    local World = {}
    
    AutoParry.ball = {
        training_ball_entity = nil,
        client_ball_entity = nil,
        ball_entity = nil,
    
        properties = {
            last_ball_pos = Vector3.zero,
            aero_dynamic_time = tick(),
            hell_hook_completed = true,
            last_position = Vector3.zero,
            rotation = Vector3.zero,
            position = Vector3.zero,
            last_warping = tick(),
            parry_remote = nil,
            is_curved = false,
            last_tick = tick(),
            auto_spam = false,
            cooldown = false,
            respawn_time = 0,
            parry_range = 0,
            spam_range = 0,
            maximum_speed = 0,
            old_speed = 0,
            parries = 0,
            direction = 0,
            distance = 0,
            velocity = 0,
            last_hit = 0,
            lerp_radians = 0,
            radians = 0,
            speed = 0,
            dot = 0
        }
    }
    
    AutoParry.target = {
        current = nil,
        from = nil,
        aim = nil,
    }
    
    AutoParry.entity_properties = {
        server_position = Vector3.zero,
        velocity = Vector3.zero,
        is_moving = false,
        direction = 0,
        distance = 0,
        speed = 0,
        dot = 0
    }
    
    local function linear_predict(a: any, b: any, time_volume: number)
        return a + (b - a) * time_volume
    end
    
    function World:get_pointer()
        local mouse_location = UserInputService:GetMouseLocation()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse_location.X, mouse_location.Y, 0)
    
        return CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
    end
    
    function AutoParry.get_ball()
        for _, ball in workspace.Balls:GetChildren() do
            if ball:GetAttribute("realBall") then
                return ball
            end
        end
    end
    
    function AutoParry.get_client_ball()
        for _, ball in workspace.Balls:GetChildren() do
            if not ball:GetAttribute("realBall") then
                return ball
            end
        end
    end
    
    function makingtrail()
        local ball = nil
    
    
        local function createOrUpdateTrail()
            local Trail = ball:FindFirstChild("Trail")
            if not Trail then
                Trail = Instance.new("Trail")
                Trail.Name = "Trail"
                Trail.FaceCamera = true
                Trail.Parent = ball
            end
    
            local At1 = ball:FindFirstChild("at1")
            local At2 = ball:FindFirstChild("at2")
    
            if At1 and At2 then
                Trail.Attachment0 = At1
                Trail.Attachment1 = At2
    
                Trail.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0.00, Color3.new(0.00, 0.00, 0.00)),  -- Black
                    ColorSequenceKeypoint.new(0.14, Color3.new(0.25, 0.25, 0.25)), -- Dark Gray
                    ColorSequenceKeypoint.new(0.30, Color3.new(0.50, 0.50, 0.50)), -- Gray
                    ColorSequenceKeypoint.new(0.48, Color3.new(0.75, 0.75, 0.75)), -- Light Gray
                    ColorSequenceKeypoint.new(0.69, Color3.new(0.85, 0.85, 0.85)), -- Lighter Gray
                    ColorSequenceKeypoint.new(0.88, Color3.new(0.95, 0.95, 0.95)), -- Almost White
                    ColorSequenceKeypoint.new(1.00, Color3.new(1.00, 1.00, 1.00))  -- White
                }
    
                Trail.WidthScale = NumberSequence.new{
                    NumberSequenceKeypoint.new(0.00, 0.5, 0.00),
                    NumberSequenceKeypoint.new(1.00, 0.00, 0.00)
                }
    
                Trail.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0.00, 0.00, 0.00),
                    NumberSequenceKeypoint.new(1.00, 1.00, 0.00)
                }
    
                Trail.Enabled = true
            end
        end
    
        local function enableTrailAndDisableFF()
            createOrUpdateTrail()
    
            local Trail = ball:FindFirstChild("Trail")
            if Trail then
                Trail.Enabled = true
            end
    
            local ff = ball:FindFirstChild("ff")
            if ff then
                ff.Enabled = false
            end
        end
    
    
        local function disableTrailAndEnableFF()
            local Trail = ball:FindFirstChild("Trail")
            if Trail then
                Trail:Destroy()
            end
    
            local ff = ball:FindFirstChild("ff")
            if ff then
                ff.Enabled = true
            end
        end
    
        ball = Helper.getBall()
    
        if ball then
            if ball_trial_Enabled then
                enableTrailAndDisableFF()
            else
                disableTrailAndEnableFF()
            end
        end
    
    end
    
    local self = Helper.getBall()
    local Visualize = Instance.new("Part",workspace)
    Visualize.Color = Color3.new(0.14902, 0, 0)
    Visualize.Material = Enum.Material.ForceField
    Visualize.Transparency = 0.5
    Visualize.Anchored = true
    Visualize.CanCollide = false
    Visualize.CastShadow = false
    Visualize.Shape = Enum.PartType.Ball
    Visualize.Size = Vector3.new(30,30,30)
    
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = Visualize
    Highlight.Enabled = true
    Highlight.FillTransparency = 0
    Highlight.OutlineColor = Color3.new(1, 1, 1)
    
    
    
    RunService.PreSimulation:Connect(function()
        if visualize_Enabled and LocalPlayer then
            Visualize.Transparency = 0
            Visualize.Material = Enum.Material.ForceField
            Visualize.Size = Vector3.new(AutoParry.ball.properties.parry_range,AutoParry.ball.properties.parry_range,AutoParry.ball.properties.parry_range)
            Visualize.CFrame = CFrame.new(LocalPlayer.Character.PrimaryPart.Position)
        else
            Visualize.Material = Enum.Material.ForceField
            Visualize.Transparency = 1
        end	
    end)
    
    function Player:get_aim_entity()
        local closest_entity = nil
        local minimal_dot_product = -math.huge
        local camera_direction = workspace.CurrentCamera.CFrame.LookVector
    
        for _, player in Alive:GetChildren() do
            if not player then
                continue
            end
    
            if player.Name ~= LocalPlayer.Name then
                if not player:FindFirstChild('HumanoidRootPart') then
                    continue
                end
    
                local entity_direction = (player.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
                local dot_product = camera_direction:Dot(entity_direction)
    
                if dot_product > minimal_dot_product then
                    minimal_dot_product = dot_product
                    closest_entity = player
                end
            end
        end
    
        return closest_entity
    end
    
    function Player:get_closest_player_to_cursor()
        local closest_player = nil
        local minimal_dot_product = -math.huge
    
        for _, player in workspace.Alive:GetChildren() do
            if player == LocalPlayer.Character then
                continue
            end
    
            if player.Parent ~= Alive then
                continue
            end
    
            local player_direction = (player.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Unit
            local pointer = World.get_pointer()
            local dot_product = pointer.LookVector:Dot(player_direction)
    
            if dot_product > minimal_dot_product then
                minimal_dot_product = dot_product
                closest_player = player
            end
        end
    
        return closest_player
    end
    
    function AutoParry.get_parry_remote()
            local Services = {cloneref(game:GetService("AnimationFromVideoCreatorService")),cloneref(game:GetService('AdService'))}
    
            for _, v in pairs(Services) do
                local temp_remote = v:FindFirstChildOfClass('RemoteEvent')
        
                if temp_remote and temp_remote.Name:find('\n') then
                AutoParry.ball.properties.parry_remote = temp_remote
            end
        end
    end
    
    AutoParry.get_parry_remote()
    
    function AutoParry.perform_grab_animation()
        local animation = ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild('GrabParry')
        local currently_equipped = Player.Entity.properties.sword
    
        if not currently_equipped or currently_equipped == 'Titan Blade' then
            return
        end
    
        if not animation then
            return
        end
    
        local sword_data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(currently_equipped)
    
        if not sword_data or not sword_data['AnimationType'] then
            return
        end
    
        local character = LocalPlayer.Character
    
        if not character or not character:FindFirstChild('Humanoid') then
            return
        end
    
        for _, object in ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren() do
            if object.Name ~= sword_data['AnimationType'] then
                continue
            end
    
            if not (object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab')) then
                continue
            end
    
            local sword_animation_type = 'GrabParry'
    
            if object:FindFirstChild('Grab') then
                sword_animation_type = 'Grab'
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.001)  -- Mouse Down
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.001) -- Mouse Up
            end
    
            animation = object[sword_animation_type]
        end
    
        Player.properties.grab_animation = character.Humanoid:LoadAnimation(animation)
        Player.properties.grab_animation:Play()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.001)  -- Mouse Down
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.001) -- Mouse Up
    end
    
    function AutoParry.perform_parry()
        local ball_properties = AutoParry.ball.properties
    
        if ball_properties.cooldown and not ball_properties.auto_spam then
            return
        end
    
        ball_properties.parries += 1
        AutoParry.ball.properties.last_hit = tick()
    
        local camera = workspace.CurrentCamera
        local camera_direction = camera.CFrame.Position
    
        local direction = camera.CFrame
        local target_position = AutoParry.entity_properties.server_position
    
        if not ball_properties.auto_spam then
            AutoParry.perform_grab_animation()
    
            ball_properties.cooldown = true
            if current_curve == 'Stright' then
                direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, target_position)
            end
            if chancer(chance) then
            if current_curve == 'Backwards' then
                direction = CFrame.new(camera_direction, (camera_direction + (-camera.CFrame.LookVector * 10000)) + Vector3.new(0, 1000, 0))
            end
    
            if current_curve == 'Randomizer' then
                direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, Vector3.new(math.random(-1000, 1000), math.random(-350, 1000), math.random(-1000, 1000)))
            end
    
            if current_curve == 'Boost' then
                direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, target_position + Vector3.new(0, 150, 0))
            end
            
            if current_curve == 'High' then
                direction = CFrame.new(LocalPlayer.Character.PrimaryPart.Position, target_position + Vector3.new(0, 1000, 0))
            end
         end
        else
                local VirtualInputManager = game:GetService("VirtualInputManager")
    
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.001)  -- Mouse Down
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.001) -- Mouse Up
    
            task.delay(sense, function()
                if ball_properties.parries > 0 then
                    ball_properties.parries -= 1
                end
            end)
    
            return
        end
    local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0.001)  -- Mouse Down
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0.001) -- Mouse Up
    
    
        task.delay(sense, function()
            if ball_properties.parries > 0 then
                ball_properties.parries -= 1
            end
        end)
    end
    
    function AutoParry.reset()
        nowprediction = true
        AutoParry.ball.properties.is_curved = false
        AutoParry.ball.properties.auto_spam = false
        AutoParry.ball.properties.cooldown = false
        AutoParry.ball.properties.maximum_speed = 0
        AutoParry.ball.properties.parries = 0
        AutoParry.entity_properties.server_position = Vector3.zero
        AutoParry.target.current = nil
        AutoParry.target.from = nil
    end
    
    ReplicatedStorage.Remotes.PlrHellHooked.OnClientEvent:Connect(function(hooker: Model)
        if hooker.Name == LocalPlayer.Name then
            AutoParry.ball.properties.hell_hook_completed = true
    
            return
        end
    
        AutoParry.ball.properties.hell_hook_completed = false
    end)
    
    ReplicatedStorage.Remotes.PlrHellHookCompleted.OnClientEvent:Connect(function()
        AutoParry.ball.properties.hell_hook_completed = true
    end)
    
    function AutoParry.is_curved()
        local target = AutoParry.target.current
    
        if not target then
            return false
        end
    
        local ball_properties = AutoParry.ball.properties
        local current_target = target.Name
    
        -- Early checks for certain conditions
        if target.PrimaryPart:FindFirstChild('MaxShield') and current_target ~= LocalPlayer.Name and ball_properties.distance < 50 then
            return false
        end
    
        if AutoParry.ball.ball_entity:FindFirstChild('TimeHole1') and current_target ~= LocalPlayer.Name and ball_properties.distance < 100 then
            ball_properties.auto_spam = false
            return false
        end
    
        if AutoParry.ball.ball_entity:FindFirstChild('WEMAZOOKIEGO') and current_target ~= LocalPlayer.Name and ball_properties.distance < 100 then
            return false
        end
    
        if AutoParry.ball.ball_entity:FindFirstChild('At2') and ball_properties.speed <= 0 then
            return true
        end
    
        if AutoParry.ball.ball_entity:FindFirstChild('AeroDynamicSlashVFX') then
            Debris:AddItem(AutoParry.ball.ball_entity.AeroDynamicSlashVFX, 0)
            ball_properties.auto_spam = false
            ball_properties.aero_dynamic_time = tick()
        end
    
        if RunTime:FindFirstChild('Tornado') then
            if ball_properties.distance > 5 and (tick() - ball_properties.aero_dynamic_time) < (RunTime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then
                return true
            end
        end
    
        if not ball_properties.hell_hook_completed and current_target == LocalPlayer.Name and ball_properties.distance > 5 - math.random() then
            return true
        end
    
        -- Predict future position using velocity
        local future_position = ball_properties.position + (ball_properties.velocity * (ball_properties.distance / ball_properties.maximum_speed))
        local previous_position = ball_properties.last_curve_position or ball_properties.position
        local travel_direction = (future_position - previous_position).Unit
    
        -- Angle calculations for better curve detection
        local dot_product = ball_properties.velocity.Unit:Dot(travel_direction)
        local angle_diff = math.acos(math.clamp(dot_product, -1, 1))
    
        -- Dynamic threshold adjustments
        local speed_factor = math.min(ball_properties.speed / 100, 40)
        local angle_threshold = 40.046 * math.max(ball_properties.dot, 0)
        local player_ping = Player.Entity.properties.ping
        local dot_threshold = pry_cur - player_ping / 950
    
        -- Adjust reach time based on velocity and ping
        local reach_time = ball_properties.distance / (ball_properties.velocity.Magnitude + 0.01) - (player_ping / 1000)
        local enough_speed = ball_properties.maximum_speed > 100
    
        -- Dynamically calculate ball distance threshold
        local ball_distance_threshold = 15 - math.min(ball_properties.distance / 1000, 15) + angle_threshold + speed_factor
    
        if enough_speed and reach_time > player_ping / 10 then
            ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)
        end
    
        if ball_properties.distance < ball_distance_threshold then
            return false
        end
    
        -- Determine if the angle difference suggests a curve
        if angle_diff > (0.5 + (ball_properties.speed / 310)) then
            ball_properties.auto_spam = false
            return true -- Early return for curves detected based on angle difference
        end
    
        if ball_properties.lerp_radians < 0.018 then
            ball_properties.last_curve_position = ball_properties.position
            ball_properties.last_warping = tick()
        end
    
        if (tick() - ball_properties.last_warping) < (reach_time / 1.5) then
            return true
        end
    
        ball_properties.last_curve_position = ball_properties.position
    
        -- Final check for curve detection based on dot product threshold
        return ball_properties.dot < dot_threshold
    end
    local old_from_target = nil 
    
    function AutoParry:is_spam()
    if not auto_pary_enabled then return false end
        local target = AutoParry.target.current
    
        if not target then
            return false
        end
    
        if AutoParry.target.from ~= LocalPlayer.Character then
            old_from_target = AutoParry.target.from
        end
    
        local take_time = (tick() - self.last_hit)
    
        if self.parries < 3 - spam_sensetive and AutoParry.target.from == old_from_target then
            return false
        end
    
    
    
        local player_ping = Player.Entity.properties.ping
        local distance_threshold = (self.spam_accuracy / 3.5) + (player_ping / 80)
    
        local ball_properties = AutoParry.ball.properties
        local reach_time = ball_properties.distance / ball_properties.maximum_speed - (player_ping / 1000)
    
        if (tick() - self.last_hit) > 0.8 and self.entity_distance > distance_threshold and self.parries < 3 then
            self.parries = 1
    
            return false
        end
    
        if ball_properties.lerp_radians > 0.028 then
            if self.parries < 2 then
                self.parries = 1
            end
    
            return false
        end
    
        if (tick() - ball_properties.last_warping) < (reach_time / 1.3) and self.entity_distance > distance_threshold and self.parries < 4 then
            if self.parries < 3 then
                self.parries = 1
            end
    
            return false
        end
    
        if math.abs(self.speed - self.old_speed) < 5.2 and self.entity_distance > distance_threshold and self.speed < 60 and self.parries < 3 then
            if self.parries < 3 then
                self.parries = 0
            end
    
            return false
        end
    
        if self.speed < 10 then
            self.parries = 1
    
            return false
        end
    
        if self.maximum_speed < self.speed and self.entity_distance > distance_threshold then
            self.parries = 1
    
            return false
        end
    
        if self.entity_distance > self.range and self.entity_distance > distance_threshold then
            if self.parries < 2 then
                self.parries = 1
            end
    
            return false
        end
    
        if self.ball_distance > self.range and self.entity_distance > distance_threshold then
            if self.parries < 2 then
                self.parries = 2
            end
    
            return false
        end
    
        if self.last_position_distance > self.spam_accuracy and self.entity_distance > distance_threshold then
            if self.parries < 4 then
                self.parries = 2
            end
    
            return false
        end
    
        if self.ball_distance > self.spam_accuracy and self.ball_distance > distance_threshold then
            if self.parries < 3 then
                self.parries = 2
            end
    
            return false
        end
    
        if self.entity_distance > self.spam_accuracy and self.entity_distance > (distance_threshold - math.pi) then
            if self.parries < 3 then
                self.parries = 2
            end
    
            return false
        end
    
        return true	
    end
    
    
    
    RunService:BindToRenderStep('server position simulation', 1, function()
        local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
    
        if not LocalPlayer.Character then
            return
        end
    
        if not LocalPlayer.Character.PrimaryPart then
            return
        end
    
        local PrimaryPart = LocalPlayer.Character.PrimaryPart
        local old_position = PrimaryPart.Position
    
        task.delay(ping / 1000, function()
            Player.Entity.properties.server_position = old_position
        end)
    end)
    
    RunService.PreSimulation:Connect(function()
        NetworkClient:SetOutgoingKBPSLimit(math.huge)
    
        local character = LocalPlayer.Character
    
        if not character then
            return
        end
    
        if not character.PrimaryPart then
            return
        end
    
        local player_properties = Player.Entity.properties
    
        player_properties.sword = character:GetAttribute('CurrentlyEquippedSword')
        player_properties.ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
        player_properties.velocity = character.PrimaryPart.AssemblyLinearVelocity
        player_properties.speed = Player.Entity.properties.velocity.Magnitude
        player_properties.is_moving = Player.Entity.properties.speed > 30
    end)
    
    
    RunService.PreSimulation:Connect(function()
        makingtrail()
    end)
    AutoParry.ball.ball_entity = AutoParry.get_ball()
    AutoParry.ball.client_ball_entity = AutoParry.get_client_ball()
    
    RunService.PreSimulation:Connect(function()
        local ball = AutoParry.ball.ball_entity
    
        if not ball then
            return
        end
    
        local zoomies = ball:FindFirstChild('zoomies')
    
        local ball_properties = AutoParry.ball.properties
    
        ball_properties.position = ball.Position
        ball_properties.velocity = ball.AssemblyLinearVelocity
    
        if zoomies then
            ball_properties.velocity = ball.zoomies.VectorVelocity
        end
    
        ball_properties.distance = (Player.Entity.properties.server_position - ball_properties.position).Magnitude
        ball_properties.speed = ball_properties.velocity.Magnitude
        ball_properties.direction = (Player.Entity.properties.server_position - ball_properties.position).Unit
        ball_properties.dot = ball_properties.direction:Dot(ball_properties.velocity.Unit)
        ball_properties.radians = math.rad(math.asin(ball_properties.dot))
        ball_properties.lerp_radians = linear_predict(ball_properties.lerp_radians, ball_properties.radians, 0.8)
    
        target_Ball_Distance = (ball_properties.position - AutoParry.entity_properties.server_position).Magnitude
    
        if not (ball_properties.lerp_radians < 0) and not (ball_properties.lerp_radians > 0) then
            ball_properties.lerp_radians = 0.027
        end
    
        ball_properties.maximum_speed = math.max(ball_properties.speed, ball_properties.maximum_speed)
    
        AutoParry.target.aim = (not uis.TouchEnabled and Player.get_closest_player_to_cursor() or Player.get_aim_entity())
    
        if ball:GetAttribute('from') ~= nil then
            AutoParry.target.from = Alive:FindFirstChild(ball:GetAttribute('from'))
        end
    
        AutoParry.target.current = Alive:FindFirstChild(ball:GetAttribute('target'))
    
        if AutoParry.target == nil then
            return
    
        end
    
        ball_properties.rotation = ball_properties.position
    
        if AutoParry.target.current and AutoParry.target.current.Name == LocalPlayer.Name then
            ball_properties.rotation = AutoParry.target.aim.PrimaryPart.Position
            lastBetweentarget = os.clock() - lastTarget
            return
        end
    
        if not AutoParry.target.current then
            return
        end
    
        local target_server_position = AutoParry.target.current.PrimaryPart.Position
        local target_velocity = AutoParry.target.current.PrimaryPart.AssemblyLinearVelocity
    
        AutoParry.entity_properties.server_position = target_server_position
        AutoParry.entity_properties.velocity = target_velocity
        AutoParry.entity_properties.distance = LocalPlayer:DistanceFromCharacter(target_server_position)
        AutoParry.entity_properties.direction = (Player.Entity.properties.server_position - target_server_position).Unit
        AutoParry.entity_properties.speed = target_velocity.Magnitude
        AutoParry.entity_properties.is_moving = target_velocity.Magnitude > 0.1
        AutoParry.entity_properties.dot = AutoParry.entity_properties.is_moving and math.max(AutoParry.entity_properties.direction:Dot(target_velocity.Unit), 0)
    end)
    
    local LocalPlayer = Players.LocalPlayer
    
    local dropdown_emotes_table = {}
    local emote_instances = {}
    
    for _, emote in ReplicatedStorage.Misc.Emotes:GetChildren() do
        local emote_name = emote:GetAttribute('EmoteName')
    
        if not emote_name then
            return
        end
    
        table.insert(dropdown_emotes_table, emote_name)
        emote_instances[emote_name] = emote
    end
    
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end)
    
    local current_animation = nil
    local current_animation_name = nil
    
    local looped_emotes = {
        "Emote108",
        "Emote225",
        "Emote300",
        "Emote301"
    }
    
    
    local spamming_done = true 
    
    
    
    
    local staff_roles = {
        'content creator',
        'contributor',
        'trial qa',
        'tester',
        'mod'
    }
    
    Players.PlayerAdded:Connect(function(player)
        local is_friend = LocalPlayer:IsFriendsWith(player.UserId)
    
    
    
        if not personnel_detector_enabled then
            return
        end
    
    
    
        local player_role = tostring(player:GetRoleInGroup(12836673)):lower()
        local player_is_staff = table.find(staff_roles, player_role)
    
        if player_is_staff then
            game:Shutdown()
    
            return
        end
    end)
    
    
    local is_respawned = false :: boolean
    
    workspace.Balls.ChildRemoved:Connect(function(child)
        is_respawned = false
    
        if child == AutoParry.ball.ball_entity then
            AutoParry.ball.ball_entity = nil
            AutoParry.ball.client_ball_entity = nil
            AutoParry.reset()
        end
    end)
    
    workspace.Balls.ChildAdded:Connect(function()
        if is_respawned then
            return
        end
    
        is_respawned = true
    
        local ball_properties = AutoParry.ball.properties
    
        ball_properties.respawn_time = tick()
    
        AutoParry.ball.ball_entity = AutoParry.get_ball()
        AutoParry.ball.client_ball_entity = AutoParry.get_client_ball()
    
        local target = AutoParry.ball.ball_entity:GetAttribute('target')
    
        AutoParry.ball.ball_entity:GetAttributeChangedSignal('target'):Connect(function()
            if target == LocalPlayer.Name then
                ball_properties.cooldown = false
    
                return
            end
    
            ball_properties.cooldown = false
            ball_properties.old_speed = ball_properties.speed
            ball_properties.last_position = ball_properties.position
    
            ball_properties.parries += 1
    
            task.delay(1, function()
                if ball_properties.parries > 0 then
                    ball_properties.parries -= 1
                end
            end)	
        end)
    end)
    
    
    
    RunService.PreSimulation:Connect(function()
    coroutine.wrap(function()
        if not AutoParry.ball.properties.auto_spam then
            return
        end
    task.spawn(function()
        for v = 1,spam_speed do
            AutoParry.perform_parry()
        end
    end)
    end)()
    end)
    
    local MauaulSpam -- Declare MauaulSpam globally
    
    function ManualSpam()
        -- Gui to Lua
        -- Version: 3.2
        
        if MauaulSpam then
            MauaulSpam:Destroy()
            MauaulSpam = nil
            return
        end
    
        MauaulSpam = Instance.new("ScreenGui")
        MauaulSpam.Name = "MauaulSpam"
        MauaulSpam.Parent = game.CoreGui
        MauaulSpam.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        MauaulSpam.ResetOnSpawn = false
    
        local Main = Instance.new("Frame")
        Main.Name = "Main"
        Main.Parent = MauaulSpam
        Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Main.BorderSizePixel = 0
        Main.Position = UDim2.new(0.41414836, 0, 0.404336721, 0)
        Main.Size = UDim2.new(0.227479532, 0, 0.191326529, 0)
    
        local UICorner = Instance.new("UICorner")
        UICorner.Parent = Main
    
        local IndercantorBlahblah = Instance.new("Frame")
        IndercantorBlahblah.Name = "IndercantorBlahblah"
        IndercantorBlahblah.Parent = Main
        IndercantorBlahblah.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        IndercantorBlahblah.BorderColor3 = Color3.fromRGB(0, 0, 0)
        IndercantorBlahblah.BorderSizePixel = 0
        IndercantorBlahblah.Position = UDim2.new(0.0280000009, 0, 0.0733333305, 0)
        IndercantorBlahblah.Size = UDim2.new(0.0719999969, 0, 0.119999997, 0)
    
        local UICorner_2 = Instance.new("UICorner")
        UICorner_2.CornerRadius = UDim.new(1, 0)
        UICorner_2.Parent = IndercantorBlahblah
    
        local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
        UIAspectRatioConstraint.Parent = IndercantorBlahblah
    
        local PC = Instance.new("TextLabel")
        PC.Name = "PC"
        PC.Parent = Main
        PC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PC.BackgroundTransparency = 1.000
        PC.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PC.BorderSizePixel = 0
        PC.Position = UDim2.new(0.547999978, 0, 0.826666653, 0)
        PC.Size = UDim2.new(0.451999992, 0, 0.173333332, 0)
        PC.Font = Enum.Font.Unknown
        PC.Text = "PC: E to spam"
        PC.TextColor3 = Color3.fromRGB(57, 57, 57)
        PC.TextScaled = true
        PC.TextSize = 16.000
        PC.TextWrapped = true
    
        local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
        UITextSizeConstraint.Parent = PC
        UITextSizeConstraint.MaxTextSize = 16
    
        local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
        UIAspectRatioConstraint_2.Parent = PC
        UIAspectRatioConstraint_2.AspectRatio = 4.346
    
        local IndercanotTextBlah = Instance.new("TextButton")
        IndercanotTextBlah.Name = "IndercanotTextBlah"
        IndercanotTextBlah.Parent = Main
        IndercanotTextBlah.Active = false
        IndercanotTextBlah.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        IndercanotTextBlah.BackgroundTransparency = 1.000
        IndercanotTextBlah.BorderColor3 = Color3.fromRGB(0, 0, 0)
        IndercanotTextBlah.BorderSizePixel = 0
        IndercanotTextBlah.Position = UDim2.new(0.164000005, 0, 0.326666653, 0)
        IndercanotTextBlah.Selectable = false
        IndercanotTextBlah.Size = UDim2.new(0.667999983, 0, 0.346666664, 0)
        IndercanotTextBlah.Font = Enum.Font.GothamBold
        IndercanotTextBlah.Text = "StarX"
        IndercanotTextBlah.TextColor3 = Color3.fromRGB(255, 255, 255)
        IndercanotTextBlah.TextScaled = true
        IndercanotTextBlah.TextSize = 24.000
        IndercanotTextBlah.TextWrapped = true
    
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
        UIGradient.Parent = IndercanotTextBlah
    
        local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
        UITextSizeConstraint_2.Parent = IndercanotTextBlah
        UITextSizeConstraint_2.MaxTextSize = 52
    
        local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
        UIAspectRatioConstraint_3.Parent = IndercanotTextBlah
        UIAspectRatioConstraint_3.AspectRatio = 3.212
    
        local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
        UIAspectRatioConstraint_4.Parent = Main
        UIAspectRatioConstraint_4.AspectRatio = 1.667
    
    --Properties:
    
    MauaulSpam.Name = "MauaulSpam"
    MauaulSpam.Parent = game.CoreGui
    MauaulSpam.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MauaulSpam.ResetOnSpawn = false
    
    Main.Name = "Main"
    Main.Parent = MauaulSpam
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.41414836, 0, 0.404336721, 0)
    Main.Size = UDim2.new(0.227479532, 0, 0.191326529, 0)
    
    UICorner.Parent = Main
    
    IndercantorBlahblah.Name = "IndercantorBlahblah"
    IndercantorBlahblah.Parent = Main
    IndercantorBlahblah.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    IndercantorBlahblah.BorderColor3 = Color3.fromRGB(0, 0, 0)
    IndercantorBlahblah.BorderSizePixel = 0
    IndercantorBlahblah.Position = UDim2.new(0.0280000009, 0, 0.0733333305, 0)
    IndercantorBlahblah.Size = UDim2.new(0.0719999969, 0, 0.119999997, 0)
    
    UICorner_2.CornerRadius = UDim.new(1, 0)
    UICorner_2.Parent = IndercantorBlahblah
    
    UIAspectRatioConstraint.Parent = IndercantorBlahblah
    
    PC.Name = "PC"
    PC.Parent = Main
    PC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PC.BackgroundTransparency = 1.000
    PC.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PC.BorderSizePixel = 0
    PC.Position = UDim2.new(0.547999978, 0, 0.826666653, 0)
    PC.Size = UDim2.new(0.451999992, 0, 0.173333332, 0)
    PC.Font = Enum.Font.Unknown
    PC.Text = "PC: E to spam"
    PC.TextColor3 = Color3.fromRGB(57, 57, 57)
    PC.TextScaled = true
    PC.TextSize = 16.000
    PC.TextWrapped = true
    
    UITextSizeConstraint.Parent = PC
    UITextSizeConstraint.MaxTextSize = 16
    
    UIAspectRatioConstraint_2.Parent = PC
    UIAspectRatioConstraint_2.AspectRatio = 4.346
    
    IndercanotTextBlah.Name = "IndercanotTextBlah"
    IndercanotTextBlah.Parent = Main
    IndercanotTextBlah.Active = false
    IndercanotTextBlah.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IndercanotTextBlah.BackgroundTransparency = 1.000
    IndercanotTextBlah.BorderColor3 = Color3.fromRGB(0, 0, 0)
    IndercanotTextBlah.BorderSizePixel = 0
    IndercanotTextBlah.Position = UDim2.new(0.164000005, 0, 0.326666653, 0)
    IndercanotTextBlah.Selectable = false
    IndercanotTextBlah.Size = UDim2.new(0.667999983, 0, 0.346666664, 0)
    IndercanotTextBlah.Font = Enum.Font.GothamBold
    IndercanotTextBlah.Text = "StarX"
    IndercanotTextBlah.TextColor3 = Color3.fromRGB(255, 255, 255)
    IndercanotTextBlah.TextScaled = true
    IndercanotTextBlah.TextSize = 24.000
    IndercanotTextBlah.TextWrapped = true
    
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
    UIGradient.Parent = IndercanotTextBlah
    
    UITextSizeConstraint_2.Parent = IndercanotTextBlah
    UITextSizeConstraint_2.MaxTextSize = 52
    
    UIAspectRatioConstraint_3.Parent = IndercanotTextBlah
    UIAspectRatioConstraint_3.AspectRatio = 3.212
    
    UIAspectRatioConstraint_4.Parent = Main
    UIAspectRatioConstraint_4.AspectRatio = 1.667
    
    -- Scripts:
    
    local function HEUNEYP_fake_script() -- IndercanotTextBlah.ColorChangeScript 
        local script = Instance.new('LocalScript', IndercanotTextBlah)
    
        local button = script.Parent
        local UIGredient = button.UIGradient
        local NeedToChange = script.Parent.Parent.IndercantorBlahblah
        local userInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
    
        -- ColorSequences ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂªÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â³ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â«ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â£ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â±ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€¦Ã‚Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂªÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂµÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂµÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â¢ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â§ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€šÃ‚ÂÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â¥ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â°ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂªÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂµÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€šÃ‚ÂÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡
        local green_Color = {
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), 
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 0)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
        }
    
        local red_Color = {
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), 
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 0)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
        }
    
        local current_Color = red_Color
        local target_Color = green_Color
        local is_Green = false
        local transition = false
        local transition_Time = 1
        local start_Time
    
        local function startColorTransition()
            transition = true
            start_Time = tick()
        end
    
        RunService.Heartbeat:Connect(function()
            if transition then
                local elapsed = tick() - start_Time
                local alpha = math.clamp(elapsed / transition_Time, 0, 1)
    
                local new_Color = {}
                for i = 1, #current_Color do
                    local start_Color = current_Color[i].Value
                    local end_Color = target_Color[i].Value
                    new_Color[i] = ColorSequenceKeypoint.new(
                        current_Color[i].Time,
                        start_Color:Lerp(end_Color, alpha)
                    )
                end
    
                UIGredient.Color = ColorSequence.new(new_Color)
    
                if alpha >= 1 then
                    transition = false
                    current_Color, target_Color = target_Color, current_Color
                end
            end
        end)
    
        local function toggleColor()
            if not transition then
                is_Green = not is_Green
                if is_Green then
                    target_Color = green_Color
                    NeedToChange.BackgroundColor3 = Color3.new(0, 1, 0)
                else
                    target_Color = red_Color
                    NeedToChange.BackgroundColor3 = Color3.new(1, 0, 0)
                end
                startColorTransition()
            end
        end
    
        button.MouseButton1Click:Connect(toggleColor)
    
        userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.E then
                toggleColor()
            end
        end)
        RunService.PreSimulation:Connect(function()
        if is_Green then
        for _=1,15 do
           AutoParry.perform_parry()
        end
        end
        end)
    end
    coroutine.wrap(HEUNEYP_fake_script)()
    local function WWJM_fake_script() -- Main.LocalScript 
        local script = Instance.new('LocalScript', Main)
    
        local UserInputService = game:GetService("UserInputService")
        
        local gui = script.Parent
        local dragging
        local dragInput
        local dragStart
        local startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        
            -- ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€¦ ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â° Tween ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€¦Ã‚Â¾ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â·ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€¹Ã¢â‚¬ ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â­ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â«ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â²ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â£ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â¥ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â·ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€¹Ã¢â‚¬ ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â­ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ÂÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚ÂµÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€¹Ã¢â‚¬ ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â­ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ Frame ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂºÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’ Ãƒâ€šÃ‚Â¹ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂºÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â­ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â¢ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€¹Ã¢â‚¬ ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â²ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â£ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â²ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€¦Ã‚Â¡ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â£ÃƒÆ’ Ãƒâ€šÃ‚Â¸Ãƒâ€šÃ‚Â·ÃƒÆ’ Ãƒâ€šÃ‚Â¹Ãƒâ€¹Ã¢â‚¬ ÃƒÆ’ Ãƒâ€šÃ‚Â¸ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢
            local TweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(gui, tweenInfo, {Position = newPosition})
            tween:Play()
        end
        
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
        
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                update(input)
            end
        end)
        
    end
    coroutine.wrap(WWJM_fake_script)()
    end
    local manual_distance_adjust = 0 -- Manual distance adjustment, can be negative or positive
    
    RunService.PostSimulation:Connect(function()
        if auto_win and workspace.Alive:FindFirstChild(LocalPlayer.Name) then
            local selaf = AutoParry.get_client_ball()
            if not selaf then return end
    
            local player = LocalPlayer.Character
            local ball_Position = selaf.Position
            local ball_Distance = (player.HumanoidRootPart.Position - ball_Position).Magnitude
    
            local ping = game:GetService("Stats"):FindFirstChild("PerformanceStats"):FindFirstChild("Ping"):GetValue() or 0
            local adjusted_Distance = math.clamp(15 + (ping / 50) + manual_distance_adjust, 15, 50)
    
            if farm_method == "Wild" then
                -- Wild method
                local angle = tick() * 50
                local offset = Vector3.new(
                    math.cos(angle) * adjusted_Distance * 2, 
                    math.sin(angle) * 15, -- Y Axis adjusted from 10 to 7 for smoother movement
                    math.sin(angle) * adjusted_Distance * 2
                )
                local target_Position = ball_Position + offset
                player.HumanoidRootPart.CFrame = CFrame.new(target_Position, ball_Position)
    
            elseif farm_method == "Controlled" then
                -- Controlled method
                local axis = selected_axis or "XYZ" -- Default to all axes if no axis is selected
                local speed = selected_speed or 1 -- Default speed if none is selected
                local movement_vector = Vector3.new(0, 0, 0) -- Default movement vector
    
                -- Define movement based on the selected axis
                if axis:find("X") then
                    movement_vector = movement_vector + Vector3.new(math.cos(tick() * speed) * adjusted_Distance* 1.02, 0, 0)
                end
                if axis:find("Y") then
                    movement_vector = movement_vector + Vector3.new(0, math.sin(tick() * speed) * adjusted_Distance * 1.19, 0) -- Y Axis adjusted to 0.8x for smoother movement
                end
                if axis:find("Z") then
                    movement_vector = movement_vector + Vector3.new(0, 0, math.sin(tick() * speed) * adjusted_Distance)
                end
    
                -- Calculate target position based on the selected axis and movement vector
                local target_Position = ball_Position + movement_vector
    
                -- Move player towards the ball using the selected axis
                player.HumanoidRootPart.CFrame = CFrame.new(target_Position, ball_Position)
            end
        end
    end)
    ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(slash: any, root: any)
        task.spawn(function()
            if root.Parent and root.Parent ~= LocalPlayer.Character then
                if root.Parent.Parent ~= Alive then
                    return
                end
    
                AutoParry.ball.properties.cooldown = false
            end
        end)
    
        if AutoParry.ball.properties.auto_spam then
            for v = 1,spam_speed do
                AutoParry.perform_parry()
            end
        end
    
        if AutoParry.target.current ~= LocalPlayer.Name then
            nowprediction = true
        end
    end)
    
    ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
        if LocalPlayer.Character.Parent ~= Alive then
            return
        end
    
        if not Player.properties.grab_animation then
            return
        end
    
    
    
        Player.properties.grab_animation:Stop()
    
        local ball = AutoParry.get_client_ball()
    
        if not ball then
            return
        end
    
    
        if AutoParry.ball.properties.auto_spam then
            for v = 1,spam_speed do
                AutoParry.perform_parry()
            end
        end
    
    
        ball = nil
    end)
    local status = "Idle"  -- Initialize status
    
    task.spawn(function()
        RunService.PostSimulation:Connect(function()
            coroutine.wrap(function()
                if not auto_parry_enabled then
                    AutoParry.reset()
                    status = "Idle"  -- Reset status when auto parry is disabled
                    return
                end
    
                local Character = LocalPlayer.Character
    
                if not Character then
                    return
                end
    
                if Character.Parent == Dead then
                    AutoParry.reset()
                    status = "Idle"  -- Reset status when character is dead
                    return
                end
    
                if not AutoParry.ball.ball_entity then
                    return
                end
    
                local ball_properties = AutoParry.ball.properties
    
                -- Predict future position based on velocity
                local future_position = ball_properties.position + (ball_properties.velocity * (ball_properties.distance / ball_properties.maximum_speed))
    
                ball_properties.is_curved = AutoParry.is_curved()
    
                local baseMoveAmount = 0.51
                local moveAmount = baseMoveAmount * (1 / (AutoParry.entity_properties.distance + 0.01)) * 1000
    
                local ping_threshold = math.clamp(Player.Entity.properties.ping / 10, 10, 16)
    
                local spam_accuracy = math.min(moveAmount + (ball_properties.speed / 8.4), (50 + moveAmount)) + ping_threshold
                local parry_accuracy = ball_properties.maximum_speed / 11.7 + ping_threshold
                local ball_distance_accuracy = ball_properties.distance * 1.01 - ping_threshold / 100
    
                local player_properties = Player.Entity.properties
    
                -- Adjust accuracy if player is moving
                if player_properties.is_moving then
                    parry_accuracy *= 0.8
                end
    
                -- Adjust accuracy based on ping
                if Player.Entity.properties.ping >= 190 then
                    parry_accuracy = parry_accuracy * (1 + Player.Entity.properties.ping / 1000)
                end
    
                ball_properties.spam_range = ping_threshold + math.min(moveAmount + (ball_properties.speed / 2.3), (50 + moveAmount))
                ball_properties.parry_range = ((parry_accuracy * 1.16) + ping_threshold + ball_properties.speed) / mul
    
                -- Adjust ranges for specific sword types
                if Player.Entity.properties.sword == 'Titan Blade' then
                    ball_properties.parry_range += 11
                    ball_properties.spam_range += 2
                end    
    
                local distance_to_last_position = LocalPlayer:DistanceFromCharacter(ball_properties.last_position)
    
                -- Check if auto spam should be enabled
                if ball_properties.auto_spam and AutoParry.target.current then
                    ball_properties.auto_spam = AutoParry.is_spam({
                        speed = ball_properties.speed,
                        spam_accuracy = spam_accuracy,
                        parries = ball_properties.parries,
                        ball_speed = ball_properties.speed,
                        range = ball_properties.spam_range / (3.15 - ping_threshold / 10),
                        last_hit = ball_properties.last_hit,
                        ball_distance = ball_properties.distance,
                        maximum_speed = ball_properties.maximum_speed,
                        old_speed = AutoParry.ball.properties.old_speed,
                        entity_distance = AutoParry.entity_properties.distance,
                        last_position_distance = distance_to_last_position,
                    })
                end
    
                if ball_properties.auto_spam then
                    status = "Auto Spam Active"  -- Update status
                    return
                end
    
                -- Perform spam check for self-target
                if AutoParry.target.current and AutoParry.target.current.Name == LocalPlayer.Name then
                    ball_properties.auto_spam = AutoParry.is_spam({
                        speed = ball_properties.speed,
                        spam_accuracy = spam_accuracy,
                        parries = ball_properties.parries,
                        ball_speed = ball_properties.speed,
                        range = ball_properties.spam_range,
                        last_hit = ball_properties.last_hit,
                        ball_distance = ball_properties.distance,
                        maximum_speed = ball_properties.maximum_speed,
                        old_speed = AutoParry.ball.properties.old_speed,
                        entity_distance = AutoParry.entity_properties.distance,
                        last_position_distance = distance_to_last_position,
                    })
                end
    
                if ball_properties.is_curved then
                    status = "Curved Ball Detected"  -- Update status
                    return
                else
                    status = "Not Curved"  -- Update status
                end
    
                -- Check if the ball is within parry range and other conditions
                if ball_properties.distance > ball_properties.parry_range and
                   ball_properties.distance > parry_accuracy and 
                   ball_properties.distance > ball_properties.parry_range * (1 + Player.Entity.properties.ping / 1000) and 
                   ball_properties.distance > parry_accuracy * (1 + Player.Entity.properties.ping / 1000) then
                    return
                end
    
                if AutoParry.target.current and AutoParry.target.current ~= LocalPlayer.Character then
                    return
                end
    
                local lastPosition = LocalPlayer.Character.PrimaryPart.Position 
    
                if parry_mode == "Legit" then
                    if ball_properties.distance <= 10 and AutoParry.entity_properties.distance <= 50 then
                        if math.random(1, 2) == 1 then
                            AutoParry.perform_parry()
                            status = "Parry Performed"  -- Update status
                        end
                    end
                end
    
                -- Boost accuracy for fast balls
                if parry_mode == "Legit" and ball_properties.maximum_speed >= 250 then
                    parry_accuracy *= 1.2
                end
    
                ball_properties.last_ball_pos = ball_properties.position
                AutoParry.perform_parry()
                status = "Parry Performed"  -- Update status
    
                -- Cooldown management
                task.spawn(function()
                    repeat
                        RunService.PreSimulation:Wait(0)
                    until (tick() - ball_properties.last_hit) > 1 - (ping_threshold / 100)
    
                    ball_properties.cooldown = false
                    status = "Idle"  -- Reset status after cooldown
                end)
            end)()
        end)
    end)
    --------------
    local function get_character()
        return LocalPlayer and LocalPlayer.Character
    end
    
    local function get_humanoid_root_part()
        local char = get_character()
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    
    local function get_humanoid()
        local char = get_character()
        return char and char:FindFirstChild("Humanoid")
    end
    
    local function get_ball()
        local ballContainer = Workspace:FindFirstChild("Balls")
        if ballContainer then
            for _, ball in ipairs(ballContainer:GetChildren()) do
                if not ball.Anchored then
                    return ball
                end
            end
        end
        return nil
    end
    
    local function calculate_parry_distance()
        local ball = get_ball()
        if ball then
            local ping = LocalPlayer:GetNetworkPing() * 20
            return math.clamp(ball.Velocity.Magnitude / 2.4 + ping, 15, 200)
        end
        return 15
    end
    
    local function create_circle_visualizer()
        -- Create the visualizer part
        local visualizer = Instance.new("Part")
        visualizer.Size = Vector3.new(7, 7, 7) -- Set size to 5,5,5
        visualizer.Shape = Enum.PartType.Ball -- Make it a sphere
        visualizer.Anchored = true -- Anchor it so it doesn't fall
        visualizer.CanCollide = false -- Disable collision
        visualizer.Material = Enum.Material.ForceField -- Make it neon for better visibility
        visualizer.Color = Visualise2color -- Set its color
        visualizer.Transparency = 0.5 -- Slight transparency
        visualizer.Parent = workspace -- Add to the game world
    
        return visualizer
    end
    
    -- Toggle handling
    local visualizerPart = nil
    local function toggle_visualizer()
        if Visualise2 then
            if not visualizerPart then
                visualizerPart = create_circle_visualizer()
            end
        else
            if visualizerPart then
                visualizerPart:Destroy()
                visualizerPart = nil
            end
        end
    end
    
    -- Update the visualizer position
    RunService.Heartbeat:Connect(function()
        if Visualise2 and visualizerPart then
            local humanoidRootPart = get_humanoid_root_part()
            if humanoidRootPart then
                visualizerPart.Position = humanoidRootPart.Position
            end
        end
    end)
    
    -- Example toggle (for testing, you can replace this with a keybind toggle)
    RunService.RenderStepped:Connect(function()
        toggle_visualizer()
    end)
                
    -- Visualizer Settings
    -- Visualizer Logic
    local sphere
    
    local function create_visualizer()
        if sphere then return end -- Avoid duplicating the sphere
    
        sphere = Instance.new("Part")
        sphere.Shape = Enum.PartType.Ball
        sphere.Anchored = true
        sphere.CanCollide = false
        sphere.CastShadow = false
        sphere.Transparency = 1 -- Hidden by default
        sphere.Material = Enum.Material.ForceField
        sphere.Parent = Workspace
    end
    
    local function update_visualizer()
        if not visualise then
            if sphere then
                sphere.Transparency = 1
            end
            return
        end
    
        local humanoidRootPart = get_humanoid_root_part()
        if not humanoidRootPart then
            if sphere then
                sphere.Transparency = 1
            end
            return
        end
    
        local parryDistance = calculate_parry_distance()
        if sphere then
            sphere.Transparency = 0.5
            sphere.Size = Vector3.new(parryDistance * 2, parryDistance * 2, parryDistance * 2)
            sphere.Position = humanoidRootPart.Position
            sphere.Color = VisualiseColor
        end
    end
    
    -- Ball Velocity Toggle
                -- Toggle for displaying Ball Velocity
    
    local function update_ball_velocity_display(ball, velocityText)
        if not BallVelocity then
            velocityText.Text = ""
            return
        end
    
        if ball then
            local velocity = ball.Velocity.Magnitude
            velocityText.Text = string.format("Ball Velocity: %.2f", velocity)
        end
    end
    
    local function create_ball_velocity_display(ball)
        -- Check if the display already exists
        local existingDisplay = ball:FindFirstChild("BallVelocityDisplay")
        if existingDisplay then
            return existingDisplay
        end
    
        -- Create the BillboardGui for the velocity display
        local ballVelocityDisplay = Instance.new("BillboardGui")
        ballVelocityDisplay.Name = "BallVelocityDisplay"
        ballVelocityDisplay.Adornee = ball
        ballVelocityDisplay.Size = UDim2.new(0, 200, 0, 50)
        ballVelocityDisplay.StudsOffset = Vector3.new(0, 5, 0) -- Position above the ball
        ballVelocityDisplay.Parent = ball
    
        -- Create the text label
        local velocityText = Instance.new("TextLabel")
        velocityText.Size = UDim2.new(1, 0, 1, 0)
        velocityText.BackgroundTransparency = 1
        velocityText.TextColor3 = Color3.new(1, 1, 1) -- White text
        velocityText.TextSize = 18
        velocityText.Text = ""
        velocityText.Parent = ballVelocityDisplay
    
        return velocityText
    end
    
    -- Monitor and update ball velocity
    local lastBall
    RunService.RenderStepped:Connect(function()
        if not BallVelocity then
            if lastBall and lastBall:FindFirstChild("BallVelocityDisplay") then
                lastBall.BallVelocityDisplay:Destroy()
            end
            lastBall = nil
            return
        end
    
        local ball = get_ball()
        if ball ~= lastBall then
            -- Clear the previous display
            if lastBall and lastBall:FindFirstChild("BallVelocityDisplay") then
                lastBall.BallVelocityDisplay:Destroy()
            end
    
            -- Create a new display for the current ball
            if ball then
                local velocityText = create_ball_velocity_display(ball)
                lastBall = ball
    
                -- Update the text periodically
                RunService.RenderStepped:Connect(function()
                    if ball and velocityText then
                        update_ball_velocity_display(ball, velocityText)
                    end
                end)
            end
        end
    end)
    
    -- Autofarm Logic
    
    local function autofarm()
        if not AutoFarm then return end
    
        local ball = get_ball()
        local humanoidRootPart = get_humanoid_root_part()
        if not ball or not humanoidRootPart then return end
    
        local position = ball.Position
        if AutoFarmType == "UnderBall" then
            humanoidRootPart.CFrame = CFrame.new(position - Vector3.new(0, 10, 0))
        elseif AutoFarmType == "X Orbit" then
            local angle = tick() * math.pi * 2 / (AutoFarmOrbit / 5)
            humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(math.cos(angle) * 10, 0, math.sin(angle) * 10))
        elseif AutoFarmType == "Y Orbit" then
            local angle = tick() * math.pi * 2 / (AutoFarmOrbit / 5)
            humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, math.sin(angle) * 10, math.cos(angle) * 10))
        end
    end
    
    -- AI Play Logic
    
    local function ai_play()
        if not AiPlay then return end
    
        local ball = get_ball()
        local humanoidRootPart = get_humanoid_root_part()
        local humanoid = get_humanoid()
        if not ball or not humanoidRootPart or not humanoid then return end
    
        local ballPosition = ball.Position
        local playerPosition = humanoidRootPart.Position
        local distance = (ballPosition - playerPosition).Magnitude
    
        if distance <= 20 then
            humanoid:Move(Vector3.zero)
            return
        end
    
        local direction = (ballPosition - playerPosition).Unit
        local targetPosition = playerPosition + direction * math.min(distance - 20, AiPlaySpeed / 10)
    
        if AiPlayType == "Legit" then
            humanoid.WalkSpeed = 35
        elseif AiPlayType == "Blatant" then
            humanoid.WalkSpeed = AiPlaySpeed
        end
    
        humanoid:MoveTo(targetPosition)
    end
    
    -- Main Loops
    RunService.RenderStepped:Connect(function()
        update_visualizer()
        autofarm()
        ai_play()
    end)
    
    -- Initialize the visualizer
    create_visualizer()



    
    --------------                    
                                           
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fsploit/UI-lib/refs/heads/main/Fluentremake.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    



    local Window = Fluent:CreateWindow({
        Title = "Blade Ball - Star X Hub V2",
        SubTitle = "By CodeE4X",
        TabWidth = 150,
        Size = UDim2.fromOffset(500, 250),
        Acrylic = false,
        Theme = "Midnight",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
          
    
    local Tabs = {
    Home = Window:AddTab({ Title = "Home(READ)", Icon = "home" }),
        Main = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "box" }),
        Visual = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Setting = Window:AddTab({ Title = "Settings", Icon = "cog" }),
    }

    Window:SelectTab(1)
    
     do
    local r = Tabs.Home:AddSection("Info 💸")
                        
    Tabs.Home:AddParagraph({
        Title = "Owner",
        Content = "-CodeE4X\n-Frostware Thanks for lib and some!"
})
                    
    Tabs.Home:AddParagraph({
        Title = "WARNING BIG ANNOUNCEMENT!!!!",
        Content = "MY GITHUB GET HACKED By One Of Black Hat Hacker(Xyb) whatever if u dont know him.
But Pls Be Carefull If u using My Script, maybe it will Have Stealer Thinggy SHIT"
})
                    
Tabs.Home:AddButton({
        Title = "Copy Discord(PWEASE GYASS)",
        Description = "Copies the discord link",
        Callback = function()
            setclipboard("https://discord.gg/b7yA7uTfmp")
            Fluent:Notify({
                Title = "Star X Hub",
                Content = "Join Our Server To get Support",
                Duration = 10
            })
        end
})

Tabs.Home:AddParagraph({
        Title = "Why Star X Hub Get Removed For A While?",
        Content = "So Real owner is sick(very seriously), And Get Rest 3 Month and when owner back, owner discord account get suspend 2 years because My Server Have Nazi Flag Emoji LOL(i got got suspend 6 account💀), Instanly Star X Hub Server Got Deleted and all file gone(cuz i put file script there, *me being dumbass)"
})
           
    end                    
                        
    do
        local sswdqd = Tabs.Main:AddSection("Main 👑")
        local auto_parry = Tabs.Main:AddToggle("ap",{
            Title = "Auto Parry", 
            Description = "Auto Parry The Balls",
            Default = true,
        })
        local auto_pary = Tabs.Main:AddToggle("apa",{
            Title = "Auto Spam", 
            Description = "Auto Spam When Clashes",
            Default = false,
        })
        local aut_pary = Tabs.Main:AddToggle("apaa",{
            Title = "Manual Spam", 
            Description = "Backup For Auto Spam",
            Default = true,
        })
    

    
    
        local radwda = Tabs.Farm:AddSection("Farms 🎣")

            
        local ai_pary = Tabs.Farm:AddToggle("pppa",{
            Title = "Ai play", 
            Description = "Ai play ",
            Default = false,
        })

        local Dropdown = Tabs.Farm:AddDropdown("Dropdown", {
            Title = "Ai Type",
            Values = {"Legit", "Blatant"},
            Multi = false,
            Default = 1,
        })
    
        Dropdown:SetValue("Legit")
    
        Dropdown:OnChanged(function(Value)
            AiPlayType = Value
        end)		
    local Slider = Tabs.Setting:AddSlider("Slider", {
            Title = "Blatant Speed",
            Description = "For Blatant Mode",
            Default = 20,
            Min = 0,
            Max = 300,
            Rounding = 1,
            Callback = function(Value)
                AiPlaySpeed = Value
            end
        })
                        
        ai_pary:OnChanged(function(v)
            AiPlay = v
        end)
                        
        auto_parry:OnChanged(function(v)
            auto_parry_enabled = v
        end)
                        
        auto_pary:OnChanged(function(v)
            auto_pary_enabled = v
        end)
                        
        aut_pary:OnChanged(function(v)
            ManualSpam()
        end)
                        
                        
        local parry_mode = Tabs.Setting:AddDropdown("pm",{
            Title = "Parry Mode",
            Description = "Choose a parry mode",
            Values = {"Legit", "Rage"},
            Multi = false,
            Default = 2,
        })
    
        parry_mode:OnChanged(function(v)
            parry_mode = tostring(v)
            print(v)
        end)
    
    
        local anti_lag = Tabs.Visual:AddToggle("al",{
            Title = "Anti Lag", 
            Description = "Removes Meshes in the game (recommended on Low end device)",
            Default = false,
        })
    
        anti_lag:OnChanged(function(v)
            anti_lag_enabled = v
    
            if anti_lag_enabled then
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                lighting.Brightness = 0
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("MeshPart") then
    
    
                    elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                        v.Enabled = false
                    end
                end
                lighting.FogEnd = 9e9
    
    
            else
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = true
                lighting.Brightness = 2
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Part") or v:IsA("MeshPart") then
    
    
                    elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                        v.Enabled = true
                    end
                end
            end
        end)
    end
    
    
    
    do
        local ball_trail = Tabs.Visual:AddToggle("bt",{
            Title = "Ball Trail", 
            Description = "Trail For Your Balls",
            Default = false,
        })
    
        local visualize = Tabs.Visual:AddToggle("vl",{
            Title = "Visualize", 
            Description = "Visualizer",
            Default = true,
        })
    
    local visualizeee = Tabs.Visual:AddToggle("vl",{
            Title = "View Velocity", 
            Description = "Views the ball velocity",
            Default = false,
        })
    
        visualizeee:OnChanged(function(v)
            BallVelocity = v
        end)
            
        visualize:OnChanged(function(v)
            visualize_Enabled = v
        end)
    
        ball_trail:OnChanged(function(v)
            ball_trial_Enabled = v
        end)
    
    end
    
    
    do
        local sswdqd = Tabs.Setting:AddSection("Setting")
        local dymanic_curve_check = Tabs.Setting:AddToggle("dcc",{
            Title = "Curve Detect", 
            Description = "Auto Spam",
            Default = true,
        })
        dymanic_curve_check:OnChanged(function(v)
            dymanic_curve_check_enabled = v
        end)
    
        local adjust_spam_speed = Tabs.Setting:AddDropdown("Ass",{
            Title = "Spam Speed",
            Description = "Adjust the Spam Speed",
            Values = {1,2,3,4,5,6,7,8,9,10,},
            Multi = false,
            Default = 10,
        })
    
        adjust_spam_speed:OnChanged(function(v)
            spam_speed = v
        end)
    end
                        
                  
     do 
    local Slider = Tabs.Config:AddSlider("Slider", {
            Title = "Walk speed",
            Description = "Edits the players walkspeed",
            Default = 30,
            Min = 0,
            Max = 500,
            Rounding = 1,
            Callback = function(Value)
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    print("Hi")
            end
        })
      local Slider = Tabs.Config:AddSlider("Slider", {
            Title = "Jump power",
            Description = "Edits The player Jump Power",
            Default = 40,
            Min = 0,
            Max = 500,
            Rounding = 1,
            Callback = function(Value)
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    print("Hi")
            end
        })
      local Slider = Tabs.Config:AddSlider("Slider", {
            Title = "FOV",
            Description = "Edits the Camera Field of View [FOV]",
            Default = 70,
            Min = 0,
            Max = 500,
            Rounding = 1,
            Callback = function(Value)
                local FovNumber = Value
    local Camera = workspace.CurrentCamera
    Camera.FieldOfView = FovNumber
    print("Hi")
            end
        })
      local Slider = Tabs.Config:AddSlider("Slider", {
            Title = "Gravity",
            Description = "Edits your Gravity",
            Default = 197,
            Min = 0,
            Max = 500,
            Rounding = 1,
            Callback = function(Value)
                workspace.Gravity = Value
    print("Hi")
            end
        })
    end        
    
    RunService.PostSimulation:Connect(function()
    while true do
    print("hi")
    task.wait(10)
    end
    end)
    end)()
    end)
