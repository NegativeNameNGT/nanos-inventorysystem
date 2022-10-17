Package.Require("uuid.lua")
Package.Require("config.lua")

Player.Subscribe("Spawn", function(player)
  player:SetValue("inventory_usedslots", CreateUsedSlots())
  player:SetValue("inventory", {})
end)

local items = {}

function CreateUsedSlots()
	local table = {}
	for i = PLAYER_SLOTS,1, - 1
	do
		table[i] = ""
	end
	return table
end

function RegisterItem(name, icon, metadata, is_stackable, luaevent, deleteafteruse)
	local item = {
		["name"] = name,
		["icon"] = icon,
		["metadata"] = metadata,
		["is_stackable"] = is_stackable,
		["LuaEvent"] = luaevent,
		["DeleteAfterUse"] = deleteafteruse
	}
	items[item.name] = item
end
Package.Export("RegisterItem", RegisterItem)

function GetEmptySlot(player)
	local usedslots = player:GetValue("inventory_usedslots")
	
	for k,v in pairs (usedslots) do
		if v == "" then return k end
	end
end

function SetSlotState(player, slot, uuid)
	local usedslots = player:GetValue("inventory_usedslots")
	usedslots[slot + 1] = uuid
	player:SetValue("inventory_usedslots", usedslots)
end

-- UTILITY
function MakeItemStructure(name, quantity, metadata, slot)
	local Item = {
		["name"] = name,
		["quantity"] = quantity,
    ["metadata"] = metadata,
		["slot"] = tostring(slot)
	}
	return Item
end

function UpdateInventoryItem(player, uuid, new_item)
	local inventory = player:GetValue("inventory")
	inventory[uuid] = new_item
	player:SetValue("inventory", inventory)
end

function DoesItemRowExists(row_name)
	if items[row_name] ~= nil then
		return true
	else
		Package.Warn("You are trying to add an item that doesn't exists! ")
		return false
	end
end

function IsItemStackable(item_data)
	return item_data["is_stackable"]
end

function GetItemIcon(item_data)
	return item_data["icon"]
end

function GetItemMetadata(item_data)
	return item_data["metadata"]
end

function AddItemQuantity(player, ItemUUID)
	local inventory = player:GetValue("inventory")
	local slot = inventory[ItemUUID].slot

	inventory[ItemUUID].quantity = inventory[ItemUUID].quantity + 1

	player:SetValue("inventory", inventory)
	Events.CallRemote("IncrementInventoryItem", player, slot)
end

-- SERVER ADD ITEM
function Player:AddItemToPlayer(item_rowname, isload, slot, quantity, uuid, metadata, save)
  local player = self

	local item_data
	
	if player:GetValue("inventory") == nil then player:SetValue("inventory", {}) end
	if DoesItemRowExists(item_rowname) == false then return end
	item_data = items[item_rowname]
	if uuid == nil then uuid = generateUUID():lower():gsub('%-', '') end
	if slot == nil then slot = GetEmptySlot(player) - 1 end
	if metadata == nil then metadata = item_data["metadata"] end

	if IsItemStackable(item_data) == true then
		
		-- LOOPS ON ALL ITEMS OF PLAYER'S INVENTORY AND IF AN ITEM OF SAME TYPE IS FOUND, ADDS QUANTITY
		for k,v in pairs(player:GetValue("inventory")) do
			if v.name == item_rowname then
				AddItemQuantity(player, k)
				if save == nil then
					SavePlayerInventory(player)
				end
				return
			end
		end
	end
  Package.Log("Added item to player")
	local new_item = MakeItemStructure(item_rowname, quantity, metadata, slot)
	UpdateInventoryItem(player, uuid, new_item)
	
	SetSlotState(player, slot, "used")
	if save == nil then
		SavePlayerInventory(player)
		Events.CallRemote("ClientAddItem", player, uuid, slot, GetItemIcon(item_data), item_data["metadata"]["rarity"], quantity, IsItemStackable(item_data))
	else
		return {
			["uuid"] = uuid,
			["slot"] = slot,
			["item_icon"] = GetItemIcon(item_data),
      			["metadata"] = metadata,
			["quantity"] = quantity,
			["IsItemStackable"] = IsItemStackable(item_data)
		}
	end

end

Events.Subscribe("MoveItem", function(player, from, to)
	local inventory = player:GetValue("inventory")
	if inventory[from] ~= nil then
		local item_from = inventory[from]
		local old_from_slot = item_from.slot

		inventory[from].slot = tostring(to)
		
		player:SetValue("inventory", inventory)
		SetSlotState(player, tonumber(old_from_slot), "")
		SetSlotState(player, to, "used")
		
		SavePlayerInventory(player)

		Events.CallRemote("MovedItem", player, old_from_slot, to)
	end
end)

function RemoveItemFromInventory(player, uuid)
	local inv_table = player:GetValue("inventory")
	local dataslot = inv_table[uuid]

	local slot = dataslot.slot
	Events.CallRemote("RemoveInventoryItem", player, slot)

	SetSlotState(player, dataslot.slot, "")
	inv_table[uuid] = nil
	player:SetValue("inventory", inv_table)
	SavePlayerInventory(player)
end

Events.Subscribe("OnItemUsed", function(player, uuid)
			local inventory = player:GetValue("inventory")
			if inventory[uuid] == nil then return end

			local item_instance = inventory[uuid]
			local item_data = items[item_instance.name]

			if tonumber(item_instance.quantity) <= 0 then
				return
			end

			if item_data["DeleteAfterUse"] ~= true then
				item_data["LuaEvent"](player, uuid, item_instance.metadata)
			else
				if(tonumber(item_instance.quantity) - 1 == 0) then
					item_data["LuaEvent"](player, uuid, item_instance.metadata)
					RemoveItemFromInventory(player, uuid)
				else

					local current_quantity = tonumber(item_instance.quantity)
					local new_quantity = current_quantity - 1

					inventory[uuid].quantity = new_quantity
					player:SetValue("inventory", inventory)

					item_data["LuaEvent"](player, uuid, item_instance.metadata)
					SavePlayerInventory(player)

					Events.CallRemote("DecrementInventoryItem", player, tonumber(inventory[uuid].slot))
				end
			end		
end)

Package.Require("InventorySave.lua")
Package.Require("Items.lua")
