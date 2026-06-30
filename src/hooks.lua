local function apply_red_stake_blinds()
    if not G.GAME then return end
    for key, blind in pairs(G.P_BLINDS) do
        blind.og_dollars = blind.og_dollars or blind.dollars
        if (G.GAME.stake or 1) >= 2 then
            blind.dollars = math.max(0, blind.og_dollars - 1)
        else
            blind.dollars = blind.og_dollars
        end
    end
    
    if G.GAME.modifiers and type(G.GAME.modifiers.no_blind_reward) == 'table' then
        G.GAME.modifiers.no_blind_reward.Small = nil
    end
end

local _start_run = Game.start_run
function Game:start_run(args)
    if args and args.save_game then
        G.IS_LOADING_SAVE = true
    end
    
    _start_run(self, args)
    
    apply_red_stake_blinds()
    
    if self.GAME then
        local sp = self.GAME.starting_params
        local rr = self.GAME.round_resets
        
        -- +1 discards at base
        if sp and not sp.rebal_base_discards_applied then
            sp.rebal_base_discards_applied = true
            sp.discards = (sp.discards or 0) + 1
            if rr then
                rr.discards = (rr.discards or 0) + 1
                if self.GAME.current_round then
                    self.GAME.current_round.discards_left = rr.discards
                end
            end
        end

        -- blue stake fix
        if (self.GAME.stake or 1) >= 5 then
            if sp and not sp.rebal_blue_applied then
                sp.rebal_blue_applied = true
                -- vanilla is -1 discard here, +1 to restore it to the new base
                sp.discards = (sp.discards or 0) + 1
                sp.hands    = (sp.hands or 0) - 1
                if rr then
                    rr.discards = (rr.discards or 0) + 1
                    rr.hands    = (rr.hands or 0) - 1
                    if self.GAME.current_round then
                        self.GAME.current_round.discards_left = rr.discards
                        self.GAME.current_round.hands_left = rr.hands
                    end
                end
            end
        end
    end
end

local _game_update = Game.update
function Game:update(dt)
    _game_update(self, dt)
    
    if G.IS_LOADING_SAVE and G.STAGE == G.STAGES.RUN then
        G.IS_LOADING_SAVE = false
    end

    if G.GAME and G.GAME.modifiers then
        local cap = G.GAME.interest_cap or 0
        local dollars = G.GAME.dollars or 0
        local rate = G.GAME.interest_amount or 1
        
        local earned_interest = 0
        if dollars >= 5 and cap > 0 then
            earned_interest = math.min(math.floor(dollars / 5), cap / 5) * rate
        end
        
        if earned_interest <= 0 then
            if not G.GAME.modifiers.no_interest then
                G.GAME.modifiers.no_interest = true
                G.GAME.smods_dynamic_ui_hide = true
            end
        else
            if G.GAME.smods_dynamic_ui_hide then
                G.GAME.modifiers.no_interest = nil
                G.GAME.smods_dynamic_ui_hide = false
            end
        end
    end
end


