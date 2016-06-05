local function IsDST()
	return GLOBAL.TheSim:GetGameID() == "DST"
end

local function GetPlayer()
	if IsDST() then
		return GLOBAL.ThePlayer
	else
		return GLOBAL.GetPlayer()
	end
end

local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local GetPlayer = GLOBAL.GetPlayer

local MouseFoodCrafting = require "widgets/mousefoodcrafting"
local Constants = require "constants"

Assets = {
	Asset("ATLAS", "images/food_tags.xml"),
	Asset("ATLAS", "images/recipe_hud.xml"),
}

local _SimLoaded = false
local _GameLoaded = false

local function OnLoad(player)
	if player and player.components and not player.components.knownfoods then
  	player:AddComponent('knownfoods')
	end
end

local function OnAfterLoad()
	local player = GetPlayer()

	if player and player.components and player.components.knownfoods then
		local config = {lock_uncooked=GetModConfigData("lock_uncooked")}
		player.components.knownfoods:OnAfterLoad(config)
    player.HUD.controls.foodcrafting:OnAfterLoad(config)
	end
end

local function OnSimLoad()
	_SimLoaded = true
	if _GameLoaded == true then
		OnAfterLoad()
	end
end

local function OnGameLoad()
	_GameLoaded = true
	if _SimLoaded == true then
		OnAfterLoad()
	end
end


local function ControlsPostInit(self)
  self.foodcrafting = self.containerroot:AddChild(MouseFoodCrafting(GetPlayer()))
  self.foodcrafting:Hide()
end

local function CookerPostInit(inst)
	if not inst.components.stewer then return end

-- store base metods
  local onopenfn = inst.components.container.onopenfn
  local onclosefn = inst.components.container.onclosefn
	local ondonecookingfn = inst.components.stewer.ondonecooking

-- define modded actions
  local function mod_onopen(inst)
    if onopenfn then onopenfn(inst) end
    GetPlayer().HUD.controls.foodcrafting:Open(inst)
  end

  local function mod_onclose(inst)
    if onclosefn then onclosefn(inst) end
    GetPlayer().HUD.controls.foodcrafting:Close(inst)
  end

	local function mod_ondonecooking(inst)
    if ondonecookingfn then ondonecookingfn(inst) end
		local foodname = inst.components.stewer.product
		GetPlayer().components.knownfoods:IncrementCookCounter(foodname)
  end

	local function cookerchangefn(inst)
		local HUD = GetPlayer().HUD
		if HUD then HUD.controls.foodcrafting:SortFoods() end
	end

-- override methods
  inst.components.container.onopenfn = mod_onopen
  inst.components.container.onclosefn = mod_onclose
	inst.components.stewer.ondonecooking = mod_ondonecooking

	inst:ListenForEvent("itemget", cookerchangefn)
	inst:ListenForEvent("itemlose", cookerchangefn)
end

local function FollowCameraPostInit(inst)
	local old_can_control = inst.CanControl
	inst.CanControl = function(inst)
		return old_can_control(inst) and not GetPlayer().HUD.controls.foodcrafting:IsFocused()
	end
end

-- follow camera modification is required to cancel the scrolling
AddClassPostConstruct("cameras/followcamera", FollowCameraPostInit)
AddPlayerPostInit(OnLoad)

-- these two loads race each other, last one gets to launch OnAfterLoad
AddSimPostInit(OnSimLoad) -- fires before game init
AddGamePostInit(OnGameLoad) -- fires last, unless it is first game launch, then it fires first
AddClassPostConstruct("widgets/controls", ControlsPostInit)

-- sadly we have to try every prefab ingame, since we just can't bind events onto postinit of stewer.host prefab
AddPrefabPostInitAny(CookerPostInit)
