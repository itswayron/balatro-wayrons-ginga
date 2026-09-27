local function is_matching_deck(deck_key)
    local is_deck_active = WG and WG.is_battery_deck_active and WG.is_battery_deck_active()
    if not deck_key then
        return is_deck_active or false
    end
    if deck_key == "b_wg_battery" then
        return true
    end
    return is_deck_active or false
end

if CardSleeves and CardSleeves.Sleeve then
    CardSleeves.Sleeve {
        key = "battery",
        name = "Battery Sleeve",
        atlas = "sleeve_battery",
        pos = { x = 0, y = 0 },
        config = { ante_scaling = 1.5 },
        unlocked = true,
        loc_vars = function(self)
            local key, vars
            local deck_key = self.get_current_deck_key and self.get_current_deck_key()
            if is_matching_deck(deck_key) then
                key = self.key .. "_alt"
                self.config = { ante_scaling = 1 }
                vars = {}
            else
                key = self.key
                self.config = { ante_scaling = 1.5 }
                vars = { self.config.ante_scaling }
            end
            return { key = key, vars = vars }
        end,
        apply = function(self)
            local deck_key = self.get_current_deck_key and self.get_current_deck_key()
            if is_matching_deck(deck_key) then
                self.config = { ante_scaling = 1 }
            else
                self.config = { ante_scaling = 1.5 }
            end
            CardSleeves.Sleeve.apply(self)
            if WG and WG.update_reserve then
                local to_big = to_big or function(x) return x end
                WG.update_reserve(G.GAME.battery_reserve or to_big(0))
            end
        end
    }
end
