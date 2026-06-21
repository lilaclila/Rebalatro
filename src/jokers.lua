
SMODS.Joker:take_ownership('j_mail', {
    config = {extra = 3},
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
	perishable_compat = false
    config = {extra = 0.1, x_mult = 1},
	loc_txt = {
        name = 'The Idol',
        text = {
            "This Joker gains {X:mult,C:white} X#1# {} Mult",
            "each time a played {C:attention}#3#",
            "of {V:1}#4#{} is scored",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
            "{s:0.8}Card changes every round"
        }
    },
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
    loc_txt = {
        name = 'To the Moon',
        text = {
            "Earn an extra {C:money}$#1#{} of",
            "{C:attention}interest{} for every {C:money}$5{} you",
            "have at end of round.",
            "Increase cap on interest earned",
	    "per round by {C:money}$2{}"
        }
    },
    
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
    add_to_deck = function(self, card)
        G.hand:change_size(2)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        ease_discard(-1)
    end,
    remove_from_deck = function(self, card)
        G.hand:change_size(-2)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
        ease_discard(1)
    end
}, true)

SMODS.Joker:take_ownership('j_bloodstone', {
    config = { extra = { odds = 3 } },
    loc_txt = {
        name = 'Bloodstone',
        text = {
            "{C:green}#1# in #2#{} chance for",
            "played cards with",
            "{C:hearts}Heart{} suit to gain a",
            "{C:red}Red Seal{} when scored"
        }
    },
    
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
