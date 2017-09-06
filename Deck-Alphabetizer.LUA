function onLoad(save_state)
    button = getObjectFromGUID('76fa09')
    zone = getObjectFromGUID('6f9471')
    output = getObjectFromGUID('c2daee')
    params = {
        ['label'] = 'Sort Cards',
        ['width'] = 450,
        ['height'] = 400,
        ['click_function'] = 'alphabetize',
        ['function_owner'] = Global,
        ['position'] = {0,0.65,0},
        ['rotation'] = {0,90,0},
        ['font_size'] = 80
    }
    button.createButton(params)
end

function alphabetize()
    local deck = zone.getObjects()[1]
    local referenceTable = {}
    if deck.tag == 'Deck' then -- validate object type
        for j,k in pairs(deck.getObjects()) do
            referenceTable[j] = {}
            referenceTable[j] = {k.nickname,k.guid} -- create key,value pairs for sorting
        end
        table.sort(referenceTable,sortFunc) -- order alphabetically by nickname
        for j,k in pairs(referenceTable) do
            if deck.getQuantity() ~= 0 then
                deck.takeObject({ -- instantiate objects in order to call putObject later
                    ['guid']=k[2],
                    ['position']={math.random(-50,50),math.random(2,30),math.random(-50,50)},
                    ['callback']='outputCard',
                    ['callback_owner']=Global
                })
            else
                Timer.create({
                    ['identifier'] = 'endOfSort',
                    ['function_name']='endOfSort',
                    ['function_owner']=Global,
                    ['delay']=0.6
                })
            end
        end
    end
end

function outputCard(card)
    output.putObject(card) -- places cards into the bag
end

function endOfSort()
    zone.getObjects()[1].setPosition({output.getPosition()[1],output.getPosition()[2]+3,output.getPosition()[3]})
    for i=1,output.getQuantity()+1,1 do
        Timer.Create({ -- delay the drawing of each new card from the alphabetixed bag to allow physics room to work
            ['identifier'] = 'nextCard'..i,
            ['function_name']='nextCard',
            ['function_owner']=Global,
            ['delay']=i/2
        })
    end
end

function nextCard()
    output.takeObject({ -- place the card on the table
        ['position']={0,2,0},
        ['rotation']={0,180,0}
    })
end

function sortFunc(a,b)
    return a[1]>b[1]
end
