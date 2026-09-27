SMODS.Back {
    key = "battery",
    atlas = "b_battery",
    pos = { x = 0, y = 0 },
    config = { ante_scaling = 1.5 },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.ante_scaling } }
    end,
    loc_txt = {
        name = "Battery Deck",
        text = {
            "Surplus score from beaten Blinds",
            "charges your {C:attention}Battery{}.",
            "Max capacity is {C:attention}2X the sum{}",
            "of all Blinds in the Ante.",
            "On the {C:attention}final hand{} of a Blind,",
            "uses battery charge if needed.",
            "{C:red}X#1#{} base Blind size"
        }
    },
    apply = function(self, back)
        if WG and WG.update_reserve then
            local to_big = to_big or function(x) return x end
            WG.update_reserve(G.GAME.battery_reserve or to_big(0))
        end
    end
}
