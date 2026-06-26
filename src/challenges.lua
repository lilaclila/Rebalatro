if G.CHALLENGES then
    for _, ch in ipairs(G.CHALLENGES) do
        if ch.id == 'c_golden_needle_1' then
            ch.restrictions = ch.restrictions or {}
            ch.restrictions.banned_other = ch.restrictions.banned_other or {}
            local present = false
            for _, b in ipairs(ch.restrictions.banned_other) do
                if b.id == 'bl_water' then present = true break end
            end
            if not present then
                ch.restrictions.banned_other[#ch.restrictions.banned_other + 1] = { id = 'bl_water', type = 'blind' }
            end
        end
    end
end