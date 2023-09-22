local http = require("socket.http")

local url = "http://motherfuckingwebsite.com"
local page = {}

local openSans = love.graphics.newFont("assets/OpenSans-Regular.ttf", 14)

function parse(html)
    local parsed = {}

    for paragraph in html:gmatch("<p>(.-)</p>") do
        table.insert(parsed, {tag = "p", content = paragraph})
    end

    for title in html:gmatch("<h%d>(.-)</h%d>") do
        table.insert(parsed, {tag = "h", content = title})
    end

    for link, text in html:gmatch('<a.-href="(.-)".->(.-)</a>') do
        table.insert(parsed, {tag = "a", href = link, content = text})
    end

    return parsed
end

function loadPage(url)
    local data, code = http.request(url)

    if code == 200 then
        page = parse(data)
        love.window.setTitle(url)
    end
end

function calculateWrappedHeight(text)
    local wrappedText = love.graphics.newText(openSans, text)
    wrappedText:setf(text, love.graphics.getWidth(), "left")

    return wrappedText:getHeight()
end

function love.load()
    loadPage(url)
end

function love.update(dt)

end

function love.draw()
    love.graphics.setBackgroundColor(255, 255, 255)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(openSans)

    local y = 0

    for _, element in ipairs(page) do
        if element.tag == "p" then
            love.graphics.printf(element.content, 0, y, love.graphics.getWidth())
            y = y + calculateWrappedHeight(element.content) + 20
        elseif element.tag == "h" then
            love.graphics.printf(element.content, 0, y, love.graphics.getWidth())
            y = y + 20
        elseif element.tag == "a" then
            love.graphics.setColor(0, 0, 255)
            love.graphics.printf(element.content, 0, y, love.graphics.getWidth())
            love.graphics.setColor(0, 0, 0)
            y = y + 20
        end
    end
end
