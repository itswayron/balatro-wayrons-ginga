--- JOKER: Leftmost Zero
--- The leftmost Joker becomes Negative (ignores Jokers with an edition).
--- Has 10% flat chance to generate as Negative.

WG = WG or {}

function WG.update_leftmost_zero()
    if WG.is_updating_leftmost_zero then return end
    if not G.jokers or not G.jokers.cards then return end
    WG.is_updating_leftmost_zero = true

    -- Auto-heal: Fix any corrupted mod below zero from previous bugs
    if G.jokers.config and G.jokers.config.card_limits and G.jokers.config.card_limits.mod and G.jokers.config.card_limits.mod < 0 then
        G.jokers.config.card_limits.mod = 0
    end

    -- 1. Find active Leftmost Zero in G.jokers (prefer one that is not at index 1 if multiple exist)
    local zero_card = nil
    for i = #G.jokers.cards, 1, -1 do
        local j = G.jokers.cards[i]
        if not j.debuff and j.config then
            local k = j.config.center_key or (j.config.center and j.config.center.key)
            if k == 'j_wg_leftmost_zero' then
                zero_card = j
                if i > 1 then break end
            end
        end
    end

    -- Clean up legacy extra slot on zero_card itself to ensure no duplicate slot
    if zero_card and zero_card.ability and zero_card.ability.card_limit ~= 0 then
        zero_card.ability.card_limit = 0
    end

    -- 2. Determine target (Option A: ignores Leftmost Zero itself, and ignores naturally Negative jokers)
    local target = nil
    if zero_card and #G.jokers.cards > 0 then
        local leftmost = G.jokers.cards[1]
        if leftmost ~= zero_card and not leftmost.debuff then
            local is_already_target = leftmost.ability and leftmost.ability.wg_leftmost_zero_applied
            local is_naturally_negative = leftmost.edition and leftmost.edition.negative and not is_already_target
            if is_already_target or not is_naturally_negative then
                target = leftmost
            end
        end
    end

    -- 3. Migration / healing for runs saved prior to this fix:
    -- If leftmost is Negative, but doesn't have the flag yet, and zero_card was active
    if target and target.edition and target.edition.negative and target.ability and not target.ability.wg_leftmost_zero_applied then
        local any_applied = false
        for _, c in ipairs(G.jokers.cards) do
            if c.ability and c.ability.wg_leftmost_zero_applied then
                any_applied = true
                break
            end
        end
        if not any_applied then
            target.ability.wg_leftmost_zero_applied = true
            target.ability.wg_leftmost_zero_orig_edition = "NONE"
        end
    end

    local changed = false

    -- 4. Revert any card in G.jokers that is no longer the target
    for _, c in ipairs(G.jokers.cards) do
        if c.ability and c.ability.wg_leftmost_zero_applied and c ~= target then
            local orig = c.ability.wg_leftmost_zero_orig_edition
            c.ability.wg_leftmost_zero_applied = nil
            c.ability.wg_leftmost_zero_orig_edition = nil

            local was_added = c.added_to_deck
            c.added_to_deck = false -- Prevent any outside hooks from altering card_limits
            if orig and orig ~= "NONE" then
                c:set_edition(orig, true)
            else
                c:set_edition(nil, true)
            end
            c.added_to_deck = was_added

            changed = true
        end
    end

    -- 5. Apply to target if not already applied
    if target and not (target.ability and target.ability.wg_leftmost_zero_applied and target.edition and target.edition.negative) then
        local orig_key = "NONE"
        if target.edition and not (target.ability and target.ability.wg_leftmost_zero_applied) then
            orig_key = target.edition.key or (target.edition.type and ('e_' .. target.edition.type)) or "NONE"
        elseif target.ability and target.ability.wg_leftmost_zero_orig_edition then
            orig_key = target.ability.wg_leftmost_zero_orig_edition
        end

        target.ability.wg_leftmost_zero_orig_edition = orig_key
        target.ability.wg_leftmost_zero_applied = true

        local was_added = target.added_to_deck
        target.added_to_deck = false
        target:set_edition({ negative = true }, true)
        target.added_to_deck = was_added

        changed = true
        target:juice_up(0.6, 0.4)
        play_sound('negative', 1.5, 0.4)
    end

    -- 6. Update target reference for UI / JokerDisplay (runtime only)
    if zero_card and zero_card.ability then
        zero_card.ability.target = target
    end

    if changed and G.jokers.handle_card_limit then
        G.jokers:handle_card_limit()
    end

    WG.is_updating_leftmost_zero = false
end

