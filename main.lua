--- STEAMODDED MOD: Wayron's Ginga
--- Author: Wayron
--- Description: A collection of Jokers and Decks by Wayron that bend the rules of card interactions.

WG = WG or {}

SMODS.current_mod.optional_features = {
    retrigger_joker = true
}

-- 1. Atlases
assert(SMODS.load_file("src/atlases.lua"))()

-- 2. Core Systems & Helpers
assert(SMODS.load_file("src/utils.lua"))()
assert(SMODS.load_file("src/battery.lua"))()
assert(SMODS.load_file("src/scoring.lua"))()
assert(SMODS.load_file("src/ui.lua"))()
assert(SMODS.load_file("src/compat.lua"))()

-- 3. Jokers & Decks
assert(SMODS.load_file("jokers/card_in_sleeve.lua"))()
assert(SMODS.load_file("jokers/another_one.lua"))()
assert(SMODS.load_file("jokers/occultist.lua"))()
assert(SMODS.load_file("jokers/vibe_coder.lua"))()
assert(SMODS.load_file("jokers/leftmost_zero.lua"))()
assert(SMODS.load_file("jokers/stack_overflow.lua"))()
assert(SMODS.load_file("decks/battery.lua"))()

-- 4. Mod Integrations
if CardSleeves and CardSleeves.Sleeve then
    assert(SMODS.load_file("sleeves/battery_sleeve.lua"))()
end

if JokerDisplay then
    assert(SMODS.load_file("compat/jokerdisplay.lua"))()
end

WG.debug_log("Wayron's Ginga mod loaded successfully.")
