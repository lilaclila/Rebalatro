SMODS.PokerHand:take_ownership('Flush',          { l_chips = 20 }, true)
SMODS.PokerHand:take_ownership('Full House',     { l_chips = 30 }, true)
SMODS.PokerHand:take_ownership('Five of a Kind', { l_chips = 40 }, true)
SMODS.PokerHand:take_ownership('High Card', 	 { l_mult = 1, l_chips = 5 }, true)
SMODS.PokerHand:take_ownership('Pair',		 { l_mult = 1, l_chips = 10 }, true)
SMODS.PokerHand:take_ownership('Three of a Kind',{ l_mult = 3, l_chips = 5 }, true)

-- put enhancements here because i dont want to make another file
SMODS.Enhancement:take_ownership('m_mult', {
    config = {mult = 5}
}, true)

SMODS.Enhancement:take_ownership('m_stone', {
    calculate = function(self, card, context)
        if context.press_play then
            for _, _card in ipairs(G.hand.highlighted) do
                if _card == card then
                    for _, __card in ipairs(G.playing_cards) do
                        if __card ~= card and __card.ability.effect == 'Stone Card' and __card.area ~= G.play then
                            local found = false
                            for _, ___card in ipairs(G.hand.highlighted) do
                                if ___card == __card then found = true; break end
                            end
                            if not found then
                                draw_card(__card.area, G.play, 1, "front", nil, __card)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
}, true)

SMODS.Enhancement:take_ownership('m_stone', {
    calculate = function(self, card, context)
        if context.press_play then
            local is_highlighted = false
            for _, hc in ipairs(G.hand.highlighted) do
                if hc == card then
                    is_highlighted = true
                    break
                end
            end
            if not is_highlighted and card.area == G.hand then
                draw_card(card.area, G.play, 1, "front", nil, card)
            end
        end
    end
}, true)
