local https = require("https")
local inspect = require("libs.inspect")
local Object = require("libs.classic")
local Camera = require("libs.camera")
local htmlparser = require("libs.htmlparser")

local openSans = love.graphics.newFont("assets/OpenSans-Regular.ttf", 14)
local openSansH1 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 34)
local openSansH2 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 30)
local openSansH3 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 26)
local openSansH4 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 22)
local openSansH5 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 18)
local openSansH6 = love.graphics.newFont("assets/OpenSans-Bold.ttf", 14)

-- globals
local currenturl = ""

local dom = {}
local y = 0

local error = false
local errorCode = 0

local images = {}

local camera = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function calculateWrappedWidth(text, font)
    local wrappedText = love.graphics.newText(font, text)
    wrappedText:setf(text, love.graphics.getWidth(), "left")

    return wrappedText:getWidth()
end

function calculateWrappedHeight(text, font)
    local wrappedText = love.graphics.newText(font, text)
    wrappedText:setf(text, love.graphics.getWidth(), "left")

    return wrappedText:getHeight()
end

function parseurl(partialurl)
    local parsed = ""

    if string.sub(partialurl, 1, 2) == "//" then
        parsed = "https:" .. partialurl
    else
        parsed = currenturl .. "/" .. partialurl
    end

    return parsed
end

function loadPage(url)
    local code, data, headers = https.request(url)

    if code == 200 then
        dom = htmlparser.parse(data, 4000)

        if dom:select("title")[1] then
            love.window.setTitle(dom:select("title")[1]:getcontent())
        end

        currenturl = url
    else
        error = true
        errorCode = code
    end
end

function render(element)
    local content = element:getcontent():gsub("<[^>]+>", "")

    if element.name == "h1" then
        love.graphics.setFont(openSansH1)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH1) + 20
    elseif element.name == "h2" then
        love.graphics.setFont(openSansH2)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH2) + 20
    elseif element.name == "h3" then
        love.graphics.setFont(openSansH3)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH3) + 20
    elseif element.name == "h4" then
        love.graphics.setFont(openSansH4)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH4) + 20
    elseif element.name == "h5" then
        love.graphics.setFont(openSansH5)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH5) + 20
    elseif element.name == "h6" then
        love.graphics.setFont(openSansH6)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSansH6) + 20
    elseif element.name == "p" or element.name == "aside" then
        love.graphics.setFont(openSans)
        love.graphics.printf(content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSans) + 20
    elseif element.name == "li" then
        love.graphics.setFont(openSans)
        love.graphics.printf("    - " .. content, 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(content, openSans) + 20
    elseif element.name == "hr" then
        love.graphics.line(10, y, love.graphics.getWidth() - 10, y)

        y = y + 20
    elseif element.name == "a" then
        mousex, mousey = camera:mousePosition()

        if checkCollision(mousex, mousey, 1, 1, 0, y, calculateWrappedWidth(content, openSans), calculateWrappedHeight(content, openSans)) then
            love.graphics.setFont(openSans)
            love.graphics.setColor(0, 255, 255)
            love.graphics.printf(content, 0, y, love.graphics.getWidth())
            love.graphics.setColor(0, 0, 0)

            if love.mouse.isDown(1) then
                print("Going to: " .. parseurl(element.attributes.href))
                loadPage(parseurl(element.attributes.href))
            end
        else
            love.graphics.setFont(openSans)
            love.graphics.setColor(0, 0, 255)
            love.graphics.printf(content, 0, y, love.graphics.getWidth())
            love.graphics.setColor(0, 0, 0)
        end

        y = y + calculateWrappedHeight(content, openSans) + 20
    elseif element.name == "img" then
        if not images[element.attributes.src] and images[element.attributes.src] ~= "failed" then
            local imageurl = parseurl(element.attributes.src)

            local code
            local data

            if string.sub(imageurl, -3) == "gif" then
                code = "Format not supported"
            else
                code, data = https.request(imageurl)
            end

            if code == 200 then
                images[element.attributes.src] = love.graphics.newImage(love.data.newByteData(data))
                print("Cached image: " .. imageurl)
            else
                images[element.attributes.src] = "failed"
                print("Error loading image: " .. imageurl .. " error: " .. code)
            end
        end

        if images[element.attributes.src] ~= nil and images[element.attributes.src] ~= "failed" then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(images[element.attributes.src], 0, y)
            love.graphics.setColor(0, 0, 0)

            y = y + images[element.attributes.src]:getHeight() + 20
        end
    end

    for _, child in ipairs(element.nodes) do
        render(child)
    end
end

function love.load()
    loadPage("https://wikipedia.org")
end

function love.update(dt)

end

function love.draw()
    camera:attach()

    love.graphics.setBackgroundColor(1, 1, 1)
    love.graphics.setColor(0, 0, 0)

    y = 0

    if error then
        love.graphics.setFont(openSansH4)
        love.graphics.print("Error " .. errorCode)
    else
        render(dom:select("body")[1])
    end

    camera:detach()

    love.graphics.print("FPS: " .. love.timer.getFPS())
end

function love.resize(w, h)
    camera:lookAt(w / 2, h / 2)
end

function love.wheelmoved(x, y)
    if love.keyboard.isDown("lctrl") then
        camera.scale = camera.scale + y / 2
    else
        camera:move(0, y * -30)
    end
end
