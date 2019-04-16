Shop = class()

function Shop:init()
    self.circSize = (WIDTH / 2)
    
    self.colour = color(0, 0, 0, 255)
    self.orCol = color(0, 0, 0, 255)
    
    self.border = WIDTH / 50
    
    local s = WIDTH / 12
    local hmesh = mesh() hmesh.vertices = { vec2(s/4, s/6), vec2(s/4, s*4/6), vec2(s/2, s*5/6), vec2(s/2, s*5/6), vec2(s*3/4, s*4/6), vec2(s*3/4, s/6), vec2(s*3/4, s/6), vec2(s/2, s*5/6), vec2(s/4, s/6) } 
    hmesh:setColors(255,255,255,255)
    local himg = image(s, s) setContext(himg) 
        hmesh:draw() stroke(self.colour) strokeWidth(2)
        for i = 1, #hmesh.vertices-2 do local a = hmesh.vertices[i] local b = hmesh.vertices[(i%(#hmesh.vertices-2)) + 1] line(a.x, a.y, b.x, b.y) end
    setContext()
    local himg1, himg2 = makeButtonImgs(himg, s, self.colour)
    self.backButton = Button(himg1, himg2, s / 2 + self.border, s / 2 + self.border, function() Scene:change("Title") end, vec2(s, s))
    
    self.skips = readLocalData("AmntSkips") or 0

    self.products = {}

    self.ident = "com.TheoArrouye.Scramblers"

    local prodID = {
        { id = "25skips", name = "25 Skips", type = "skips", col = color(255, 225, 0), apply = function() self:addSkips(25) end },
        { id = "100skips", name = "100 Skips", type = "skips", col = color(255, 150, 0), apply = function() self:addSkips(100) end },
        { id = "400Skips", name = "400 Skips", type = "skips", col = color(255, 80, 0), apply = function() self:addSkips(400) end },
        { id = "infskips", name = "Infinite Skips", type = "skips", col = color(255, 0, 0), apply = function() self:addSkips(math.huge) end },
        { id = "speedmode", name = "Speed Challenge Mode", type = "speed", col = color(255, 0, 0), apply = function() saveLocalData("unlockedspeed", true) end }
    }

    self.products["restore"] = { label = "Restore Purchases", type = "restore", col = color(0), order = #prodID + 1 }

    for i, prod in ipairs(prodID) do
        registerItem(self.ident .. "." .. prod.id)
        self.products[self.ident .. "." .. prod.id] = { label = prod.name, apply = prod.apply, place = 0, order = i, col = prod.col, price = "Store Loading" }
    end

    initStore()
    storeReady = false

    productPlace = 0
    collectgarbage()
end

-- iAP Handling Global Functions
function getProductInfo(id, price)
    Scene.scenes["Store"].products[id].price = price
    Scene.scenes["Store"].products[id].place = productPlace
    productPlace = productPlace + 1
end

function productBeingPurchased(id)
    purchasePending = true
    collectgarbage()
end

function restoredProducts(id)
    setProductPurchased(id)
    alert("Successfully restored product.", "Successful Restore")
end

function productPurchaseFailed()
    purchasePending = false
end

function productPurchaseSucceeded(id)
    alert("Thank you for purchasing. We hope you enjoy.", "Successful Purchase")
    purchasePending = false
    setProductPurchased(id)
end

function setProductPurchased(id)
    Scene.scenes["Store"].products[id].apply()
end

--

function Shop:onEnter()
    self.skips = readLocalData("AmntSkips") or 0
end

function Shop:addSkips(amnt)
    self.skips = self.skips + amnt
    saveLocalData("AmntSkips", self.skips)
end

function Shop:draw()
    pushStyle()
    background(255)
    
    stroke(self.colour) noFill() strokeWidth(1)
    -- ellipse(WIDTH/2, HEIGHT/2, self.circSize)
    
    font(STANDARDFONT)
    fill(self.colour)
    
    fontSize(WIDTH / 35) textAlign(LEFT) textMode(CORNER) rectMode(CENTER)
    if self.products ~= nil then
        local topY = HEIGHT/2 + (fontSize() + fontSize()) * (table.count(self.products) / 2)
        for id, product in pairs(self.products) do
            stroke(product.col)
            local w,h = textSize(product.label)
            local drawY = topY - (h * product.order) - (fontSize() * (product.order - 1))
            product.pos = vec2(WIDTH/2, drawY)

            if product.touched then
                fill(product.col)
            else
                fill(255)
            end
            product.size = vec2(self.circSize, h + fontSize() - 1)
            rect(WIDTH/2, drawY, product.size.x, product.size.y)
        
            if product.touched then
                fill(255 - product.col.r, 255 - product.col.g, 255 - product.col.b)
            else
                fill(product.col)
            end
            text(product.label, WIDTH/2 - product.size.x/2.1, drawY - h/2)
            if product.type ~= "restore" then
                local pw = textSize(product.price)
                text(product.price, WIDTH/2 + product.size.x/2.1 - pw, drawY - h/2)
            end
        end
    else
        text("Store is unavailable.\nCheck your internet connection", WIDTH / 2, HEIGHT / 2)
    end
    
    fill(self.colour)
    textMode(CENTER) fontSize(WIDTH / 20)
    text("Perks Shop", WIDTH/2, HEIGHT - fontSize())

    local smode = "No"
    if readLocalData("unlockedspeed") then smode = "Yes" end
    fontSize(WIDTH / 35) text("Your Skips: " .. self.skips .. "\nSpeed Challenge Mode Unlocked: " .. smode, WIDTH / 2, fontSize() + self.border / 2)
    
    self.backButton:draw()
    popStyle()
end

function Shop:touched(touch)
    for id, product in pairs(self.products) do
        if touch.x > product.pos.x - product.size.x/2 and touch.x < product.pos.x + product.size.x/2
        and touch.y > product.pos.y - product.size.y/2 and touch.y < product.pos.y + product.size.y/2 then
            product.touched = true
            
            if touch.state == ENDED then
                product.touched = false
                if product.type == "skips" and self.skips == math.huge then
                    alert("You already have infinite skips!", "Transaction Blocked")
                    return
                end
                if product.type == "speed" and readLocalData("unlockedspeed") then
                    alert("You already have speed challenge mode!", "Transaction Blocked")
                    return
                end
                if purchasePending then
                    alert("There is already a pending purchase", "Please Wait")
                    return
                end

                if product.type == "restore" then
                    restorePurchases()
                    return
                end

                purchaseItem(product.place)
            end
        else
            product.touched = false
        end
    end
    
    self.backButton:touched(touch)
end