local _create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if area == G.pack_cards and (key_append == 'ar1' or key_append == 'ar2') then
        local should_have_spectrals = G.GAME and G.GAME.modifiers and G.GAME.modifiers.ghost_deck_omen
        if should_have_spectrals then
            if pseudorandom('omen_globe_mod') > 0.8 then
                _type = "Spectral"
                key_append = 'ar2'
            else
                _type = "Tarot"
                key_append = 'ar1'
            end
        else
            _type = "Tarot"
            key_append = 'ar1'
        end
    end
    local card = _create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    
    if card and area == G.pack_cards and card.ability and card.ability.set == 'Joker' then
        G.E_MANAGER:add_event(Event({
            func = (function()
                if G.GAME and G.GAME.tags then
                    for k, v in ipairs(G.GAME.tags) do
                        if v.config.type == 'store_joker_modify' and not card.edition then
                            if v:apply_to_run({type = 'store_joker_modify', card = card}) then break end
                        end
                    end
                end
                return true
            end)
        }))
    end
    
    if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers.v_illusion and card and card.base and card.base.suit then
        if area == G.shop_jokers then
            local has_seal = card.seal ~= nil and card.seal ~= ''
            local has_edition = card.edition ~= nil
            local has_enh = card.ability and card.ability.set == 'Default' and card.ability.enhanced ~= nil
            if not (has_seal or has_edition or has_enh) then
                local r = pseudorandom(pseudoseed('illusion_pre_std'))
                if r < 0.33 then
                    local seals = {'Red', 'Blue', 'Gold', 'Purple'}
                    card:set_seal(pseudorandom_element(seals, pseudoseed('illusion_seal')), true)
                elseif r < 0.66 then
                    local edition = poll_edition('illusion_edi', 1, false, true)
                    card:set_edition(edition)
                else
                    if card.ability and card.ability.set == 'Default' then
                        card:set_ability(G.P_CENTERS[SMODS.poll_enhancement({key = 'illusion_enh', guaranteed = true})])
                    end
                end
            end
        end
    end
    
    return card
end

if Card and Card.calculate_joker then
    local _calculate_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        -- glass joker fix
        if self.ability and self.ability.name == 'Glass Joker' then
            if context.using_consumeable and context.consumeable and context.consumeable.ability.name == 'The Hanged Man' then
                local old_name = context.consumeable.ability.name
                context.consumeable.ability.name = 'Dummy'
                local ret = _calculate_joker(self, context)
                context.consumeable.ability.name = old_name
                return ret
            end
            if context.remove_playing_cards and context.removed then
                for _, val in ipairs(context.removed) do
                    if val.ability and val.ability.name == 'Glass Card' and not val.shattered then
                        val.shattered = true
                        val.shattered_faked = true
                    end
                end
            end
        end

        local ret = _calculate_joker(self, context)

        if self.ability and self.ability.name == 'Glass Joker' and context.remove_playing_cards and context.removed then
            for _, val in ipairs(context.removed) do
                if val.shattered_faked then
                    val.shattered = false
                    val.shattered_faked = nil
                end
            end
        end

        if context.discard and context.other_card and not context.red_seal_retrigger then
            if context.other_card:get_seal() == 'Red' then
                context.red_seal_retrigger = true
                local ret2 = _calculate_joker(self, context)
                context.red_seal_retrigger = nil
                
                if ret2 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            card_eval_status_text(self, 'jokers', nil, nil, nil, ret2)
                            return true
                        end
                    }))
                end
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if self.ability and self.ability.perishable and self.set_cost then
                self:set_cost()
            end
        end
        
        return ret
    end
end

if Card and Card.set_cost then
    local _set_cost = Card.set_cost
    function Card:set_cost()
        _set_cost(self)
        local uv  = (G.GAME and G.GAME.used_vouchers) or {}
        local set = self.ability and self.ability.set
        local key = self.config and self.config.center and self.config.center.key
        
        local planet_discount = 0
        if uv.v_planet_tycoon then planet_discount = 2 elseif uv.v_planet_merchant then planet_discount = 1 end
        if planet_discount > 0 and (set == 'Planet' or (key and string.find(key, 'celestial'))) then
            self.cost = math.max(0, (self.cost or 0) - planet_discount)
        end
        
        local tarot_discount = 0
        if uv.v_tarot_tycoon then tarot_discount = 2 elseif uv.v_tarot_merchant then tarot_discount = 1 end
        if tarot_discount > 0 and (set == 'Tarot' or (key and string.find(key, 'arcana'))) then
            self.cost = math.max(0, (self.cost or 0) - tarot_discount)
        end
        
        if self.ability and self.ability.perishable then
            local base_sell = self.ability.rental and 1 or self.cost
            if self.ability.perish_tally and self.ability.perish_tally <= 0 then
                self.sell_cost = math.max(1, base_sell) + (self.ability.extra_value or 0)
            else
                self.sell_cost = math.max(1, math.floor(base_sell / 2)) + (self.ability.extra_value or 0)
            end
        end
        
        if self.ability and self.ability.couponed and self.area and self.area == G.shop_vouchers then
            self.cost = 0
        end
    end
