SMODS.Joker {
    key = "occultist",
    rarity = 2,
    cost = 6,
    atlas = "occultist",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.probabilities.normal) or 1, card.ability.extra.odds } }
    end,
    loc_txt = {
        name = "Occultist",
        text = {
            "When {C:attention}Blind{} is selected,",
            "{C:green}#1# in #2#{} chance to",
            "create a {C:spectral}Spectral{} card",
            "{C:inactive}(Must have room){}"
        }
    },
    calculate = function(self, card, context)
        if context.setting_blind and not context.getting_sliced then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                if pseudorandom('occultist') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    local spectral_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'occultist')
                                    spectral_card:add_to_deck()
                                    G.consumeables:emplace(spectral_card)
                                    G.GAME.consumeable_buffer = 0
                                    return true
                                end
                            }))
                            local msg = (G.localization and G.localization.misc and G.localization.misc.dictionary and G.localization.misc.dictionary.k_plus_spectral) or "+1 Spectral"
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                                message = msg,
                                colour = (G.C.SECONDARY_SET and G.C.SECONDARY_SET.Spectral) or G.C.PURPLE
                            })
                            return true
                        end)
                    }))
                end
            end
        end
    end
}
