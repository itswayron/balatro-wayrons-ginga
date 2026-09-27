SMODS.Joker {
    key = "vibe_coder",
    rarity = 2,
    cost = 5,
    atlas = "vibe_coder",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, card)
        local vars = { (G.GAME and G.GAME.probabilities.normal) or 1, card.ability.extra.odds }
        local main_end = nil

        if card and card.ability then
            local target = card.ability.vibe_target
            if card.ability.vibe_active and target and type(target) == 'table' and not target.destroyed and not target.shattered and target.config and target.config.center then
                if info_queue then
                    table.insert(info_queue, target.config.center)
                end
                local target_center = target.config.center
                local target_name = (target_center and target_center.key and localize{type = 'name_text', key = target_center.key, set = 'Joker'})
                if not target_name or target_name == 'ERROR' then
                    target_name = (target_center and target_center.name) or "Joker"
                end
                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local copying_template = (dict and dict.k_wg_vibe_copying) or "Copying: #1#"
                local copying_text = copying_template:gsub("#1#", function() return target_name end)

                main_end = {
                    { n = G.UIT.C, config = { align = "bm", minh = 0.4 }, nodes = {
                        { n = G.UIT.C, config = { align = "m", colour = G.C.GREEN, r = 0.05, padding = 0.06 }, nodes = {
                            { n = G.UIT.T, config = { text = " " .. copying_text .. " ", colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.85 } }
                        }}
                    }}
                }
            elseif card.ability.vibe_failed then
                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local failed_text = (dict and dict.k_wg_vibe_failed) or "Failed this Blind"
                main_end = {
                    { n = G.UIT.C, config = { align = "bm", minh = 0.4 }, nodes = {
                        { n = G.UIT.C, config = { align = "m", colour = G.C.RED, r = 0.05, padding = 0.06 }, nodes = {
                            { n = G.UIT.T, config = { text = " " .. failed_text .. " ", colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.85 } }
                        }}
                    }}
                }
            end
        end

        return { vars = vars, main_end = main_end }
    end,
    loc_txt = {
        name = "Vibe Coder",
        text = {
            "When {C:attention}Blind{} is selected,",
            "{C:green}#1# in #2#{} chance to copy",
            "the ability of a {C:attention}random Joker{}",
            "for the entire Blind"
        }
    },
    calculate = function(self, card, context)
        -- Blind start: roll vibe check (1 in 2) and lock in target for the entire Blind
        if context.setting_blind and not context.blueprint then
            card.ability.vibe_active = false
            card.ability.vibe_target = nil
            card.ability.vibe_failed = false

            if pseudorandom('vibe_coder') < G.GAME.probabilities.normal / card.ability.extra.odds then
                local eligible = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        if j ~= card and not j.debuff and j.config and j.config.center and j.config.center.blueprint_compat ~= false then
                            local k = j.config.center_key or (j.config.center and j.config.center.key)
                            if k ~= 'j_wg_vibe_coder' and k ~= 'j_blueprint' and k ~= 'j_brainstorm' then
                                table.insert(eligible, j)
                            end
                        end
                    end
                end

                if #eligible > 0 then
                    card.ability.vibe_target = pseudorandom_element(eligible, pseudoseed('vibe_target'))
                    card.ability.vibe_active = true
                    card.ability.vibe_failed = false

                    local target_center = card.ability.vibe_target.config.center
                    local target_name = (target_center and target_center.key and localize{type = 'name_text', key = target_center.key, set = 'Joker'})
                    if not target_name or target_name == 'ERROR' then
                        target_name = (target_center and target_center.name) or "Joker"
                    end

                    local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                    local success_msg = (dict and dict.k_wg_vibe_success) or "It Works!"
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = success_msg,
                        colour = G.C.GREEN
                    })
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "-> " .. target_name,
                        colour = G.C.GREEN
                    })
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            card:juice_up(0.7, 0.5)
                            return true
                        end
                    }))

                    -- If the copied joker triggers on setting_blind, evaluate it
                    local ret = SMODS.blueprint_effect(card, card.ability.vibe_target, context)
                    if ret then
                        ret.colour = G.C.GREEN
                        return ret
                    end
                end
            else
                card.ability.vibe_active = false
                card.ability.vibe_target = nil
                card.ability.vibe_failed = true
                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local fail_msg = (dict and dict.k_wg_vibe_fail) or "Bug..."
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = fail_msg,
                    colour = G.C.RED
                })
            end
        end

        -- End of round: evaluate any end-of-round effect of the copied joker, then reset for next Blind
        if context.end_of_round and not context.blueprint then
            local ret = nil
            if card.ability.vibe_active and card.ability.vibe_target and type(card.ability.vibe_target) == 'table' and not card.ability.vibe_target.debuff and card.ability.vibe_target.area == G.jokers then
                ret = SMODS.blueprint_effect(card, card.ability.vibe_target, context)
                if ret then ret.colour = G.C.GREEN end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = function()
                    card.ability.vibe_active = false
                    card.ability.vibe_target = nil
                    card.ability.vibe_failed = false
                    return true
                end
            }))
            if ret then return ret end
        end

        -- Re-trigger scoring / abilities of target joker during active blind
        if card.ability.vibe_active and card.ability.vibe_target and type(card.ability.vibe_target) == 'table' and not card.ability.vibe_target.debuff and card.ability.vibe_target.area == G.jokers then
            return SMODS.blueprint_effect(card, card.ability.vibe_target, context)
        end
    end
}
