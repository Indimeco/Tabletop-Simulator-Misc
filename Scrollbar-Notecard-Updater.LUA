function onload()
    local button_parameters = {}
    button_parameters.click_function = 'updateNotecard'
    button_parameters.function_owner = self
    button_parameters.label = 'Update Notecard'
    button_parameters.position = {-0.85,0.4,0}
    button_parameters.rotation = {0,-90,0}
    button_parameters.width = 700
    button_parameters.height = 90
    button_parameters.font_size = 70
    self.createButton( button_parameters )
end

function updateNotecard()
    local zone = Global.getVar('updateZone')
    local objects = zone.getObjects()
    for i,v in pairs(objects) do
        if v.getVar('above') ~= nil then
            v.setLuaScript(currentVersion)
            local pos = v.getPosition()
            v.destruct()
            v.clone({['position'] = {pos[1],pos[2]+1,pos[3]}})
            printToAll(v.getName()..' has been updated!', {0,1,0})
            break
        else
            printToAll('No notecard detected!', {0,1,0})
        end
    end
end

currentVersion = [[function onLoad(save_state)
    -- The scrollbars use four buttons, 2 do-nothing buttons that only show the arrow and two functional, but hidden buttons.
    local button_parameters = {}
    button_parameters.click_function = 'scrollDown'
    button_parameters.function_owner = self
    button_parameters.label = string.char(9652)
    button_parameters.position = {-0.46,5,-0.45}
    button_parameters.rotation = {0,0,0}
    button_parameters.width = 40
    button_parameters.height = 40
    button_parameters.font_size = 70
    self.createButton( button_parameters )

    button_parameters.click_function = 'scrollUp'
    button_parameters.function_owner = self
    button_parameters.label = string.char(9662)
    button_parameters.position = {-0.46,5,0.45}
    button_parameters.rotation = {0,0,0}
    button_parameters.width = 40
    button_parameters.height = 40
    button_parameters.font_size = 70
    self.createButton( button_parameters )

    -- Takes the above and below information from the encoded JSON string and turns them into usable variables.
    local saveStrings = JSON.decode(save_state)
    if saveStrings == nil then
        above = ''
        below = ''
        starting = self.getDescription()
    else
        above = saveStrings['above']
        below = saveStrings['below']
        starting = saveStrings['starting'] -- The text before it becomes altered by the user, updated after a scroll function completes.
    end

    -- Table describes the math of all characters on the standard English keyboard and their estimated width where a full line = 100,000
    characterWidthTable = {
        ['`'] = 2381, ['~'] = 2381, ['1'] = 1724, ['!'] = 1493, ['2'] = 2381,
        ['@'] = 4348, ['3'] = 2381, ['#'] = 3030, ['4'] = 2564, ['$'] = 2381,
        ['5'] = 2381, ['%'] = 3846, ['6'] = 2564, ['^'] = 2564, ['7'] = 2174,
        ['&'] = 2777, ['8'] = 2564, ['*'] = 2174, ['9'] = 2564, ['('] = 1724,
        ['0'] = 2564, [')'] = 1724, ['-'] = 1724, ['_'] = 2381, ['='] = 2381,
        ['+'] = 2381, ['q'] = 2564, ['Q'] = 3226, ['w'] = 3704, ['W'] = 4167,
        ['e'] = 2174, ['E'] = 2381, ['r'] = 1724, ['R'] = 2777, ['t'] = 1724,
        ['T'] = 2381, ['y'] = 2564, ['Y'] = 2564, ['u'] = 2564, ['U'] = 3030,
        ['i'] = 1282, ['I'] = 1282, ['o'] = 2381, ['O'] = 3226, ['p'] = 2564,
        ['P'] = 2564, ['['] = 1724, ['{'] = 1724, [']'] = 1724, ['}'] = 1724,
        ['|'] = 1493, ['\\'] = 1923,['a'] = 2564, ['A'] = 2777, ['s'] = 1923,
        ['S'] = 2381, ['d'] = 2564, ['D'] = 3030, ['f'] = 1724, ['F'] = 2381,
        ['g'] = 2564, ['G'] = 2777, ['h'] = 2564, ['H'] = 3030, ['j'] = 1075,
        ['J'] = 1282, ['k'] = 2381, ['K'] = 2777, ['l'] = 1282, ['L'] = 2174,
        [';'] = 1282, [':'] = 1282, ['\''] = 855, ['"'] = 1724, ['z'] = 1923,
        ['Z'] = 2564, ['x'] = 2381, ['X'] = 2777, ['c'] = 1923, ['C'] = 2564,
        ['v'] = 2564, ['V'] = 2777, ['b'] = 2564, ['B'] = 2564, ['n'] = 2564,
        ['N'] = 3226, ['m'] = 3846, ['M'] = 3846, [','] = 1282, ['<'] = 2174,
        ['.'] = 1282, ['>'] = 2174, ['/'] = 1923, ['?'] = 2174, [' '] = 1282,
        [string.char(196)]  = 2777, [string.char(197)]  = 2777, -- capital A with diaeresis above, capital A with circle above
        [string.char(228)]  = 2777, [string.char(229)]  = 2777, -- small A with diaeresis above, small A with circle above
        [string.char(214)]  = 3226, [string.char(213)]  = 3226, -- capital O with diaeresis, capital O with tilde
        [string.char(246)]  = 2381, [string.char(245)]  = 2381, -- small O with diaeresis, small O with tilde
        [string.char(220)]  = 3030, [string.char(252)]  = 2564, -- capital U with diaeresis, small U with diaeresis
        [string.char(223)]  = 2777, [string.char(233)]  = 2174, -- latin small sharp S, small e with acute
        [string.char(8220)] = 1923, [string.char(8221)] = 1923, [string.char(8217)] = 1075, -- left quotes, right quotes, apostrophe
        [string.char(8226)] = 1493,                                                         -- bullet point
        ['\t'] = 5128, ['\r'] = 0, ['\n'] = 100000
    }
end

function onSave() -- Saves the text data to be encoded and preserved.
    local saveTable = {}
    saveTable['above'] = above
    saveTable['below'] = below
    saveTable['starting'] = starting
    return JSON.encode(saveTable)
end

function scrollUp(obj,color)
    if above ~= '' then
        local verifyCharacters = getPage(self.getDescription())
        if type(verifyCharacters) == 'table' then -- getPage() returns a table when it encounters a character that doesn't exist within the characterWidthTable.
            printToColor('Unrecognized character: "'..verifyCharacters[1]..'" in scrollbar notecard "'..self.getName()..'"\nPlease delete it.',color,{1,0.2,0.2})
        else
            local newPage = string.reverse(getPage(string.reverse(above)))
            if self.getDescription() ~= '' then
                local i = string.len(newPage)
                local tempPage = getPage(removeNewline(removeNewline(newPage..'\n'..preserveNewline(self.getDescription()),'Ending'),'Beginning'))
                local j = string.len(tempPage)
                if i < j then
                    newPage = tempPage
                    above = removeNewline(removeNewline(plainReplace(above,string.sub(newPage,1,i),''),'Ending'),'Beginning')
                    below = removeNewline(removeNewline(plainReplace(preserveNewline(self.getDescription()),removeNewline(string.sub(newPage,i+1,j),'Beginning'),'')..'\n'..below,'Beginning'),'Ending')
                else
                    above = removeNewline(plainReplace(above,removeNewline(removeNewline(newPage,'Ending'),'Beginning'),''),'Ending')
                    below = removeNewline(removeNewline(preserveNewline(self.getDescription())..'\n'..below,'Ending'),'Beginning')
                end
            else
                above = removeNewline(plainReplace(above,removeNewline(removeNewline(newPage,'Ending'),'Beginning'),''),'Ending')
            end
            self.setDescription(removeNewline(removeNewline(newPage,'Ending'),'Beginning'))
            starting = self.getDescription()
        end
    end
end

function scrollDown(obj,color)
    if self.getDescription() ~= '' or below ~= '' then
        local abovePage = getPage(preserveNewline(self.getDescription()))
        local newPage
        if type(abovePage) == 'table' then -- getPage() returns a table when it encounters a character that doesn't exist within the characterWidthTable.
            printToColor('Unrecognized character: "'..abovePage[1]..'" in scrollbar notecard "'..self.getName()..'"\nPlease delete it.',color,{1,0.2,0.2})
        else
            local tempPage = string.sub(preserveNewline(self.getDescription()),string.len(abovePage)+1,-1)
            if tempPage ~= '' then
                newPage = getPage(removeNewline(removeNewline(tempPage..'\n'..below,'Ending'),'Beginning'))
                if type(newPage) == 'table' then
                    printToColor('Unrecognized character: "'..newPage[1]..'" in scrollbar notecard "'..self.getName()..'"\nPlease delete it.',color,{1,0.2,0.2})
                    return 0
                end
                if string.len(newPage) > string.len(tempPage) then
                    tempPage = ''
                end
            else
                tempPage = ''
                newPage = getPage(removeNewline(removeNewline(below,'Ending'),'Beginning'))
            end
            above = removeNewline(above..'\n'..abovePage,'Beginning')

            local extraLength1 = getLines(preserveNewline(self.getDescription()))
            local tempStartingText = getLines(starting)
            local extraLength2 = extraLength1['lineCount'] - tempStartingText['lineCount']
            local extraLength3 = getLines(below)
            local extraLength4 = tempStartingText['lineCount'] - extraLength2
            local extraLength5 = extraLength3[extraLength4]
            self.setDescription(removeNewline(removeNewline(newPage,'Beginning'),'Ending'))
            starting = self.getDescription()
            if extraLength2 > 0 and extraLength4 <= extraLength3['lineCount'] and extraLength4 > 0 and extraLength5 ~= nil then
                below = removeNewline(string.sub(tempPage..below,extraLength5+1),'Beginning')
            else
                if string.len(self.getDescription()) ~= string.len(below) then
                    below = removeNewline(removeNewline(string.sub(tempPage..below,string.len(self.getDescription())+2),'Ending'),'Beginning')
                else
                    below = ''
                end
            end
        end
    end
end

function getPage(invStr) -- Iterates through the str and sums the estimated line length based on characterWidthTable for each character in a max 100000 system. Margin for error is 200.
    local lineWidth = 0
    local lineCount = 0
    local placeholder = 1
    local key = ''
    local page = ''
    local i = 1
    while lineCount ~= 9 do
        key = string.sub(invStr, i, i)
        if key == '' then
            page = page..string.sub(invStr,placeholder,i)
            break
        end
        if characterWidthTable[key] == nil then
            return {key}
        end
        lineWidth = lineWidth + characterWidthTable[key]
        if lineWidth > 99878 then
            if key == '\n' then
                page = page..string.sub(invStr,placeholder,i-1)
                placeholder = i
            else
                page = page..string.sub(invStr,placeholder,i)
                placeholder = i + 1
            end
            lineCount = lineCount + 1
            lineWidth = 0
        end
        i = i + 1
    end
    return page
end

function getLines(str) -- Returns a table countaining the number of lines in a string as well as the location of the end of each line.
    local lineWidth = 0
    local lineCount = 0
    local length = string.len(str)
    local placeholder = 1
    local key = ''
    local lineTable = {}
    local i = 1
    while i < 2+string.len(str) do
        key = string.sub(str, i, i)
        if key == '' then
            lineCount = lineCount + 1
            break
        end
        lineWidth = lineWidth + characterWidthTable[key]
        if lineWidth > 99878 then
            if key == '\n' then
                lineTable[lineCount+1] = i-1
                placeholder = i
            else
                lineTable[lineCount+1] = i
                placeholder = i + 1
            end
            lineCount = lineCount + 1
            lineWidth = 0
        end
        i = i + 1
    end
    lineTable['length'] = length
    lineTable['lineCount'] = lineCount
    return lineTable
end

function removeNewline(str, location) -- Takes a string and chops off all the newlines it can find, given the direction, until it hits text.
    if location == 'Beginning' then
        while string.sub(str,1,1) == '\n' do
            str = string.sub(str,2,-1)
        end
        return str
    elseif location == 'Ending' then
        while string.sub(str,-1,-1) == '\n' do
            str = string.sub(str,1,-2)
        end
        return str
    end
end

function preserveNewline(str) -- A variant on the plainReplace function designed to prevent the destruction of user-made newlines.
    local z = 1
    while true do
        local x,y = str:find('\n\n',z,true)
        if x==nil then
           break
       elseif str:sub(x-1,y+2) ~= '\n \n' then
           str = str:sub(1,x-1)..'\n \n'..str:sub(y+1)
        end
        z = y+1
    end
    return str
end

function getFullText() -- returns the complete string of data for a card.
    local fullText = self.getDescription()
    if above ~= '' then
        fullText = above..'\n'..fullText
    end
    if below ~= '' then
        fullText = fullText..'\n'..below
    end
    return fullText
end

function plainReplace(str, pattern, replacement) -- Takes a string changes the pattern within it to the replacement.
    local x,y = str:find(pattern,1,true)
    if x==nil then
       return str
    else
       return str:sub(1,x-1)..replacement..str:sub(y+1)
    end
end]]
