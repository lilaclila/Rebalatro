SMODS.Back:take_ownership('b_black', {
    config = { hands = -1, discards = 0, joker_slot = 1}
}, true)

SMODS.Back:take_ownership('b_nebula', {
    config = { consumable_slot = 0, voucher = false}, 
    calculate = function(self, back, context)
        if context.ending_shop and not G.IS_LOADING_SAVE then
            if G.GAME.nebula_last_shop_ante ~= G.GAME.round_resets.ante then
                G.GAME.nebula_last_shop_ante = G.GAME.round_resets.ante
                G.E_MANAGER:add_event(Event({
                func = function()
                    local secret_tag = Tag('tag_rebal_asteroid')
                    add_tag(secret_tag)
                    
                    if secret_tag.HUD_tag and type(secret_tag.HUD_tag.remove) == 'function' then
                        secret_tag.HUD_tag:remove()
                        secret_tag.HUD_tag = { remove = function() end }
                    end
                    return true
                end
            }))
            end
        end
    end
}, true)

SMODS.Back:take_ownership('b_zodiac', {
    config = {vouchers = {'v_tarot_merchant', 'v_planet_merchant'}},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Booster'] then
                    for _, v in ipairs(G.P_CENTER_POOLS['Booster']) do
                        if v.kind == 'Arcana' or v.kind == 'Celestial' then
                            G.GAME.banned_keys[v.key] = true
                        end
                    end
                end
                return true
            end
        }))
    end
}, true)

SMODS.Back:take_ownership('b_ghost', {
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.modifiers.ghost_deck_omen = true
                return true
            end
        }))
    end
}, true)
