if Blind and Blind.set_blind then
    local _set_blind = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        _set_blind(self, blind, reset, silent)
        if not reset and G.GAME and (G.GAME.stake or 1) >= 2 then
            if G.GAME.modifiers and G.GAME.modifiers.no_blind_reward then
                G.GAME.modifiers.no_blind_reward.Small = nil
            end
            local t = self.get_type and self:get_type()
            local disp = self.dollars or 0
            if t == 'Small' then
                self.dollars = (blind and blind.dollars) or self.dollars or 0
                disp = self.dollars
            elseif t == 'Big' or t == 'Boss' then
                disp = math.max(0, (self.dollars or 0) - 1)
            end
            if G.GAME.current_round then
                G.GAME.current_round.dollars_to_be_earned =
                    disp > 0 and (string.rep(localize('$'), disp) .. '') or ''
            end
        end
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
	if uv.v_planet_tycoon then
		planet_discount = 2
	elseif uv.v_planet_merchant then
		planet_discount = 1
	end
        if planet_discount > 0 and (set == 'Planet' or (key and string.find(key, 'celestial'))) then
            self.cost = math.max(0, (self.cost or 0) - planet_discount)
        end
	local tarot_discount = 0
	if uv.v_tarot_tycoon then
		tarot_discount = 2
	elseif uv.v_tarot_merchant then
		tarot_discount = 1
	end
        if tarot_discount > 0 and (set == 'Tarot' or (key and string.find(key, 'arcana'))) then
            self.cost = math.max(0, (self.cost or 0) - tarot_discount)
        end
        if self.ability and self.ability.perishable then
		local base_sell = 0
            if self.ability.rental then
                base_sell = 1 
            else
		base_sell = self.cost
	    end
	
	    self.sell_cost = math.max(1, base_sell + (self.ability.extra_value or 0))
            end
        if self.ability and self.ability.couponed
           and self.area and self.area == G.shop_vouchers then
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

--[[if G.FUNCS and type(G.FUNCS.skip_blind) == 'function' then
    local _skip_blind = G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        if G.GAME and G.GAME.rebal_skip_lock then return end
 
        local _tag = e and e.UIBox and e.UIBox:get_UIE_by_ID('tag_container')
        local skip_key = _tag and _tag.config and _tag.config.ref_table and _tag.config.ref_table.key
        local has_double = false
        for _, t in ipairs(G.GAME.tags or {}) do
            if t.key == 'tag_double' then has_double = true; break end
        end
 
        if has_double and skip_key then
            if G.GAME then G.GAME.rebal_skip_lock = true end
 
            for _, t in ipairs(G.GAME.tags) do
                if t.key == 'tag_double' then
                    if t.remove then t:remove() end
                    break
                end
            end
 
            local hidden = {}
            for _, t in ipairs(G.GAME.tags) do
                if t.key == 'tag_double' then
                    hidden[#hidden + 1] = { tag = t, name = t.name }
                    t.name = '__rebal_hidden'
                end
            end
            add_tag(Tag(skip_key))
            for _, h in ipairs(hidden) do h.tag.name = h.name end
            play_sound('generic1')
 
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.3, blockable = false, blocking = false,
                func = function()
                    if e then e.disable_button = nil end
                    if G.GAME then G.GAME.rebal_skip_lock = nil end
                    return true
                end,
            }))
            return
        end
 
        if G.GAME then G.GAME.rebal_skip_lock = true end
        local ret = _skip_blind(e)
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.6, blockable = false, blocking = false,
            func = function()
                if G.GAME then G.GAME.rebal_skip_lock = nil end
                return true
            end,
        }))
        return ret
    end
end
]]

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

if Game and Game.start_run then
    local _start_run = Game.start_run
    function Game:start_run(args)
        _start_run(self, args)
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
end

if type(poll_edition) == 'function' then
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        _mod = _mod or 1
        local edition_poll = pseudorandom(pseudoseed(_key or 'edition_generic'))
        local rate = (G.GAME and G.GAME.edition_rate) or 1
        if _guaranteed then
            if edition_poll > 1 - 0.003 * 25 and not _no_neg then return { negative = true }
            elseif edition_poll > 1 - 0.003 * 25 then return { polychrome = true }
            elseif edition_poll > 1 - 0.02 * 25 then return { holo = true }
            elseif edition_poll > 1 - 0.04 * 25 then return { foil = true }
            end
        else
            if edition_poll > 1 - 0.003 * rate * _mod and not _no_neg then return { negative = true }
            elseif edition_poll > 1 - 0.003 * rate * _mod then return { polychrome = true }
            elseif edition_poll > 1 - 0.02 * rate * _mod then return { holo = true }
            elseif edition_poll > 1 - 0.04 * rate * _mod then return { foil = true }
            end
        end
        return nil
    end
end

local _create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = _create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if G.GAME.used_vouchers.v_illusion and area == G.shop_jokers and card.base and card.base.suit then
        if pseudorandom('illusion_seal') > 0.6 then
            local seals = {'Red', 'Blue', 'Gold', 'Purple'}
            card:set_seal(pseudorandom_element(seals, pseudoseed('illusion_seal')), true)
        end
    end
    return card
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
    if G.GAME.used_vouchers.v_magic_trick then
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
    
    local _start_run = Game.start_run
    function Game:start_run(args)
        if args and args.save_game then
            G.IS_LOADING_SAVE = true
        end
        _start_run(self, args)
    end
    
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

if Game and Game.update then
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
end