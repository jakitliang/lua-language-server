local files = require "files"
local guide = require "parser.guide"

local colorPattern = string.rep('%x', 8)
local hex6Pattern = string.format("^#%s", string.rep('%x', 6))
---@param source parser.object
---@return boolean
local function isColor(source)
    ---@type string
    local text = source[1]
    if text:len() == 8 then
        return text:match(colorPattern)
    end

    if text:len() == 7 then
        return text:match(hex6Pattern)
    end

    return false
end


---@param colorText string
---@return Color
local function textToColor(colorText)
    return {
        alpha = tonumber(colorText:sub(1, 2), 16) / 255,
        red   = tonumber(colorText:sub(3, 4), 16) / 255,
        green = tonumber(colorText:sub(5, 6), 16) / 255,
        blue  = tonumber(colorText:sub(7, 8), 16) / 255,
    }
end

---@param colorText string
---@return Color
local function hexTextToColor(colorText)
    return {
        alpha = 255,
        red   = tonumber(colorText:sub(2, 3), 16) / 255,
        green = tonumber(colorText:sub(4, 5), 16) / 255,
        blue  = tonumber(colorText:sub(6, 7), 16) / 255,
    }
end

---@param color Color
---@return string
local function colorToText(color)
    return string.format('%02X%02X%02X%02X'
        , math.floor(color.alpha * 255)
        , math.floor(color.red   * 255)
        , math.floor(color.green * 255)
        , math.floor(color.blue  * 255)
    )
end

---@class Color
---@field red number
---@field green number
---@field blue number
---@field alpha number

---@class ColorValue
---@field color Color
---@field start integer
---@field finish integer

---@async
local function colors(uri)
    local state = files.getState(uri)
    local text  = files.getText(uri)
    if not state or not text then
        return nil
    end
    ---@type ColorValue[]
    local colorValues = {}

    guide.eachSource(state.ast, function (source) ---@async
        if source.type == 'string' and isColor(source) then
            ---@type string
            local colorText = source[1]

            local color = colorText:match(colorPattern) and textToColor(colorText) or hexTextToColor(colorText)

            colorValues[#colorValues+1] = {
                start  = source.start + 1,
                finish = source.finish - 1,
                color  = color
            }
        end
    end)
    return colorValues
end

return {
    colors = colors,
    colorToText = colorToText
}
