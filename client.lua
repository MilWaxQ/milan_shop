
-- Változók a képernyőre való rendereléshez
local sX, sY = guiGetScreenSize()
local oX, oY = 2560, 1080
local scale = sY / oY

local selectedShopElement = nil
local shopItems = {}
local cart = {}
local showCart = false
local cartItemCount = 0

--Scroll változók
local maxItemCount = 14
local scrollPosition = 0

local shopBoxW, shopBoxH = 400 * scale, 590 * scale
local shopBoxX, shopBoxY

--Itemek fogadása
function receiveItems(items)
  shopItems = items
end
addEvent("shop->receiveItems", true)
addEventHandler("shop->receiveItems", root, receiveItems)

--Kosár betöltése
function receiveCart(cartData, itemCount)
  cart = cartData
  cartItemCount = itemCount
end
addEvent("shop->receiveCart", true)
addEventHandler("shop->receiveCart", root, receiveCart)

-- Boxok, Szövegek renderelése
function onRender()

  -- Loop az összes ped-en
  for k, v in ipairs(getElementsByType("ped")) do
    local shopName = getElementData(v, "shop:name")
    if (shopName) then
      local screenX, screenY = getScreenFromWorldPosition(getPedBonePosition(v, 6))
      if (screenX and screenY) then

        -- Amennyiben látható a ped, a név kiírása a felhasználó képernyőjére
        dxDrawText(shopName, screenX-20, screenY-80, screenX+20, screenY, tocolor(255, 255, 255), 1.5, "default", "center", "center", false, false, false, true)
      end
    end
  end

  if (selectedShopElement ~= nil and #shopItems > 0) then
    --Bolt adatainak lekérdezése, méretek megadása
    local shopName = getElementData(selectedShopElement, "shop:name")
    shopBoxX, shopBoxY = getScreenStartPositionFromBox(shopBoxW, shopBoxH, 0, 0, "center", "center")

    --Bolt box renderelése
    dxDrawRectangle(shopBoxX, shopBoxY, shopBoxW, shopBoxH, tocolor(0, 0, 0, 240))

    if (showCart) then
      --Kosár szöveg renderelése
      dxDrawText("Kosár", shopBoxX, shopBoxY, shopBoxX+shopBoxW, shopBoxY+30, tocolor(255, 255, 255), 1.5, "default", "center", "center", false, false, false, true)
      
      for i=1+scrollPosition, (#cart > maxItemCount and maxItemCount+scrollPosition or #cart) do
        --Adott sor Y helyzete
        local rowY = shopBoxY+30 + ((i-1)*40)
      
        --Sor box rajzolás, szövegek kiírása
        dxDrawRectangle(shopBoxX, rowY, shopBoxW, 40, (i % 2 == 0 and tocolor(25, 25, 25) or tocolor(50, 50, 50)))
        dxDrawText(cart[i]["name"], shopBoxX+10, rowY+2, shopBoxX + shopBoxW, rowY + 40 - 5, tocolor(255, 255, 255), 1.2, "default", "left", "center", false, false, false, true)
        dxDrawText(cart[i]["count"].. "db", shopBoxX+10, rowY+2, shopBoxX + shopBoxW - 5, rowY + 40 - 5, tocolor(255, 255, 255), 1.2, "default", "right", "center", false, false, false, true)
      end
    else
      --Bolt név renderelése
      dxDrawText(shopName, shopBoxX, shopBoxY, shopBoxX+shopBoxW, shopBoxY+30, tocolor(255, 255, 255), 1.5, "default", "center", "center", false, false, false, true)

      for i=1+scrollPosition, (#shopItems > maxItemCount and maxItemCount+scrollPosition or #shopItems) do
        --Adott sor Y helyzete
        local rowY = shopBoxY+30 + ((i-1-scrollPosition)*40)

        --Sor box rajzolás, szövegek kiírása
        dxDrawRectangle(shopBoxX, rowY, shopBoxW, 40, (i % 2 == 0 and tocolor(25, 25, 25) or tocolor(50, 50, 50)))
        dxDrawText(shopItems[i]["name"], shopBoxX+10, rowY+2, shopBoxX + shopBoxW, rowY + 40 - 5, tocolor(255, 255, 255), 1.2, "default", "left", "top", false, false, false, true)
        dxDrawText(shopItems[i]["price"].. "Ft", shopBoxX+10, rowY+2, shopBoxX + shopBoxW, rowY + 40 - 5, tocolor(255, 255, 255), 1, "default", "left", "bottom", false, false, false, true)

        --'Kosárba' gomb
        local cartButtonX, cartButtonY = shopBoxX + shopBoxW - 90, rowY + 10
        local cartButtonW, cartButtonH = 80, 20
        local buttonOpacity = isMouseInPosition(cartButtonX, cartButtonY, cartButtonW, cartButtonH) and 200 or 150
        dxDrawRectangle(cartButtonX, cartButtonY, cartButtonW, cartButtonH, tocolor(0, 255, 0, buttonOpacity))
        dxDrawText("Kosárba", cartButtonX, cartButtonY, cartButtonX + cartButtonW, cartButtonY + cartButtonH, tocolor(0, 0, 0), 1.2, "default", "center", "center", false, false, false, true)
      end
    end

    --Kosár megtekintése / Fizetés
    local viewCartX, viewCartY = shopBoxX, shopBoxY + shopBoxH
    local viewCartW, viewCartH = shopBoxW, 40
    local viewCartOpacity = isMouseInPosition(viewCartX, viewCartY, viewCartW, viewCartH) and 200 or 150
    dxDrawRectangle(viewCartX, viewCartY, viewCartW, viewCartH, tocolor(0, 255, 0, viewCartOpacity))
    dxDrawText(showCart and "Fizetés" or ("Kosár megtekintése ("..cartItemCount.." termék)"), viewCartX, viewCartY, viewCartX + viewCartW, viewCartY + viewCartH, tocolor(0, 0, 0), 1.2, "default", "center", "center")
  end
end
addEventHandler("onClientRender", root, onRender)


function onKey(button, isPress)
  --Kurzor mutatása/eltüntetése az 'M' gomb megnyomására
  if (button == "m" and isPress) then
    showCursor(not isCursorShowing())
  elseif (button == "backspace" and isPress and selectedShopElement) then
    if (showCart) then showCart = false return end

    selectedShopElement = nil
    showCart = false
    scrollPosition = 0
    shopItems = {}
  elseif (button == "mouse_wheel_up") then
    if (not selectedShopElement or scrollPosition == 0) then return end

    if ((showCart and #cart > maxItemCount) or (not showCart and #shopItems > maxItemCount)) then
      scrollPosition = scrollPosition - 1
    end
  elseif (button == "mouse_wheel_down") then
    if (not selectedShopElement) then return end

    if ((showCart and #cart > maxItemCount and scrollPosition < #cart-maxItemCount) or (not showCart and #shopItems > maxItemCount and scrollPosition < #shopItems-maxItemCount)) then
      scrollPosition = scrollPosition + 1
    end
  end
end
addEventHandler("onClientKey", root, onKey)

function onClick(button, state, x, y, wx, wy, wz, clickedElement)
  if (button == "right" and state == "down") then
    if (not clickedElement) then return end
    local eX, eY, eZ = getElementPosition(clickedElement)
    local pX, pY, pZ = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(pX, pY, pZ, eX, eY, eZ)
  
    if (distance > 2) then return end

    local clickedShopID = getElementData(clickedElement, "shop:id")
    if (not clickedShopID) then return end

    triggerServerEvent("shop->fetchItems", localPlayer, clickedShopID)
    triggerServerEvent("shop->fetchCart", localPlayer, clickedShopID)
    
    selectedShopElement = clickedElement
  elseif (button == "left" and state == "down" and selectedShopElement) then
    local selectedShopID = getElementData(selectedShopElement, "shop:id")
    --'Kosárba' gomb kattintás
    for i=1, #shopItems do
      --Adott sor Y helyzete
      local rowY = shopBoxY+30 + ((i-1)*40)
      local cartButtonX, cartButtonY = shopBoxX + shopBoxW - 90, rowY + 10
      local cartButtonW, cartButtonH = 80, 20
      if (isMouseInPosition(cartButtonX, cartButtonY, cartButtonW, cartButtonH)) then
        local itemName = shopItems[i]["name"]
        for k, v in ipairs(cart) do
          if (v["name"] == itemName) then
            triggerServerEvent("shop->updateCart", localPlayer, selectedShopID, itemName, v["count"])
            return
          end
        end
        triggerServerEvent("shop->insertItemIntoCart", localPlayer, selectedShopID, itemName)
      end
    end

    -- 'Kosár megtekintése' gombra kattintás
    local viewCartX, viewCartY = shopBoxX, shopBoxY + shopBoxH
    local viewCartW, viewCartH = shopBoxW, 40
    if (isMouseInPosition(viewCartX, viewCartY, viewCartW, viewCartH)) then
      if (not showCart) then
        if (#cart == 0) then
          outputChatBox("Nincs semmi a kosaradban", 255, 255, 255)
          return
        end
        showCart = true
        scrollPosition = 0
      else
        if (#cart > 0) then
          outputChatBox("Sikeresen megvásároltad a következő itemeket:", 255, 255, 255)
          for k, v in pairs(cart) do
            outputChatBox("- #00FF00"..v["count"].."x #FFFFFF"..v["name"], 255, 255, 255, true)
          end
          showCart = false
          scrollPosition = 0
          triggerServerEvent("shop->clearCart", localPlayer, selectedShopID)
        end
      end
    end
  end
end
addEventHandler("onClientClick", root, onClick)

--Helper funkciók az MTA Wikiről
function getScreenStartPositionFromBox (width, height, offsetX, offsetY, startIndicationX, startIndicationY)
	
	local startX = offsetX 
	local startY = offsetY
		
	if startIndicationX == "right" then
		startX = sX - (width + offsetX)
	elseif startIndicationX == "center" then
		startX = sX / 2 - width / 2 + offsetX
	end
		
	if startIndicationY == "bottom" then
		startY = sY - (height + offsetY)
	elseif startIndicationY == "center" then
		startY = sY / 2 - height / 2 + offsetY
	end
	
	return startX, startY
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end