SMODS.Consumable:take_ownership('c_ouija', {
	use = function(self, card, area, copier)
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
	play_sound('tarot1')
	card:juice_up(0.3, 0.5)
	return true
end}))
	for i=1, #G.hand.cards do
	local percent = 1.15 - (i-0.999)/(#G.hand.cards-0.998)*0.3
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function() 
	G.hand.cards[i]:flip()
	play_sound('card1', percent)
	G.hand.cards[i]:juice_up(0.3, 0.3)
	return true 
end}))
end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
	local _rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, 	pseudoseed('ouija'))
        for i=1, #G.hand.cards do
        local suit_prefix = string.sub(G.hand.cards[i].base.suit, 1, 1)..'_'
        G.hand.cards[i]:set_base(G.P_CARDS[suit_prefix.._rank])
        end
        return true 
end}))
	for i=1, #G.hand.cards do
        local percent = 0.85 + (i-0.999)/(#G.hand.cards-0.998)*0.3
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function() 
        G.hand.cards[i]:flip()
        play_sound('tarot2', percent, 0.6)
        G.hand.cards[i]:juice_up(0.3, 0.3)
        return true 
end}))
end
}, true)
