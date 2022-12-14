# nanos-inventorysystem
Serverside Modular Inventory System

Clientside events :

```lua
Events.Subscribe("ClientAddItem", function(uid, slot, icon, rarity, quantity, stackable)

end)

Events.Subscribe("MovedItem", function(slot1, slot2)

end)

Events.Subscribe("RemoveInventoryItem", function(slot)

end)

Events.Subscribe("DecrementInventoryItem", function(slot)

end)

Events.Subscribe("IncrementInventoryItem", function(slot)

end)
```

Client to Server Remote Calls :
```lua
Events.CallRemote("OnItemUsed", sSlotID) -- sSlotID needs to be in lowercase
Events.CallRemote("MoveItem", sSlotID, iToSlot) -- sSlotID needs to be in lowercase
```

Register an item
```lua
RegisterItem(sItem_id, sIcon, tMetadata, bStackable, fOnUsed, bDelete_Once_Used)

RegisterItem("myItem", "icon_path", {["rarity"] = "standard"}, false, function(player, uItemId, tItemMetadata)
   -- item behavior
end, true)
```
Giving an item to a player :
```lua
player:AddItemToPlayer("myItem")
```

Metadata management :
```lua
local tMetadata = player:GetItemMetadata(uItemID)
player:SetItemMetadata(uItemID, tNewMetadata)
```



Changing max slots :
 - Open "config.lua" file
- Edit the value of "PLAYER_SLOTS"
```lua
PLAYER_SLOTS = 64
```
