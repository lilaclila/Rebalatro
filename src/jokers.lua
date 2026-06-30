
SMODS.Joker:take_ownership('j_mail', {
    config = {extra = 2},
    loc_vars = function(self, info_queue, card)
        local rank = 'Ace'
        if G.GAME and G.GAME.current_round and G.GAME.current_round.mail_card then
            rank = G.GAME.current_round.mail_card.rank
        end
        
        return { vars = { card.ability.extra, localize(rank, 'ranks') } } 
    end,
    
    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and context.other_card:get_id() == G.GAME.current_round.mail_card.id then
            ease_dollars(card.ability.extra)
            return {
                message = localize('$')..card.ability.extra,
                colour = G.C.MONEY
            }
        end
    end
}, true)

SMODS.Joker:take_ownership('j_idol', {
	perishable_compat = false,
    config = {extra = 0.1, x_mult = 1},
    loc_vars = function(self, info_queue, card)
        local rank = 'Ace'
        local suit = 'Spades'
        
        if G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card then
            rank = G.GAME.current_round.idol_card.rank
            suit = G.GAME.current_round.idol_card.suit
        end
        
        return { 
            vars = { 
                card.ability.extra, 
                (card.ability.x_mult or 1), 
                localize(rank, 'ranks'), 
                localize(suit, 'suits_plural'),
                colours = {G.C.SUITS[suit] or G.C.ORANGE}
            }
        }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if not context.other_card.debuff and context.other_card:is_suit(G.GAME.current_round.idol_card.suit) and context.other_card.base.id == G.GAME.current_round.idol_card.id then
                card.ability.x_mult = card.ability.x_mult + card.ability.extra
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED
                }
            end
        end
        
        if context.joker_main and card.ability.x_mult > 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                Xmult_mod = card.ability.x_mult
            }
        end
    end
}, true)

SMODS.Joker:take_ownership('j_to_the_moon', {  
    loc_vars = function(self, info_queue, card)
        local interest_val = (type(card.ability.extra) == 'table' and card.ability.extra.interest) or 1
        return { vars = { interest_val, 10 } }
    end,
    
    update = function(self, card, dt)
        if G.GAME then
            local ttm_count = 0
            local interest_val = (type(card.ability.extra) == 'table' and card.ability.extra.interest) or 1
            
            if G.jokers and G.jokers.cards then
                for _, v in ipairs(G.jokers.cards) do
                    if v.ability and v.ability.name == 'To the Moon' and not v.debuff then
                        ttm_count = ttm_count + 1
                    end
                end
            end
            
            G.GAME.interest_amount = 1 + (ttm_count * interest_val)
            
            local is_green = G.GAME.selected_back and (G.GAME.selected_back.effect.center.key == 'b_green')
            local cap = is_green and 0 or 25
            
            if G.GAME.used_vouchers.v_seed_money then cap = cap + 25 end
            if G.GAME.used_vouchers.v_money_tree then cap = cap + 50 end
            G.GAME.interest_cap = cap + (ttm_count * 10)
        end
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        local ttm_count = 0
        local interest_val = (type(card.ability.extra) == 'table' and card.ability.extra.interest) or 1
        
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do
                if v ~= card and v.ability and v.ability.name == 'To the Moon' and not v.debuff then
                    ttm_count = ttm_count + 1
                end
            end
        end
        
        G.GAME.interest_amount = 1 + (ttm_count * interest_val)
        
        local is_green = G.GAME.selected_back and (G.GAME.selected_back.effect.center.key == 'b_green')
        local cap = is_green and 0 or 25
        
        if G.GAME.used_vouchers.v_seed_money then cap = cap + 25 end
        if G.GAME.used_vouchers.v_money_tree then cap = cap + 50 end
        
        G.GAME.interest_cap = cap + (ttm_count * 10)
    end
}, true)

SMODS.Joker:take_ownership('j_hit_the_road', { perishable_compat = false }, true)

SMODS.Joker:take_ownership('j_campfire', { perishable_compat = false }, true)

SMODS.Joker:take_ownership('j_troubadour', {
    config = {extra = {h_size = 3, h_plays = -1}}
}, true)

