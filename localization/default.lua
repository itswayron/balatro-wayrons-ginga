return {
    descriptions = {
        Joker = {
            j_wg_card_in_sleeve = {
                name = "Card up the Sleeve",
                text = {
                    "Played cards also count",
                    "as cards {C:attention}held in hand{}"
                }
            },
            j_wg_another_one = {
                name = "Another One",
                text = {
                    "Cards {C:attention}held in hand{}",
                    "also count as {C:attention}played cards{},",
                    "{C:red}#1#{} hand size"
                }
            },
            j_wg_occultist = {
                name = "Occultist",
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "{C:green}#1# in #2#{} chance to",
                    "create a {C:spectral}Spectral{} card",
                    "{C:inactive}(Must have room){}"
                }
            },
            j_wg_vibe_coder = {
                name = "Vibe Coder",
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "{C:green}#1# in #2#{} chance to copy",
                    "the ability of a {C:attention}random Joker{}",
                    "for the entire Blind"
                }
            },
            j_wg_leftmost_zero = {
                name = "Leftmost Zero",
                text = {
                    "The {C:attention}leftmost{} Joker",
                    "becomes {C:dark_edition}Negative{}",
                    "{C:inactive}(Ignores Negative Jokers){}"
                }
            },
            j_wg_stack_overflow = {
                name = "Stack Overflow",
                text = {
                    "All {C:attention}retrigger{} effects",
                    "have a {C:green}#1# in #2#{} chance",
                    "to {C:attention}retrigger again{}",
                    "{C:inactive}(Includes retriggers from this Joker){}",
                    "{C:inactive}(Not affected by {C:attention,T:j_oops}dice{C:inactive}){}"
                }
            }
        },
        Voucher = {
            v_wg_scalper = {
                name = "Scalper",
                text = {
                    "All {C:attention}Consumables{} sell for",
                    "{C:money}+#1#{} above purchase cost"
                }
            },
            v_wg_dollar_dealer = {
                name = "Dollar Dealer",
                text = {
                    "All {C:attention}Consumables{} sell for an",
                    "additional {C:money}+#1#{} {C:inactive}(+#2# total){}"
                }
            }
        },
        Back = {
            b_wg_battery = {
                name = "Battery Deck",
                text = {
                    "Surplus score from beaten Blinds",
                    "charges your {C:attention}Battery{}.",
                    "Max capacity is {C:attention}2X the sum{}",
                    "of all Blinds in the Ante.",
                    "On the {C:attention}final hand{}, uses charge if needed.",
                    "{C:red}X#1#{} base Blind size"
                }
            }
        },
        Sleeve = {
            sleeve_wg_battery = {
                name = "Battery Sleeve",
                text = {
                    "Surplus score charges your {C:attention}Battery{}.",
                    "Capacity is {C:attention}2X the sum{} of all Blinds in Ante.",
                    "Uses battery charge on the {C:attention}final hand{}.",
                    "{C:red}X#1#{} base Blind size"
                }
            },
            sleeve_wg_battery_alt = {
                name = "Battery Sleeve",
                text = {
                    "Charges {C:attention}2X{} faster,",
                    "discharges {C:attention}2X{} slower,",
                    "and has {C:attention}Infinite Capacity{}"
                }
            }
        }
    },
    misc = {
        dictionary = {
            k_wg_sleeve = "Up the Sleeve!",
            k_wg_another_one = "Another One!",
            k_wg_vibe_success = "It Works!",
            k_wg_vibe_fail = "Bug...",
            k_wg_vibe_copying = "Copying: #1#",
            k_wg_vibe_inactive = "Inactive",
            k_wg_vibe_failed = "Failed this Blind",
            k_wg_zero_target = "Negative: #1#",
            k_wg_reserve = "Battery: ",
            k_wg_stored = " in Battery!",
            k_wg_from_reserve = " from Battery!",
            k_wg_stored_splash = "+#1# Battery Charged!",
            k_wg_from_reserve_splash = "+#1# Used from Battery!",
            k_wg_battery_full = "Battery Full!",
            k_wg_battery_max_tag = " (MAX)",
            k_plus_spectral = "+1 Spectral",
            jdis_wg_played_to_hand = "#1# -> Hand",
            jdis_wg_hand_to_played = "#1# -> Played",
            jdis_wg_hand_size = "Hand Size",
            jdis_wg_random = "Random"
        }
    }
}
