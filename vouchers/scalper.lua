--- STEAMODDED VOUCHER: Scalper (Cambista)
--- All Consumables sell for +$1 above their purchase cost.

SMODS.Voucher {
    key = "scalper",
    atlas = "scalper",
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    config = { extra = 1 },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra } }
    end,
    loc_txt = {
        name = "Scalper",
        text = {
            "All {C:attention}Consumables{} sell for",
            "{C:money}+#1#{} above purchase cost"
        }
    },
    redeem = function(self, card)
        if G.consumeables and G.consumeables.cards then
            for _, c in ipairs(G.consumeables.cards) do
                c:set_cost()
            end
        end
    end
}
