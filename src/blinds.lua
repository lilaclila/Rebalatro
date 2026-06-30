SMODS.Blind:take_ownership('bl_needle', {
    mult = 1.5
}, true)

SMODS.Blind:take_ownership('bl_water', {
    mult = 1.5
}, true)

SMODS.Blind:take_ownership('bl_wheel', {
    stay_flipped = function(self, area, card)
        if area == G.hand then
            G.GAME.wheel_flip_counter = (G.GAME.wheel_flip_counter or 0) + 1
            if G.GAME.wheel_flip_counter % 2 == 0 then
                return true
            end
        end
    end,
    loc_txt = {
        name = 'The Wheel',
        text = {
            'Every other card',
            'is drawn face down'
        }
    }
}, true)

SMODS.Blind:take_ownership('bl_final_leaf', {
    recalc_debuff = function(self, card, from_blind)
        if card.area ~= G.jokers and card.ability and not card.ability.verdant_immune then
            return true
        end
        return false
    end,
    calculate = function(self, blind, context)
        if context.selling_card and context.card.ability.set == 'Joker' then
            for _, c in ipairs(G.hand.cards) do
                c.ability.verdant_immune = true
                c:set_debuff(false)
            end
        end
    end
}, true)

SMODS.Blind:take_ownership('bl_final_heart', {
    recalc_debuff = function(self, card, from_blind)
        if card.area == G.jokers then
            if G.jokers and G.jokers.cards then
                local num_jokers = #G.jokers.cards
                if num_jokers > 0 and (card == G.jokers.cards[num_jokers] or (num_jokers > 1 and card == G.jokers.cards[num_jokers - 1])) then
                    return true
                end
            end
        end
        return false
    end,
    drawn_to_hand = function(self) end,
    press_play = function(self) end
}, true)



SMODS.Blind:take_ownership('bl_final_bell', {
    calculate = function(self, blind, context)
        if context.before and G.play and G.play.cards and #G.play.cards > 0 then
            local card_to_remove = pseudorandom_element(G.play.cards, pseudoseed('cerulean_bell_remove'))
            card_to_remove:highlight(false)
            G.hand:remove_from_highlighted(card_to_remove)
            for i = #G.play.cards, 1, -1 do
                if G.play.cards[i] == card_to_remove then table.remove(G.play.cards, i) break end
            end
            for i = #context.scoring_hand, 1, -1 do
                if context.scoring_hand[i] == card_to_remove then table.remove(context.scoring_hand, i) break end
            end
            draw_card(G.play, G.hand, 100, 'up', nil, card_to_remove)
        end
    end
}, true)
