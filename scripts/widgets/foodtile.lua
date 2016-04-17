require "class"

--local TileBG = require "widgets/tilebg"
--local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
--local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
--local TabGroup = require "widgets/tabgroup"
--local UIAnim = require "widgets/uianim"
--local Text = require "widgets/text"

local FoodTile = Class(Widget, function(self, foodname)
    Widget._ctor(self, "FoodTile")
    self.img = self:AddChild(Image())
    self.atlas = resolvefilepath("images/inventoryimages.xml")
    self:SetClickable(false)
    if foodname then
        self.foodname = recipe
        self.img:SetTexture(self.atlas, foodname..".tex")
        --self:MakeNonClickable()
    end
end)

function FoodTile:SetRecipe(foodname)
    self.foodname = foodname
    self.img:SetTexture(self.atlas, foodname..".tex")
end

function FoodTile:SetCanCook(cancook)
    if cancook then
        self.img:SetTint(1,1,1,1)
    else
        self.img:SetTint(0,0,0,1)
    end
end

return FoodTile