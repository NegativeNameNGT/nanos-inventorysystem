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

Register an item
```lua
RegisterItem(item_id, icon, metadata, func, delete_once_used)

RegisterItem("myItem", "chemin_vers_icon", {["rarity"] = "standard"}, function(player, itemid)
   -- item behavior
end, true)
```
Giving an item to a player :
```lua
player:AddItemToPlayer("myItem")
```

Changing max slots :
 - Open "config.lua" file
- Edit the value of "PLAYER_SLOTS"
```lua
PLAYER_SLOTS = 64
```
