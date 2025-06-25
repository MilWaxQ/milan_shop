
--MySQL adatok
local db
local host = "localhost"
local username = "root"
local password = ""
local database = "devmta"

--Bolt NPC-k
local shops = {}

function init()
  --MySQL csatlakozás
  db = dbConnect("mysql", "dbname="..database..";host="..host, username, password, "autoreconnect=1")
  if db then
    outputServerLog("DevMTA: Sikeres MySQL csatlakozás")

    --Boltok betöltése
    local shops = dbPoll(dbQuery(db, "SELECT * FROM shops"), -1)
    for k, v in ipairs(shops) do
      local npc = createPed(67, v.posX, v.posY, v.posZ)
      setElementFrozen(npc, true)

      --NPC adatainak beállítása
      setElementData(npc, "shop:name", v.name.." #00FF00("..v.ID..")")
      setElementData(npc, "shop:id", v.ID)
      shops[v.ID] = npc
    end
  end
end
addEventHandler("onResourceStart", resourceRoot, init)

addCommandHandler("goto", function(p, c, x, y, z)
  if (x and y and z) then
    setElementPosition(p, x, y, z)
  end
end)

function fetchItems(shopID)
  --Egy tömb az itemek tárolására
  local items = {}

  --Itemek lekérdezése shopID alapján
  local results = dbPoll(dbQuery(db, "SELECT * FROM items WHERE shopID = ?", shopID), -1)

  --Loop az eredményen, berakás az items listába
  for k, v in ipairs(results) do
    local item = {name=v.name, price=v.price}
    table.insert(items, item)
  end

  --Items küldése a kliensnek
  triggerClientEvent(source, "shop->receiveItems", source, items)
end
addEvent("shop->fetchItems", true)
addEventHandler("shop->fetchItems", root, fetchItems)

function fetchCart(shopID)
  local serial = getPlayerSerial(source)
  local results = dbPoll(dbQuery(db, "SELECT * FROM carts WHERE shopID = ? AND serial = ?", shopID, serial), -1)

  local cartData = {}
  local cartItemCount = 0
  for k, v in ipairs(results) do
    cartItemCount = cartItemCount + v.count
    table.insert(cartData, {name=v.itemName, count=v.count})
  end
  triggerClientEvent(source, "shop->receiveCart", source, cartData, cartItemCount)
end
addEvent("shop->fetchCart", true)
addEventHandler("shop->fetchCart", root, fetchCart)

function updateCart(shopID, itemName, count)
  local serial = getPlayerSerial(source)
  local updateQuery = dbQuery(db, "UPDATE carts SET count = ? WHERE serial = ? AND itemName = ? AND shopID = ?", count, serial, itemName, shopID)
  dbFree(updateQuery)
  triggerEvent("shop->fetchCart", source, shopID)
end
addEvent("shop->updateCart", true)
addEventHandler("shop->updateCart", root, updateCart)

function insertItemIntoCart(shopID, itemName)
  local serial = getPlayerSerial(source)
  local insertQuery = dbQuery(db, "INSERT INTO carts (serial, shopID, itemName) VALUES (?, ?, ?)", serial, shopID, itemName)
  dbFree(insertQuery)
  triggerEvent("shop->fetchCart", source, shopID)
end
addEvent("shop->insertItemIntoCart", true)
addEventHandler("shop->insertItemIntoCart", root, insertItemIntoCart)

function clearCart(shopID)
  local serial = getPlayerSerial(source)
  local deleteQuery = dbQuery(db, "DELETE FROM carts WHERE serial = ? AND shopID = ?", serial, shopID)
  dbFree(deleteQuery)
  triggerEvent("shop->fetchCart", source, shopID)
end
addEvent("shop->clearCart", true)
addEventHandler("shop->clearCart", root, clearCart)