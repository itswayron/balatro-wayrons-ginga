SMODS.Joker {
    key = "another_one",
    rarity = 3,
    cost = 8,
    atlas = "another_one",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { h_size = -1 },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.h_size } }
    end,
    loc_txt = {
        name = "Another One",
        text = {
            "Cards {C:attention}held in hand{}",
            "also count as {C:attention}played cards{},",
            "{C:red}#1#{} hand size"
        }
    },
    calculate = function(self, card, context)
        -- Handled by WG core scoring engine
    end
}
