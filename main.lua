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

local url = "https://wikipedia.org"

local dom = {}
local y = 0

local error = false
local errorCode = 0

function loadPage(url)
    local code, data, headers = https.request(url)

    if code == 200 then
        dom = htmlparser.parse(data)
        love.window.setTitle(dom:select("title")[1]:getcontent())
    else
        error = true
        errorCode = code
    end
end

function calculateWrappedHeight(text, font)
    local wrappedText = love.graphics.newText(font, text)
    wrappedText:setf(text, love.graphics.getWidth(), "left")

    return wrappedText:getHeight()
end

function render(element)
    if element.name == "h1" then
        love.graphics.setFont(openSansH1)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH1) + 20
    elseif element.name == "h2" then
        love.graphics.setFont(openSansH2)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH2) + 20
    elseif element.name == "h3" then
        love.graphics.setFont(openSansH3)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH3) + 20
    elseif element.name == "h4" then
        love.graphics.setFont(openSansH4)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH4) + 20
    elseif element.name == "h5" then
        love.graphics.setFont(openSansH5)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH5) + 20
    elseif element.name == "h6" then
        love.graphics.setFont(openSansH6)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSansH6) + 20
    elseif element.name == "p" or element.name == "aside" then
        love.graphics.setFont(openSans)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSans) + 20
    elseif element.name == "li" then
        love.graphics.setFont(openSans)
        love.graphics.printf("    - " .. element:getcontent(), 0, y, love.graphics.getWidth())

        y = y + calculateWrappedHeight(element:getcontent(), openSans) + 20
    elseif element.name == "hr" then
        love.graphics.line(10, y, love.graphics.getWidth() - 10, y)

        y = y + 20
    elseif element.name == "a" then
        love.graphics.setFont(openSans)
        love.graphics.setColor(0, 0, 255)
        love.graphics.printf(element:getcontent(), 0, y, love.graphics.getWidth())
        love.graphics.setColor(0, 0, 0)

        y = y + 20
    elseif element.name == "img" then
        local code, data = https.request(url .. "/" .. element.attributes.src)
        local file = love.filesystem.newFile("image.png", "w")
        file:write(data)
        file:close()
    end

    for _, child in ipairs(element.nodes) do
        render(child)
    end
end

function love.load()
    camera = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    loadPage(url)
end

function love.update(dt)

end

function love.draw()
    camera:attach()

    love.graphics.setBackgroundColor(255, 255, 255)
    love.graphics.setColor(0, 0, 0)

    y = 0

    if error then
        love.graphics.setFont(openSansH4)
        love.graphics.print("Error " .. errorCode)
    else
        render(dom:select("body")[1])
    end

    camera:detach()
end

function love.resize(w, h)
    camera:lookAt(w / 2, h / 2)
end

function love.wheelmoved(x, y)
    camera:move(0, y * -30)
end
