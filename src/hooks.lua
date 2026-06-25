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
    
    if self.GAME and (self.GAME.stake or 1) >= 5 then
        local sp = self.GAME.starting_params
        local rr = self.GAME.round_resets
        if sp and not sp.rebal_blue_applied then
            sp.rebal_blue_applied = true
            sp.discards = (sp.discards or 0) + 2
            sp.hands    = (sp.hands or 0) - 1
            if rr then
                rr.discards = (rr.discards or 0) + 2
                rr.hands    = (rr.hands or 0) - 1
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
    local card = _create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    
    if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers.v_illusion and area == G.shop_jokers and card and card.base and card.base.suit then
        if pseudorandom('illusion_seal') > 0.4 then
            local seals = {'Red', 'Blue', 'Gold', 'Purple'}
            card:set_seal(pseudorandom_element(seals, pseudoseed('illusion_seal')), true)
        end
    end
    
    return card
end

if Card and Card.calculate_joker then
    local _calculate_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        local ret = _calculate_joker(self, context)

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
            if type(change_shop_size) == 'function' then change_shop_size(1) end
        end
        return ret
    end
end

local _get_current_shop_base_weights = get_current_shop_base_weights
function get_current_shop_base_weights()
    local weights, total = _get_current_shop_base_weights()
    if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers.v_magic_trick then
        local card_slots = (G.shop_jokers and G.shop_jokers.config.card_limit) or 2
        local playing_card_current_weight = weights.playing_card or 0
        local new_weight = (1 / card_slots) * (total - playing_card_current_weight)
        weights.playing_card = new_weight
        total = total - playing_card_current_weight + new_weight
    end
    return weights, total
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
        
        local threshold_mod = _guaranteed and 1 or (rate * _mod)
        
        if edition_poll > 1 - 0.003 * threshold_mod and not _no_neg then return { negative = true }
        elseif edition_poll > 1 - 0.003 * threshold_mod then return { polychrome = true }
        elseif edition_poll > 1 - 0.02 * threshold_mod then return { holo = true }
        elseif edition_poll > 1 - 0.04 * threshold_mod then return { foil = true }
        end
        return nil
    end
end

SMODS.Seals.Blue.calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    local consumable = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'blusl')
                    consumable:add_to_deck()
                    G.consumeables:emplace(consumable)
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))
            
            return {
                message = localize('k_plus_planet'),
                colour = G.C.SECONDARY_SET.Planet,
                card = card
            }
        end
    end
end