SMODS.Joker {
    key = "leftmost_zero",
    rarity = 2,
    cost = 5,
    atlas = "leftmost_zero",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    set_ability = function(self, card, initial, delay_sprites)
        -- 10% flat chance to generate with Negative edition during runs
        if G.STAGE == G.STAGES.RUN and not card.edition then
            local roll = (type(pseudorandom) == 'function' and pseudorandom('leftmost_zero_neg')) or math.random()
            if roll < 0.10 then
                card:set_edition({ negative = true }, true)
            end
        end
    end,
    loc_vars = function(self, info_queue, card)
        if info_queue and G.P_CENTERS and G.P_CENTERS.e_negative then
            table.insert(info_queue, G.P_CENTERS.e_negative)
        end

        local main_end = nil
        if card and card.area == G.jokers and G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
            local target = card.ability and type(card.ability.target) == 'table' and card.ability.target
            if target and not target.debuff and target.config and target.config.center then
                local center = target.config.center
                local target_name = (center.key and localize{type = 'name_text', key = center.key, set = 'Joker'})
                if not target_name or target_name == 'ERROR' then
                    target_name = center.name or "Joker"
                end
                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local target_label = (dict and dict.k_wg_zero_target) or "Negative: #1#"
                local display_text = target_label:gsub("#1#", function() return target_name end)
                main_end = {
                    { n = G.UIT.C, config = { align = "bm", minh = 0.4 }, nodes = {
                        { n = G.UIT.C, config = { align = "m", colour = G.C.DARK_EDITION, r = 0.05, padding = 0.06 }, nodes = {
                            { n = G.UIT.T, config = { text = " " .. display_text .. " ", colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.85 } }
                        }}
                    }}
                }
            else
                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local inactive_text = (dict and dict.k_wg_vibe_inactive) or "Inactive"
                main_end = {
                    { n = G.UIT.C, config = { align = "bm", minh = 0.4 }, nodes = {
                        { n = G.UIT.C, config = { align = "m", colour = G.C.UI.BACKGROUND_INACTIVE or G.C.GREY, r = 0.05, padding = 0.06 }, nodes = {
                            { n = G.UIT.T, config = { text = " " .. inactive_text .. " ", colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.85 } }
                        }}
                    }}
                }
            end
        end

        return { vars = {}, main_end = main_end }
    end,
    loc_txt = {
        name = "Leftmost Zero",
        text = {
            "The {C:attention}leftmost{} Joker",
            "becomes {C:dark_edition}Negative{}",
            "{C:inactive}(Ignores Negative Jokers){}"
        }
    },
    add_to_deck = function(self, card, from_debuff)
        if WG and WG.update_leftmost_zero then
            WG.update_leftmost_zero()
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.jokers and G.jokers.cards then
            for _, c in ipairs(G.jokers.cards) do
                if c.ability and c.ability.wg_leftmost_zero_applied then
                    local orig = c.ability.wg_leftmost_zero_orig_edition
                    c.ability.wg_leftmost_zero_applied = nil
                    c.ability.wg_leftmost_zero_orig_edition = nil

                    local was_added = c.added_to_deck
                    c.added_to_deck = false
                    if orig and orig ~= "NONE" then
                        c:set_edition(orig, true)
                    else
                        c:set_edition(nil, true)
                    end
                    c.added_to_deck = was_added
                end
            end
        end
        if card.ability then
            card.ability.card_limit = 0
            card.ability.target = nil
        end
        if G.jokers and G.jokers.handle_card_limit then
            G.jokers:handle_card_limit()
        end
    end
}

-- Hook game run start / load so Leftmost Zero is cleanly initialized
local orig_game_start_run = Game.start_run
function Game:start_run(args)
    orig_game_start_run(self, args)
    if G.jokers and WG and WG.update_leftmost_zero then
        G.E_MANAGER:add_event(Event({
            func = function()
                WG.update_leftmost_zero()
                return true
            end
        }))
    end
end

-- Hook save_run to prevent serialization of raw Card object references in ability.target
local orig_save_run = save_run
function save_run()
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if j.ability and j.ability.target then
                j.ability.target = nil
            end
        end
    end
    orig_save_run()
    if WG and WG.update_leftmost_zero then
        WG.update_leftmost_zero()
    end
end

-- Hook drag & drop release (updates immediately upon dropping a card)
local orig_node_stop_drag = Node.stop_drag
function Node:stop_drag()
    local ret = orig_node_stop_drag(self)
    if G.jokers and WG and WG.update_leftmost_zero then
        G.jokers:align_cards()
        WG.update_leftmost_zero()
    end
    return ret
end

-- Hook cardarea reordering
local orig_cardarea_set_ranks = CardArea.set_ranks
function CardArea:set_ranks()
    orig_cardarea_set_ranks(self)
    if self == G.jokers and WG and WG.update_leftmost_zero then
        WG.update_leftmost_zero()
    end
end

-- Hook card removal (sell / destroy)
local orig_cardarea_remove_card = CardArea.remove_card
function CardArea:remove_card(card, discarded_only)
    local ret = orig_cardarea_remove_card(self, card, discarded_only)
    if self == G.jokers and WG and WG.update_leftmost_zero then
        WG.update_leftmost_zero()
    end
    return ret
end

-- Hook card insertion (buy / pack)
local orig_cardarea_emplace = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    orig_cardarea_emplace(self, card, location, stay_flipped)
    if self == G.jokers and WG and WG.update_leftmost_zero then
        WG.update_leftmost_zero()
    end
end

-- Hook debuff state changes
local orig_card_set_debuff = Card.set_debuff
function Card:set_debuff(should_debuff)
    orig_card_set_debuff(self, should_debuff)
    if self.area == G.jokers and WG and WG.update_leftmost_zero then
        WG.update_leftmost_zero()
    end
end
