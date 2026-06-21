local mod = SMODS.current_mod

local files = {
	'blinds',     
	'challenges',       
	'decks',      
	'hooks',
	'jokers',
	'planets',
	'spectrals',
	'tags',
	'vouchers'
}

for _, f in ipairs(files) do
    local chunk = SMODS.load_file('src/' .. f .. '.lua')
    if chunk then
        local ok, err = pcall(chunk)
        if not ok then
            sendDebugMessage('[Rebalatro] failed loading ' .. f .. ': ' .. tostring(err), 'Rebalatro')
        end
    end
end

function mod.process_loc_text()
    local D = G.localization.descriptions
    D.Back.b_black.text = {
        "{C:attention}+1{} Joker slot",
        "{C:red}-1{} discard",
        "every round",
    }
    D.Back.b_nebula.text = {
        "Open a free {C:planet}Celestial{}",
        "pack at the end",
        "of every shop",
    }

    D.Spectral.c_ouija.text = {
        "Converts all cards",
        "in hand to a single",
        "random {C:attention}rank",
        "{C:red}-1{} discard",
    }

    D.Joker.j_troubadour.text = {
        "{C:attention}+#1#{} hand size,",
        "{C:red}-#2#{} discard",
    }

    D.Voucher.v_hieroglyph.text = {
        "{C:attention}-#1#{} Ante",
        "{C:red}-#1#{} discard",
        "each round",
    }

    D.Voucher.v_seed_money.text = {
        "Raise the cap on",
        "interest earned per",
        "round by {C:money}$5",
    }
    D.Voucher.v_money_tree.text = {
        "Raise the cap on",
        "interest earned per",
        "round by {C:money}$10",
    }

    if D.Voucher.v_planet_merchant then
        D.Voucher.v_planet_merchant.text = {
            "{C:planet}Planet{} cards appear",
            "{C:attention}#1#X{} more frequently",
            "in the shop",
            "{C:money}-$1{} {C:planet}Planet{} & {C:planet}Celestial{} cost",
        }
    end
    if D.Voucher.v_planet_tycoon then
        D.Voucher.v_planet_tycoon.text = {
            "{C:planet}Planet{} cards appear",
            "{C:attention}#1#X{} more frequently",
            "in the shop",
            "{C:money}-$1{} {C:planet}Planet{} & {C:planet}Celestial{} cost",
        }
    end

    if D.Voucher.v_tarot_merchant then
        D.Voucher.v_tarot_merchant.text = {
            "{C:tarot}Tarot{} cards appear",
            "{C:attention}#1#X{} more frequently",
            "in the shop",
            "{C:money}-$1{} {C:tarot}Tarot{} & {C:tarot}Arcana{} cost",
        }
    end
	
    if D.Voucher.v_tarot_tycoon then
        D.Voucher.v_tarot_tycoon.text = {
            "{C:tarot}Tarot{} cards appear",
            "{C:attention}#1#X{} more frequently",
            "in the shop",
            "{C:money}-$1{} {C:tarot}Tarot{} & {C:tarot}Arcana{} cost",
        }
    end

if D.Voucher.v_hone then
        D.Voucher.v_hone.text = {
                    "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
                    "{C:dark_edition}Polychrome{}, and {C:dark_edition}Negative{} cards",
                    "appear {C:attention}#1#X{} more often",
        }
    end

if D.Voucher.v_glow_up then
        D.Voucher.v_glow_up.text = {
                    "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
                    "{C:dark_edition}Polychrome{}, and {C:dark_edition}Negative{} cards",
                    "appear {C:attention}#1#X{} more often",
        }
    end


    if D.Stake and D.Stake.stake_blue then
        D.Stake.stake_blue.text = {
            "{C:blue}-1{} hands,",
            "{C:red}+1{} discards",
            "{s:0.8}Applies all previous Stakes",
        }
    end

    if D.Voucher.v_magic_trick then
        D.Voucher.v_magic_trick.text = {
            "{C:attention}+1{} card slot available in shop",
            "{C:attention}Playing cards{} can",
            "appear in the shop",
        }
    end

    if D.Voucher.v_illusion then
        D.Voucher.v_illusion.text = {
            "{C:attention}Playing cards{} in shop",
            "may have an {C:dark_edition}edition{}",
            "an {C:attention}enhancement",
	    "and a {C:attention}seal",
        }
    end

    if D.Stake and D.Stake.stake_red then
        D.Stake.stake_red.text = {
            "{C:money}-$1{} {C:attention}Big Blind{} &",
            "{C:attention}Boss Blind{} reward",
            "{s:0.8}Applies all previous Stakes",
        }
    end

    if D.Joker.j_bloodstone then
        D.Joker.j_bloodstone.text = {
            "{C:green}1 in 2{} chance for",
            "scored cards with",
            "{C:hearts}Heart{} suit to gain",
            "a {C:red}Red Seal",
        }
    end

    if D.Joker.j_dna then
        D.Joker.j_dna.text = {
            "Add a permanent copy of the",
            "{C:attention}first scored{} card",
	    "in the {C:attention}first hand{} of round",
            "to deck and draw it to {C:attention}hand",
        }
    end

    if D.Joker.j_satellite then
        D.Joker.j_satellite.text = {
                    "Earn {C:money}$#2#{} at end of round",
                    "Payout increases by {C:money}$#1#{}",
                    "per unique {C:planet}Planet{}",
		    "card used this run",
        }
    end

    if D.Joker.j_swashbuckler then
        D.Joker.j_swashbuckler.text = {
            "Adds the sell value of",
            "all owned {C:attention}Jokers{} and",
            "held {C:attention}consumables{} to Mult",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)",
        }
	end
	if D.Joker.j_throwback then
       	 D.Joker.j_throwback.text = {
                    "{X:mult,C:white} X#1# {} Mult for each",
                    "{C:attention}Tag{} gained this run",
                    "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
		}
    end

    if D.Spectral and D.Spectral.c_black_hole then
        D.Spectral.c_black_hole.text = {
            "Upgrade every",
            "{C:legendary,E:1}poker hand",
            "by {C:attention}3{} levels",
        }
    end

    if D.Tag and D.Tag.tag_coupon then
        D.Tag.tag_coupon.text = {
            "Initial cards, booster",
            "packs and {C:voucher}vouchers{} in",
            "next shop are {C:attention}free",
        }
    end

    if D.Tag and D.Tag.tag_voucher then
        D.Tag.tag_voucher.text = {
            "Adds a {C:attention}free{}",
            "{C:voucher}Voucher{} to the next shop",
        }
    end

    if D.Tag and D.Tag.tag_ethereal then
        D.Tag.tag_ethereal.text = {
            "Gives a free",
            "{C:spectral}Jumbo Spectral Pack",
        }
   		 end
	end