SMODS.Joker:take_ownership('j_bloodstone', {
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, card)
        local odds = card.ability.extra.odds or 3
        return { vars = { ''..(G.GAME and G.GAME.probabilities.normal or 1), odds } }
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Hearts") and context.other_card.seal ~= 'Red' then
                if pseudorandom('bloodstone') < G.GAME.probabilities.normal / (card.ability.extra.odds or 3) then
                    context.other_card:set_seal('Red', true, true)
                    return {
                        extra = {message = 'Sealed!', colour = G.C.RED},
                        card = card
                    }
                end
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_dna', {
calculate = function(self, card, context)
if context.before and G.GAME.current_round.hands_played == 0 and context.full_hand and context.full_hand[1] then
local src = (context.scoring_hand and context.scoring_hand[1]) or context.full_hand[1]
G.playing_card = (G.playing_card and G.playing_card + 1) or 1
local _card = copy_card(src, nil, nil, G.playing_card)
_card:add_to_deck()
G.deck.config.card_limit = G.deck.config.card_limit + 1
table.insert(G.playing_cards, _card)
G.hand:emplace(_card)
_card.states.visible = nil
G.E_MANAGER:add_event(Event({
func = function() _card:start_materialize(); return true end,
                    }))
return {
playing_cards_created = {true}, 
}
	end
end
}, true)

SMODS.Joker:take_ownership('j_throwback', {
    loc_vars = function(self, info_queue, card)
        local true_x_mult = 1 + ((G.GAME.tags_gained or 0) * (card.ability.extra or 0.25))
        return { vars = { card.ability.extra or 0.25, true_x_mult } }
    end,
    
calculate = function(self, card, context)
	if context.joker_main then
	local true_x_mult = 1 + ((G.GAME.tags_gained or 0) * (card.ability.extra or 0.25))
	if true_x_mult > 1 then
		return {
			message = localize{type='variable',key='a_xmult',vars={true_x_mult}},
			Xmult_mod = true_x_mult
		}
			end
		end
	end
}, true)

SMODS.Joker:take_ownership('j_satellite', {
	loc_vars = function(self, info_queue, card)
	local planets_used = 0
		if G.GAME and G.GAME.consumeable_usage then
		for _, consumable_data in pairs(G.GAME.consumeable_usage) do
	if consumable_data.set == 'Planet' then planets_used = planets_used + 1 end
		end
	end
	return { vars = { card.ability.extra, 2 + (planets_used * card.ability.extra) } }
    end,
    
    calc_dollar_bonus = function(self, card)
        local planets_used = 0
        if G.GAME and G.GAME.consumeable_usage then
            for _, consumable_data in pairs(G.GAME.consumeable_usage) do
                if consumable_data.set == 'Planet' then planets_used = planets_used + 1 end
            end
        end
        
        return 2 + (planets_used * card.ability.extra)
    end
}, true)

SMODS.Joker:take_ownership('j_swashbuckler', {
    loc_vars = function(self, info_queue, card)
        local true_mult = 0
        
        if G.jokers and G.jokers.cards then
            for _, v in ipairs(G.jokers.cards) do true_mult = true_mult + v.sell_cost end
        end
        if G.consumeables and G.consumeables.cards then
            for _, v in ipairs(G.consumeables.cards) do true_mult = true_mult + v.sell_cost end
        end
        
        return { vars = { true_mult } }
    end,
    
    calculate = function(self, card, context)
        if context.joker_main then
            local true_mult = 0
            
            if G.jokers and G.jokers.cards then
                for _, v in ipairs(G.jokers.cards) do true_mult = true_mult + v.sell_cost end
            end
            if G.consumeables and G.consumeables.cards then
                for _, v in ipairs(G.consumeables.cards) do true_mult = true_mult + v.sell_cost end
            end
            
            if true_mult > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={true_mult}},
                    mult_mod = true_mult
                }
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_yorick', {
    config = {extra = {xmult = 1, discards = 51}},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.discards, card.ability.yorick_discards, card.ability.x_mult}}
    end
}, true)


SMODS.Joker:take_ownership('j_greedy_joker', {
    config = { extra = { s_mult = 4, suit = 'Diamonds' } }
}, true)

SMODS.Joker:take_ownership('j_lusty_joker', {
    config = { extra = { s_mult = 4, suit = 'Hearts' } }
}, true)