end

if Card and Card.set_perishable then
    local _set_perishable = Card.set_perishable
    function Card:set_perishable(_perishable)
        _set_perishable(self, _perishable)
        if self.set_cost then self:set_cost() end
    end
end

if Card and Card.use_consumeable then
    local _use = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        if self.ability and self.ability.name == 'Ouija' and G.hand then
            local hand = G.hand
            local real_change = hand.change_size
            hand.change_size = function() end
            _use(self, area, copier)
            hand.change_size = real_change
            G.GAME.round_resets.discards = math.max(0, (G.GAME.round_resets.discards or 1) - 1)
            if ease_discard then ease_discard(-1) end
            return
        end
        return _use(self, area, copier)
    end
end

if Card and Card.apply_to_run then
    local _apply_to_run = Card.apply_to_run
    function Card:apply_to_run(center)
        local ret = _apply_to_run(self, center)
        local ct = center or (self.config and self.config.center)
        if ct and ct.name == 'Magic Trick' and G.GAME and not G.GAME.rebal_magic_slot then
            G.GAME.rebal_magic_slot = true
        end
        return ret
    end
end

if Back and Back.apply_to_run then
    local _back_apply = Back.apply_to_run
    function Back:apply_to_run()
        _back_apply(self)
        if self.effect and self.effect.center and self.effect.center.key == 'b_green' then
            if G.GAME.modifiers.no_interest then
                G.GAME.modifiers.no_interest = nil
            end
            G.GAME.interest_cap = 0 
        end
        if self.effect and self.effect.center and self.effect.center.key == 'b_zodiac' then
            G.GAME.modifiers.bram_poker = true
            G.GAME.joker_rate = 0
        end
    end
end

if not G.THROWBACK_FIX_APPLIED then
    G.THROWBACK_FIX_APPLIED = true
    local _add_tag = add_tag
    function add_tag(tag)
        local is_asteroid = tag.key and string.find(tag.key, 'asteroid')
        if is_asteroid then
            tag.ID = 'asteroid_secret_tag'
            tag.HUD_tag = { remove = function() end }
            if G.GAME and G.GAME.tags then
                table.insert(G.GAME.tags, tag)
            end
            return 
        end
        _add_tag(tag)
        if not G.IS_LOADING_SAVE then
            G.GAME.tags_gained = (G.GAME.tags_gained or 0) + 1
        end
    end
end

if type(poll_edition) == 'function' then
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        _mod = _mod or 1
        local edition_poll = pseudorandom(pseudoseed(_key or 'edition_generic'))
        local rate = (G.GAME and G.GAME.edition_rate) or 1
        
        local threshold_mod = _guaranteed and 25 or (rate * _mod)
        
        if edition_poll > 1 - 0.003 * threshold_mod and not _no_neg then return { negative = true }
        elseif edition_poll > 1 - 0.006 * threshold_mod then return { polychrome = true }
        elseif edition_poll > 1 - 0.02 * threshold_mod then return { holo = true }
        elseif edition_poll > 1 - 0.04 * threshold_mod then return { foil = true }
        end
        return nil
    end
end

SMODS.Seals.Blue.loc_vars = function(self, info_queue, card)
    local triggers = card and card.ability and card.ability.blue_seal_triggers or 0
    return { vars = { math.max(0, 3 - triggers) } }
end

SMODS.Atlas({ key = 'blueseal1', path = 'blueseal1rounds.png', px = 71, py = 95, raw_key = true })
SMODS.Atlas({ key = 'blueseal2', path = 'blueseal2rounds.png', px = 71, py = 95, raw_key = true })
SMODS.Atlas({ key = 'blueseal3', path = 'blueseal3rounds.png', px = 71, py = 95, raw_key = true })

