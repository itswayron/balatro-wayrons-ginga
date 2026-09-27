-- =========================================================================
-- BATTERY DECK: STATE, CAPACITY, TRANSFER & SURPLUS LOGIC
-- =========================================================================

WG = WG or {}

local to_big = to_big or function(x) return x end
local debug_log = WG.debug_log or function() end

function WG.is_battery_deck_active()
    if not G.GAME or not G.GAME.selected_back then return false end
    local back = G.GAME.selected_back
    if back.effect and back.effect.center and back.effect.center.key == 'b_wg_battery' then
        return true
    end
    if back.name == 'Battery Deck' or back.name == 'b_wg_battery' then
        return true
    end
    return false
end

function WG.is_battery_sleeve_active()
    if not G.GAME then return false end
    if G.GAME.selected_sleeve == 'sleeve_wg_battery' then
        return true
    end
    if CardSleeves and CardSleeves.get_current_sleeve then
        local slv = CardSleeves.get_current_sleeve()
        if slv and (slv.key == 'sleeve_wg_battery' or slv.key == 'battery') then
            return true
        end
    end
    return false
end

function WG.is_battery_active()
    return WG.is_battery_deck_active() or WG.is_battery_sleeve_active()
end

function WG.has_sleeve_combo()
    return WG.is_battery_deck_active() and WG.is_battery_sleeve_active()
end

--- Calculate maximum battery capacity: 2X the sum of all Blinds in the current Ante
--- When Deck + Sleeve are combined, capacity is infinite (returns nil)
function WG.get_battery_capacity()
    if WG.has_sleeve_combo() then
        return nil
    end

    local tb = (type(to_big) == 'function' and to_big) or function(x) return x end
    if not G.GAME or not G.GAME.round_resets then return tb(2000) end
    local ante = G.GAME.round_resets.ante or 1
    if ante < 1 then ante = 1 end
    local scaling = (G.GAME.starting_params and G.GAME.starting_params.ante_scaling) or 1
    local base = tb((type(get_blind_amount) == 'function' and get_blind_amount(ante)) or 300)

    local small_mult = (G.P_BLINDS and G.P_BLINDS.bl_small and G.P_BLINDS.bl_small.mult) or 1.0
    local big_mult = (G.P_BLINDS and G.P_BLINDS.bl_big and G.P_BLINDS.bl_big.mult) or 1.5
    local boss_mult = 2.0
    if G.GAME.round_resets.blind_choices and G.GAME.round_resets.blind_choices.Boss and G.P_BLINDS and G.P_BLINDS[G.GAME.round_resets.blind_choices.Boss] then
        boss_mult = G.P_BLINDS[G.GAME.round_resets.blind_choices.Boss].mult or 2.0
    end

    local sum_blinds = (tb(base) * small_mult + tb(base) * big_mult + tb(base) * boss_mult) * scaling
    local max_capacity = tb(sum_blinds) * 2

    if type(max_capacity) == 'table' and max_capacity.floor then
        max_capacity = max_capacity:floor()
    else
        max_capacity = math.floor(tonumber(max_capacity) or max_capacity)
    end
    return tb(max_capacity)
end

function WG.update_reserve(new_val)
    if not G.GAME then return end
    local tb = (type(to_big) == 'function' and to_big) or function(x) return x end
    local val = new_val or tb(0)
    if tb(val) < tb(0) then
        val = tb(0)
    end
    local max_cap = WG.get_battery_capacity()
    if max_cap and tb(val) > tb(max_cap) then
        val = max_cap
    end
    G.GAME.battery_reserve = val

    local str_val = (type(number_format) == 'function' and number_format(val)) or tostring(val)
    if max_cap then
        local str_cap = (type(number_format) == 'function' and number_format(max_cap)) or tostring(max_cap)
        G.GAME.battery_reserve_text = str_val .. " / " .. str_cap
    else
        G.GAME.battery_reserve_text = str_val
    end

    if G.HUD_blind and G.HUD_blind.get_UIE_by_ID then
        local reserve_ui = G.HUD_blind:get_UIE_by_ID('HUD_wg_reserve')
        if reserve_ui and reserve_ui.juice_up then
            reserve_ui:juice_up(0.4, 0.4)
        end
    end
end

function WG.show_reserve_splash(msg, colour, sound_name)
    colour = colour or G.C.CHIPS
    if type(attention_text) == 'function' then
        attention_text({
            text = msg,
            scale = 1.2,
            hold = 2.0,
            align = 'cm',
            major = G.play or G.ROOM_ATTACH,
            offset = { x = 0, y = -0.5 },
            colour = colour
        })
    end
    if G.ROOM then
        G.ROOM.jiggle = (G.ROOM.jiggle or 0) + 3
    end
    if sound_name then
        play_sound(sound_name, 1, 0.8)
    else
        play_sound('chips2', 1, 0.8)
    end
    play_sound('cardFan2', 0.9, 0.7)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.8,
        func = function()
            return true
        end
    }))
end