SMODS.Joker:take_ownership('j_wrathful_joker', {
    config = { extra = { s_mult = 4, suit = 'Spades' } }
}, true)

SMODS.Joker:take_ownership('j_gluttenous_joker', {
    config = { extra = { s_mult = 4, suit = 'Clubs' } }
}, true)

SMODS.Joker:take_ownership('j_flower_pot', {
    calculate = function(self, card, context)
        if context.joker_main then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            local unique_suits = 0
            
            for i = 1, #context.scoring_hand do
                if not SMODS.has_any_suit(context.scoring_hand[i]) then
                    if context.scoring_hand[i]:is_suit('Hearts', nil, true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds', nil, true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Spades', nil, true) and suits["Spades"] == 0 then
                        suits["Spades"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs', nil, true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = 1
                        unique_suits = unique_suits + 1
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if SMODS.has_any_suit(context.scoring_hand[i]) then
                    if context.scoring_hand[i]:is_suit('Hearts', nil, true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds', nil, true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Spades', nil, true) and suits["Spades"] == 0 then
                        suits["Spades"] = 1
                        unique_suits = unique_suits + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs', nil, true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = 1
                        unique_suits = unique_suits + 1
                    end
                end
            end
            
            if unique_suits >= 3 then
                local xmult = type(card.ability.extra) == 'table' and card.ability.extra.Xmult or card.ability.extra
                return {
                    message = localize{type='variable',key='a_xmult',vars={xmult}},
                    Xmult_mod = xmult
                }
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_trading', {
    config = { extra = 1 }
}, true)

SMODS.Joker:take_ownership('j_sixth_sense', {
    calculate = function(self, card, context)
        if context.before then
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.sixth_sense_target = nil
        end
        if context.individual and context.cardarea == G.play then
            card.ability.extra = card.ability.extra or {}
            if not card.ability.extra.sixth_sense_target and G.GAME.current_round.hands_played == 0 then
                card.ability.extra.sixth_sense_target = context.other_card
            end
        end
        if context.destroy_card and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            if context.destroy_card == card.ability.extra.sixth_sense_target and context.destroy_card:get_id() == 6 and G.GAME.current_round.hands_played == 0 then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            SMODS.add_card {
                                set = 'Spectral',
                                key_append = 'vremade_sixth_sense'
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = localize('k_plus_spectral'),
                        colour = G.C.SECONDARY_SET.Spectral,
                        remove = true
                    }
                end
                return {
                    remove = true
                }
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_hanging_chad', {
    config = {extra = 1},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card == context.scoring_hand[1] or context.other_card == context.scoring_hand[2] then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra,
                    card = card
                }
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_faceless', {
    config = {extra = {dollars = 4, faces = 3}}
}, true)
SMODS.Joker:take_ownership('j_baron', {
    config = {extra = 2}
}, true)

SMODS.Joker:take_ownership('j_castle', {
    config = {extra = {chips = 0, chip_mod = 2}}
}, true)

SMODS.Joker:take_ownership('j_lucky_cat', {
    config = {Xmult = 1, extra = 0.2}
}, true)

SMODS.Joker:take_ownership('j_space', {
    config = {extra = 3}
}, true)

SMODS.Joker:take_ownership('j_loyalty_card', {
    config = {extra = {Xmult = 4, every = 4, remaining = "4 remaining"}}
}, true)

SMODS.Joker:take_ownership('j_splash', {
    calculate = function(self, card, context)
        if context.before and context.scoring_hand then
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].debuff then
                    context.scoring_hand[i]:set_debuff(false)
                    context.scoring_hand[i].ability.splash_undebuffed = true
                end
            end
        end
        if context.after and context.full_hand then
            for i = 1, #context.full_hand do
                if context.full_hand[i].ability.splash_undebuffed then
                    context.full_hand[i]:set_debuff(true)
                    context.full_hand[i].ability.splash_undebuffed = nil
                end
            end
        end
    end
}, true)

SMODS.Joker:take_ownership('j_popcorn', {
    config = { mult = 24, extra = 4 }
}, true)

SMODS.Joker:take_ownership('j_turtle_bean', {
    config = { extra = { h_size = 6, h_mod = 1 } }
}, true)
