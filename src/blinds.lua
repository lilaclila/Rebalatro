SMODS.Blind:take_ownership('bl_needle', {
    mult = 1.5
}, true)

SMODS.Blind:take_ownership('bl_water', {
    mult = 1.5
}, true)

SMODS.Blind:take_ownership('bl_wheel', {
    stay_flipped = function(self, area, card)
        if area == G.hand then
            G.GAME.wheel_flip_counter = (G.GAME.wheel_flip_counter or 0) + 1
            if G.GAME.wheel_flip_counter % 2 == 0 then
                return true
            end
        end
    end,
    loc_txt = {
        name = 'The Wheel',
        text = {
            'Every other card',
            'is drawn face down'
        }
    }
}, true)
