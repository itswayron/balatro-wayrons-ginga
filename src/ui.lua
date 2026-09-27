-- =========================================================================
-- HUD UI INDICATORS
-- =========================================================================

local to_big = to_big or function(x) return x end

local orig_create_UIBox_HUD_blind = create_UIBox_HUD_blind
function create_UIBox_HUD_blind()
    local t = orig_create_UIBox_HUD_blind()
    if WG and WG.is_battery_active and WG.is_battery_active() then
        if not G.GAME.battery_reserve then
            WG.update_reserve(to_big(0))
        else
            WG.update_reserve(G.GAME.battery_reserve)
        end

        local box = t.nodes and t.nodes[2] and t.nodes[2].nodes and t.nodes[2].nodes[2] and t.nodes[2].nodes[2].nodes and t.nodes[2].nodes[2].nodes[2]
        if box and box.nodes then
            local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
            local res_label = (dict and dict.k_wg_reserve) or "Battery: "
            table.insert(box.nodes, {
                n = G.UIT.R,
                config = { align = "cm", minh = 0.35, maxw = 3.2, id = 'HUD_wg_reserve' },
                nodes = {
                    { n = G.UIT.T, config = { text = res_label, scale = 0.28, colour = G.C.WHITE, shadow = true } },
                    { n = G.UIT.T, config = { ref_table = G.GAME, ref_value = 'battery_reserve_text', scale = 0.30, colour = G.C.CHIPS, shadow = true } }
                }
            })
        end
    end
    return t
end
