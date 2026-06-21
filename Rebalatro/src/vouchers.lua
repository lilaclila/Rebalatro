SMODS.Voucher:take_ownership('v_seed_money', {
 redeem = function(self, card)
 G.GAME.interest_cap = G.GAME.interest_cap + 25
end
}, true)

SMODS.Voucher:take_ownership('v_money_tree', {
redeem = function(self, card)
G.GAME.interest_cap = G.GAME.interest_cap + 50
end
}, true)

SMODS.Voucher:take_ownership('v_hieroglyph', {
redeem = function(self, card)
ease_ante(-card.ability.extra)
G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - card.ability.extra
G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra
ease_discard(-card.ability.extra)
end
}, true)

SMODS.Voucher:take_ownership('v_planet_merchant', {
loc_vars = function(self, info_queue, card)
return { vars = { self.config.extra, 1 } }
end
}, true)

SMODS.Voucher:take_ownership('v_planet_tycoon', {
loc_vars = function(self, info_queue, card)
return { vars = { self.config.extra, 2 } }
end
}, true)

SMODS.Voucher:take_ownership('v_tarot_merchant', {
loc_vars = function(self, info_queue, card)
return { vars = { self.config.extra, 1 } }
end
}, true)

SMODS.Voucher:take_ownership('v_tarot_tycoon', {
loc_vars = function(self, info_queue, card)
return { vars = { self.config.extra, 2 } }
end
}, true)