SMODS.Joker {
    key = "card_in_sleeve",
    rarity = 3,
    cost = 8,
    atlas = "jokers",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    loc_txt = {
        name = "Card up the Sleeve",
        text = {
            "Played cards also count",
            "as cards {C:attention}held in hand{}"
        }
    },
    calculate = function(self, card, context)
        -- Handled by WG core scoring engine
    end
}
