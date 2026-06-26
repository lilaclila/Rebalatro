SMODS.Tag:take_ownership('tag_coupon', {
	apply = function(self, tag, context)
	if context.type == 'shop_final_pass' then
	local applied = false

if G.shop_jokers and G.shop_jokers.cards then
	for k, v in ipairs(G.shop_jokers.cards) do
	v.ability = v.ability or {}
	v.ability.couponed = true
	v:set_cost()
	applied = true
	end
end

if G.shop_booster and G.shop_booster.cards then
	for k, v in ipairs(G.shop_booster.cards) do
	v.ability = v.ability or {}
	v.ability.couponed = true
	v:set_cost()
	applied = true
	end
end

if G.shop_vouchers and G.shop_vouchers.cards then
	for k, v in ipairs(G.shop_vouchers.cards) do
	v.ability = v.ability or {}
	v.ability.couponed = true
	v:set_cost()
	applied = true
	end
end

if applied then
	tag:yep('+', G.C.Money, function() return true end)
	tag.triggered = true
		end
	end
end
}, true)

SMODS.Tag:take_ownership('tag_voucher', {
    apply = function(self, tag, context)
        if context.type == 'voucher_add' then
            tag:yep('+', G.C.SECONDARY_SET.Voucher, function()
                local voucher = SMODS.add_voucher_to_shop(nil, true)
		voucher.cost = 0
                voucher.from_tag = true
                return true
            end)
            tag.triggered = true
        end
    end
}, true)

SMODS.Tag:take_ownership('tag_ethereal', {
	apply = function(self, tag, context)
	if context.type == 'immediate' then
	local lock = tag.ID
	G.CONTROLLER.locks[lock] = true

	tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
	local key = 'p_spectral_jumbo_1'
	local card = Card(
		G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2, 
                    G.play.T.y + G.play.T.h/2 - G.CARD_H*1.27/2, 
                    G.CARD_W*1.27, G.CARD_H*1.27, 
                    G.P_CARDS.empty, 
                    G.P_CENTERS[key], 
                    {bypass_discovery_center = true, bypass_discovery_ui = true}
                )
	card.cost = 0
	card.from_tag = true
	G.FUNCS.use_card({config = {ref_table = card}})
	card:start_materialize()
	G.CONTROLLER.locks[lock] = nil
	return true
	end)
	tag.triggered = true
	return true
	end
end
}, true)

SMODS.Tag {
    key = 'asteroid',
    config = {type = 'new_blind_choice'},
    no_collection = true, 
    in_pool = function() return false end,
    loc_txt = {
        name = 'Asteroid Tag',
        text = {""}
    },
    
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag.triggered = true
            local key = 'p_celestial_mega_1'
            local card = Card(
                G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, 
                G.CARD_W*1.27, G.CARD_H*1.27, 
                G.P_CARDS.empty, 
                G.P_CENTERS[key], 
                {bypass_discovery_center = true, bypass_discovery_ui = true}
            )
            
            card.cost = 0
            card.from_tag = true
            G.FUNCS.use_card({config = {ref_table = card}})
            card:start_materialize()
            G.CONTROLLER.locks[lock] = nil
            tag:remove()
            
            return true
        end
    end
}
SMODS.Tag:take_ownership('tag_investment', {
    config = {type = 'eval', dollars = 20}
}, true)
