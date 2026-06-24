local mod = SMODS.current_mod

local files = {
    'blinds',     
    'challenges',        
    'decks',      
    'hooks',
    'jokers',
    'planets',
    'spectrals',
    'tags',
    'vouchers',
    'seals'
}

for _, f in ipairs(files) do
    local chunk = SMODS.load_file('src/' .. f .. '.lua')
    if chunk then
        local ok, err = pcall(chunk)
        if not ok then
            sendDebugMessage('[Rebalatro] failed loading ' .. f .. ': ' .. tostring(err), 'Rebalatro')
        end
    end
end
