-------------------------------------------------------------------------
-- Wayron's Ginga x JokerDisplay Compatibility
-------------------------------------------------------------------------
if not JokerDisplay then return end

local function get_dict_entry(key, default)
    local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
    if dict and dict[key] then
        return dict[key]
    end
    return default
end

local card_in_sleeve_def = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active_text", colour = G.C.ORANGE },
        { text = ")" }
    },
    calc_function = function(card)
        local count = (G.play and G.play.cards and #G.play.cards > 0 and #G.play.cards) or
                      (G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and #G.hand.highlighted) or 0
        local label = get_dict_entry("jdis_wg_played_to_hand", "#1# -> Hand")
        card.joker_display_values.active_text = count > 0 and string.gsub(label, "#1#", tostring(count)) or "Played = Hand"
    end
}

local another_one_def = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active_text", colour = G.C.BLUE },
        { text = ")" }
    },
    extra = {
        {
            { ref_table = "card.joker_display_values", ref_value = "h_size_text", colour = G.C.RED }
        }
    },
    extra_config = { scale = 0.3 },
    calc_function = function(card)
        local hand_count = (G.hand and G.hand.cards and #G.hand.cards) or 0
        local selected = (G.play and G.play.cards and #G.play.cards > 0 and 0) or
                         (G.hand and G.hand.highlighted and #G.hand.highlighted) or 0
        local remaining = math.max(0, hand_count - selected)
        local label = get_dict_entry("jdis_wg_hand_to_played", "#1# -> Played")
        card.joker_display_values.active_text = remaining > 0 and string.gsub(label, "#1#", tostring(remaining)) or "Hand = Played"

        local hs_label = get_dict_entry("jdis_wg_hand_size", "Hand Size")
        local hs_val = (card.ability and card.ability.h_size) or -1
        card.joker_display_values.h_size_text = "(" .. tostring(hs_val) .. " " .. hs_label .. ")"
    end
}

local occultist_def = {
    reminder_text = {
        { text = "(" },
        {
            text = get_dict_entry("k_plus_spectral", "+1 Spectral"),
            colour = (G.C.SECONDARY_SET and G.C.SECONDARY_SET.Spectral) or G.C.PURPLE
        },
        { text = ")" }
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { scale = 0.3 },
    calc_function = function(card)
        local numerator, denominator = (G.GAME.probabilities.normal or 1), (card.ability.extra and card.ability.extra.odds or 2)
        if SMODS and SMODS.get_probability_vars then
            numerator, denominator = SMODS.get_probability_vars(card, numerator, denominator, 'occultist')
        end
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

local vibe_coder_def = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "vibe_target_name", colour = G.C.GREEN },
        { text = ")" }
    },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { scale = 0.3 },
    calc_function = function(card)
        if card.ability.vibe_active and card.ability.vibe_target and type(card.ability.vibe_target) == 'table' and not card.ability.vibe_target.debuff then
            local target_center = card.ability.vibe_target.config.center
            local target_name = (target_center and target_center.key and localize{type = 'name_text', key = target_center.key, set = 'Joker'})
            if not target_name or target_name == 'ERROR' then
                target_name = (target_center and target_center.name) or "Joker"
            end
            card.joker_display_values.vibe_target_name = target_name
            JokerDisplay.copy_display(card, card.ability.vibe_target, card.ability.vibe_target.debuff)
        else
            JokerDisplay.copy_display(card, nil)
            local random_label = get_dict_entry("jdis_wg_random", "Random")
            card.joker_display_values.vibe_target_name = random_label
            local numerator, denominator = (G.GAME.probabilities.normal or 1), (card.ability.extra and card.ability.extra.odds or 2)
            if SMODS and SMODS.get_probability_vars then
                numerator, denominator = SMODS.get_probability_vars(card, numerator, denominator, 'vibe_coder')
            end
            card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
        end
    end
}

local leftmost_zero_def = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "target_text", colour = G.C.DARK_EDITION },
        { text = ")" }
    },
    calc_function = function(card)
        local target = card.ability and type(card.ability.target) == 'table' and card.ability.target
        local target_name = nil
        if target and not target.debuff and target.config and target.config.center then
            local center = target.config.center
            target_name = (center.key and localize{type = 'name_text', key = center.key, set = 'Joker'})
            if not target_name or target_name == 'ERROR' then
                target_name = center.name or "Joker"
            end
        end
        local inactive_label = get_dict_entry("k_wg_vibe_inactive", "Inactive")
        card.joker_display_values.target_text = target_name or inactive_label
    end
}

local stack_overflow_def = {
    reminder_text = {
        { text = "(" },
        { text = "75%", colour = G.C.GREEN },
        { text = ")" }
    }
}

-- Register into JokerDisplay.Definitions and G.P_CENTERS
local jokers_to_register = {
    { key = "j_wg_card_in_sleeve", def = card_in_sleeve_def },
    { key = "j_wg_another_one", def = another_one_def },
    { key = "j_wg_occultist", def = occultist_def },
    { key = "j_wg_vibe_coder", def = vibe_coder_def },
    { key = "j_wg_leftmost_zero", def = leftmost_zero_def },
    { key = "j_wg_stack_overflow", def = stack_overflow_def }
}

if JokerDisplay and JokerDisplay.Definitions then
    for _, item in ipairs(jokers_to_register) do
        JokerDisplay.Definitions[item.key] = item.def
    end
end

if G and G.P_CENTERS then
    for _, item in ipairs(jokers_to_register) do
        if G.P_CENTERS[item.key] then
            G.P_CENTERS[item.key].joker_display_def = function() return item.def end
        end
    end
end
