-- =========================================================================
-- THIRD-PARTY MOD COMPATIBILITY & SAFEGUARDS
-- =========================================================================

local to_big = to_big or function(x) return x end

-- 1. CardSleeves: Ensure sleeve atlas can be found under both prefixed and unprefixed keys
if G and G.ASSET_ATLAS then
    local sleeve_atlas = G.ASSET_ATLAS['wg_sleeve_battery']
    if sleeve_atlas and not G.ASSET_ATLAS['sleeve_battery'] then
        G.ASSET_ATLAS['sleeve_battery'] = sleeve_atlas
    end
end

-- 2. Talisman / SMODS Safeguards:
-- Prevents "attempt to compare table with number" in evaluate_play_after (state_events.lua:1257)
if Blind and Blind.set_blind then
    local orig_blind_set_blind = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        orig_blind_set_blind(self, blind, reset, silent)
        if type(to_big) == 'function' and self.chips then
            self.chips = to_big(self.chips)
        end
        if WG and WG.is_battery_active and WG.is_battery_active() then
            WG.update_reserve(G.GAME.battery_reserve or 0)
        end
    end
end

if evaluate_play_after then
    local orig_evaluate_play_after = evaluate_play_after
    function evaluate_play_after(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
        if G.GAME and G.GAME.blind and type(to_big) == 'function' and G.GAME.blind.chips then
            G.GAME.blind.chips = to_big(G.GAME.blind.chips)
        end
        return orig_evaluate_play_after(text, disp_text, poker_hands, scoring_hand, non_loc_disp_text, percent, percent_delta)
    end
end
