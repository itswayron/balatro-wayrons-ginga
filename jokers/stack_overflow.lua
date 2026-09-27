--- JOKER: Stack Overflow (Legendary)
--- All retrigger effects have a 3/4 chance to retrigger again (including retriggers from this Joker).

SMODS.Joker {
    key = "stack_overflow",
    rarity = 4, -- Legendary
    cost = 20,
    atlas = "stack_overflow",
    pos = { x = 0, y = 0 },
    soul_pos = nil,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { num = 3, denom = 4 } },
    loc_vars = function(self, info_queue, card)
        if info_queue and G.P_CENTERS and G.P_CENTERS.j_oops then
            local already_in_queue = false
            for _, item in ipairs(info_queue) do
                if item == G.P_CENTERS.j_oops or (type(item) == "table" and item.key == "j_oops") then
                    already_in_queue = true
                    break
                end
            end
            if not already_in_queue then
                table.insert(info_queue, G.P_CENTERS.j_oops)
            end
        end
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.num or 3, extra.denom or 4 } }
    end,
    loc_txt = {
        name = "Stack Overflow",
        text = {
            "All {C:attention}retrigger{} effects",
            "have a {C:green}#1# in #2#{} chance",
            "to {C:attention}retrigger again{}",
            "{C:inactive}(Includes retriggers from this Joker){}",
            "{C:inactive}(Not affected by {C:attention,T:j_oops}dice{C:inactive}){}"
        }
    },
    calculate = function(self, card, context)
        -- Retrigger chaining is handled generically in SMODS.insert_repetitions hook below
    end
}

-- =========================================================================
-- GENERIC RETRIGGER CHAINING HOOK FOR STACK OVERFLOW
-- =========================================================================
local orig_insert_repetitions = SMODS.insert_repetitions
function SMODS.insert_repetitions(ret, eval, effect_card, _type)
    local start_len = #ret
    orig_insert_repetitions(ret, eval, effect_card, _type)
    local added = #ret - start_len

    if added > 0 and not WG.is_calculating_stack_overflow then
        local triggers = WG.get_stack_overflow_triggers and WG.get_stack_overflow_triggers()
        if triggers and #triggers > 0 then
            WG.is_calculating_stack_overflow = true

            local queue = added
            local total_chain = 0
            local max_chain = 50 -- Safety fail-safe to avoid runaway loops or engine freeze

            while queue > 0 and total_chain < max_chain do
                queue = queue - 1
                for _, so_card in ipairs(triggers) do
                    if total_chain >= max_chain then break end
                    -- Strictly fixed 75% independent roll (unaffected by Oops! All 6s as requested)
                    local roll = (type(pseudorandom) == 'function' and pseudorandom('stack_overflow')) or math.random()
                    if roll < 0.75 then
                        total_chain = total_chain + 1
                        queue = queue + 1

                        local effect = {
                            card = so_card,
                            message = localize('k_again_ex'),
                            repetitions = 1
                        }
                        if _type == 'joker_retrigger' then
                            effect.retrigger_card = so_card
                            effect.message_card = so_card
                            effect.retrigger_flag = true
                        elseif _type == 'individual_retrigger' then
                            effect.retrigger_card = so_card
                            effect.message_card = so_card
                            effect.retrigger_flag = true
                        end

                        table.insert(ret, _type and effect or { retriggers = effect })
                    end
                end
            end

            WG.is_calculating_stack_overflow = false
        end
    end
end
