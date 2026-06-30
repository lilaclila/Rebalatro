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
ease_discard(-2)
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
SMODS.Voucher:take_ownership('v_omen_globe', {
    config = {extra = 1},
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra } }
    end,
    redeem = function(self, card)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra
    end
}, true)

SMODS.Voucher:take_ownership('v_magic_trick', {
    config = { extra = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    redeem = function(self, card)
        if G.shop_jokers then

            local force_enh = false
            local force_edi = false
            local force_seal = false
            if G.GAME.used_vouchers.v_illusion then
                local r = pseudorandom(pseudoseed('illusion_pre'))
                if r < 0.333 then force_enh = true
                elseif r < 0.666 then force_edi = true
                else force_seal = true end
            end

            local pc = create_card((force_enh or pseudorandom(pseudoseed('magic_trick_enh')) > 0.6) and 'Enhanced' or 'Base', G.shop_jokers, nil, nil, nil, nil, nil, 'sho')
            if force_enh and pc.ability.set == 'Default' then
                pc:set_ability(G.P_CENTERS[SMODS.poll_enhancement({key = 'illusion_enh', guaranteed = true})])
            end
            
            local edition_rate = 2
            local edition = poll_edition('magic_trick_edi', edition_rate, true, force_edi)
            pc:set_edition(edition)
            
            local seal_rate = 10
            local seal_poll = pseudorandom(pseudoseed('magic_trick_seal'))
            if force_seal or seal_poll > 1 - 0.02*seal_rate then pc:set_seal(SMODS.poll_seal({guaranteed = true})) end
            create_shop_card_ui(pc, 'Base', G.shop_jokers)
            pc:start_materialize()
            G.shop_jokers.config.card_limit = math.max(G.shop_jokers.config.card_limit, #G.shop_jokers.cards + 1)
            G.shop_jokers:emplace(pc)
            G.shop_jokers.T.w = math.max(G.GAME.shop.joker_max, #G.shop_jokers.cards) * 1.02 * G.CARD_W
            if G.shop then G.shop:recalculate() end
        end
    end
}, true)

SMODS.Voucher:take_ownership('v_illusion', {
    config = { extra = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    calculate = function(self, card, context)
        if context.modify_booster_card then
            local is_standard = context.booster and context.booster.config and context.booster.config.center and context.booster.config.center.kind == 'Standard'
            if is_standard then
                local guarantee_type = pseudorandom(pseudoseed('illusion_guarantee'))
                local force_seal, force_edi, force_enh = false, false, false
                
                if guarantee_type < 0.333 then
                    force_seal = true
                elseif guarantee_type < 0.666 then
                    force_edi = true
                else
                    force_enh = true
                end

                local card_to_mod = context.card

                local edition_rate = 2
                local edition = poll_edition('illusion_booster_edi', edition_rate, true, force_edi)
                if edition then card_to_mod:set_edition(edition, true, true) end

                local seal_rate = 10
                local seal_poll = pseudorandom(pseudoseed('illusion_booster_seal'))
                if force_seal or seal_poll > 1 - 0.02 * seal_rate then 
                    card_to_mod:set_seal(SMODS.poll_seal({guaranteed = true}), true, true) 
                end
                
                local enh_poll = pseudorandom(pseudoseed('illusion_booster_enh'))
                if force_enh or enh_poll > 0.6 then
                     if card_to_mod.ability and card_to_mod.ability.set == 'Default' then
                          card_to_mod:set_ability(G.P_CENTERS[SMODS.poll_enhancement({key='illusion_enh', guaranteed=true})])
                     end
                end
            end
        end
    end
}, true)
