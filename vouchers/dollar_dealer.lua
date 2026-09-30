--- STEAMODDED VOUCHER: Dollar Dealer (Doleiro)
--- All Consumables sell for an additional +$2 (+$3 total).
--- Requires Scalper.

SMODS.Voucher {
    key = "dollar_dealer",
    atlas = "dollar_dealer",
    pos = { x = 0, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    requires = { "v_wg_scalper" },
    config = { extra = 2, total = 3 },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra, self.config.total } }
    end,
    loc_txt = {
        name = "Dollar Dealer",
        text = {
            "All {C:attention}Consumables{} sell for an",
            "additional {C:money}+#1#{} {C:inactive}(+#2# total){}"
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