-- =========================================================================
-- HOOK: RESERVE CONSUMPTION ON FINAL HAND & SURPLUS STORAGE HOOK
-- =========================================================================
local orig_end_round = end_round
function end_round()
    if WG.is_battery_active() and G.GAME and G.GAME.blind then
        local round_id = tostring(G.GAME.round_resets.ante) .. "_" .. tostring(G.GAME.blind_on_deck or G.GAME.blind:get_type())

        -- 1. Check if the player needs reserve score to beat the blind
        if to_big(G.GAME.chips) < to_big(G.GAME.blind.chips) then
            local needed = to_big(G.GAME.blind.chips) - to_big(G.GAME.chips)
            local reserve = to_big(G.GAME.battery_reserve or 0)
            if to_big(needed) > to_big(0) and to_big(reserve) > to_big(0) then
                local max_can_transfer = reserve
                if WG.has_sleeve_combo() then
                    max_can_transfer = to_big(reserve) * 2
                end

                local to_transfer = (to_big(needed) < to_big(max_can_transfer)) and needed or max_can_transfer
                G.GAME.chips = to_big(G.GAME.chips) + to_big(to_transfer)

                -- Sleeve combo bonus: discharges 2x slower (deducts only half)
                local deduct = to_transfer
                if WG.has_sleeve_combo() then
                    deduct = to_big(to_transfer) / 2
                    if type(deduct) == 'table' and deduct.floor then
                        deduct = deduct:floor()
                    else
                        deduct = math.floor(tonumber(deduct) or deduct)
                    end
                end

                local new_reserve = to_big(reserve) - to_big(deduct)
                if to_big(new_reserve) < to_big(0) then new_reserve = to_big(0) end
                WG.update_reserve(new_reserve)

                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                local suffix = (dict and dict.k_wg_from_reserve) or " from Battery!"
                local str_transfer = (type(number_format) == 'function' and number_format(to_transfer)) or tostring(to_transfer)
                local msg = "+" .. str_transfer .. suffix
                if G.deck then
                    card_eval_status_text(G.deck, 'extra', nil, nil, nil, {
                        message = msg,
                        colour = G.C.CHIPS
                    })
                end

                local splash_template = (dict and dict.k_wg_from_reserve_splash) or "+#1# Used from Battery!"
                local splash_msg = splash_template:gsub("#1#", function() return str_transfer end)
                WG.show_reserve_splash(splash_msg, G.C.CHIPS, 'chips2')

                debug_log("Reserve used! Transferred: " .. tostring(str_transfer) .. ", Deducted: " .. tostring(deduct) .. ", Remaining: " .. tostring(G.GAME.battery_reserve_text))
            end
        end

        -- 2. Check if the player beat the blind and has surplus score to store
        if to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips) and WG.last_accumulated_round ~= round_id then
            local surplus = to_big(G.GAME.chips) - to_big(G.GAME.blind.chips)
            if to_big(surplus) > to_big(0) then
                WG.last_accumulated_round = round_id

                -- Sleeve combo bonus: charges 2x faster (doubles stored surplus)
                local combo_bonus = false
                if WG.has_sleeve_combo() then
                    surplus = to_big(surplus) * 2
                    combo_bonus = true
                end

                local current_res = to_big(G.GAME.battery_reserve or 0)
                local max_cap = WG.get_battery_capacity()

                local actual_added = surplus
                local is_full = false
                local is_capped = false

                if max_cap then
                    local space = to_big(max_cap) - to_big(current_res)
                    if to_big(space) < to_big(0) then space = to_big(0) end

                    if to_big(space) <= to_big(0) then
                        is_full = true
                        actual_added = to_big(0)
                    elseif to_big(surplus) >= to_big(space) then
                        actual_added = space
                        is_capped = true
                    else
                        actual_added = surplus
                    end
                end

                local new_reserve = to_big(current_res) + to_big(actual_added)
                WG.update_reserve(new_reserve)

                local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
                if is_full then
                    local msg_full = (dict and dict.k_wg_battery_full) or "Battery Full!"
                    if G.deck then
                        card_eval_status_text(G.deck, 'extra', nil, nil, nil, {
                            message = msg_full,
                            colour = G.C.CHIPS
                        })
                    end
                    WG.show_reserve_splash(msg_full, G.C.CHIPS, 'chips2')
                    debug_log("Battery full! No surplus added. Reserve: " .. tostring(G.GAME.battery_reserve_text))
                else
                    local str_added = (type(number_format) == 'function' and number_format(actual_added)) or tostring(actual_added)
                    local suffix = (dict and dict.k_wg_stored) or " in Battery!"
                    local extra_tag = ""
                    if is_capped then
                        extra_tag = (dict and dict.k_wg_battery_max_tag) or " (MAX)"
                    elseif combo_bonus then
                        extra_tag = " (2X)"
                    end

                    local msg = "+" .. str_added .. suffix .. extra_tag
                    if G.deck then
                        card_eval_status_text(G.deck, 'extra', nil, nil, nil, {
                            message = msg,
                            colour = G.C.CHIPS
                        })
                    end

                    local splash_template = (dict and dict.k_wg_stored_splash) or "+#1# Battery Charged!"
                    local splash_msg = splash_template:gsub("#1#", function() return str_added end) .. extra_tag
                    WG.show_reserve_splash(splash_msg, G.C.CHIPS, 'chips2')

                    debug_log("Surplus accumulated! Added: " .. tostring(str_added) .. ", New Reserve: " .. tostring(G.GAME.battery_reserve_text) .. (is_capped and " (CAPPED)" or "") .. (combo_bonus and " (2X CHARGE)" or ""))
                end
            end
        end
    end

    orig_end_round()
end