if Card and Card.draw then
    local _draw = Card.draw
    function Card:draw(...)
        local original_atlas = nil
        local original_pos = nil
        if self.seal == 'Blue' and G.shared_seals and G.shared_seals['Blue'] then
            local triggers = self.ability and self.ability.blue_seal_triggers or 0
            local rounds_left = math.max(0, 3 - triggers)
            original_atlas = G.shared_seals['Blue'].atlas
            original_pos = G.shared_seals['Blue'].sprite_pos
            
            local new_atlas = nil
            if rounds_left >= 3 and G.ASSET_ATLAS['blueseal3'] then
                new_atlas = G.ASSET_ATLAS['blueseal3']
            elseif rounds_left == 2 and G.ASSET_ATLAS['blueseal2'] then
                new_atlas = G.ASSET_ATLAS['blueseal2']
            elseif rounds_left <= 1 and G.ASSET_ATLAS['blueseal1'] then
                new_atlas = G.ASSET_ATLAS['blueseal1']
            end

            if new_atlas then
                G.shared_seals['Blue'].atlas = new_atlas
                if G.shared_seals['Blue'].set_sprite_pos then
                    G.shared_seals['Blue']:set_sprite_pos({x=0,y=0})
                end
            end
        end
        
        _draw(self, ...)
        
        if original_atlas then
            G.shared_seals['Blue'].atlas = original_atlas
            if original_pos and G.shared_seals['Blue'].set_sprite_pos then
                G.shared_seals['Blue']:set_sprite_pos(original_pos)
            end
        end
    end
end

if Card and Card.get_end_of_round_effect then
    local _get_end_of_round_effect = Card.get_end_of_round_effect
    function Card:get_end_of_round_effect(context)
        local ret = _get_end_of_round_effect(self, context)
        
        if self.seal == 'Blue' and context and not self.debuff then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                self.ability.blue_seal_triggers = (self.ability.blue_seal_triggers or 0)
                if self.ability.blue_seal_triggers >= 3 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = (function()
                            self:set_seal(nil, true, true)
                            return true
                        end)
                    }))
                end
            end
        end
        return ret
    end
end

if create_UIBox_standard_pack then
    local _create_UIBox_standard_pack = create_UIBox_standard_pack
    function create_UIBox_standard_pack()
        local t = _create_UIBox_standard_pack()
        if G.pack_cards then
            G.pack_cards.T.w = G.pack_cards.T.w + (G.CARD_W * 1.1)
        end
        return t
    end
end

if Card and Card.sell_card then
    local _sell_card = Card.sell_card
    function Card:sell_card()
        local is_verdant = false
        if self.ability and self.ability.set == 'Joker' and G.GAME and G.GAME.blind and G.GAME.blind.name == 'Verdant Leaf' then
            is_verdant = true
            G.GAME.blind.name = 'Dummy'
        end
        
        _sell_card(self)
        
        if is_verdant then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
                if G.GAME and G.GAME.blind and G.GAME.blind.name == 'Dummy' then
                    G.GAME.blind.name = 'Verdant Leaf'
                end
                return true
            end}))
        end
    end
end

if Tag and Tag.apply_to_run then
    local _apply_to_run = Tag.apply_to_run
    function Tag:apply_to_run(context)
        local ret = _apply_to_run(self, context)
        if ret then
            local card = nil
            if context.type == 'store_joker_create' then
                card = type(ret) == 'table' and ret or nil
            elseif context.type == 'store_joker_modify' then
                card = context.card
            end
            
            if card and card.ability and card.ability.set == 'Joker' then
                card.ability.eternal = false
                card.ability.perishable = false
                card.ability.rental = false
                card.pinned = false
            end
        end
        return ret
    end
end


