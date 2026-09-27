-- =========================================================================
-- SCORING ENGINE INTERCEPTOR & JOKER SYNERGY HOOKS
-- =========================================================================

local debug_log = (WG and WG.debug_log) or function() end

local orig_calculate_main_scoring = SMODS.calculate_main_scoring
function SMODS.calculate_main_scoring(context, scoring_hand)
    -- Cache phase types BEFORE calling orig_calculate_main_scoring (avoids table mutation bugs)
    local is_hand_scoring = (context and context.cardarea == G.hand)
    local is_play_scoring = (context and context.cardarea == G.play)

    orig_calculate_main_scoring(context, scoring_hand)

    -- 1. ANOTHER ONE: When played cards scoring finishes, evaluate held-in-hand cards as played cards!
    if is_play_scoring and not (context and (context.wg_play_eval or context.wg_eval)) then
        local another_one_triggers = WG.get_another_one_triggers()
        if #another_one_triggers > 0 and G.hand and G.hand.cards and #G.hand.cards > 0 then
            debug_log("Activating Another One triggers. Count: " .. #another_one_triggers)
            local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
            local msg = (dict and dict.k_wg_another_one) or "Another One!"

            for t_idx, trigger_joker in ipairs(another_one_triggers) do
                card_eval_status_text(trigger_joker, 'extra', nil, nil, nil, {
                    message = msg
                })
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        trigger_joker:juice_up(0.7, 0.5)
                        return true
                    end
                }))

                -- Snapshot cards currently in hand
                local hand_cards_snapshot = {}
                for _, c in ipairs(G.hand.cards) do
                    if not c.shattered and not c.destroyed then
                        table.insert(hand_cards_snapshot, c)
                    end
                end

                for _, hand_card in ipairs(hand_cards_snapshot) do
                    if not hand_card.shattered and not hand_card.destroyed then
                        debug_log("Another One scoring hand card as played: rank " .. tostring(hand_card.base and hand_card.base.value))
                        local eval_context = {
                            cardarea = G.play,
                            scoring_hand = context.scoring_hand,
                            full_hand = G.play.cards,
                            scoring_name = context.scoring_name,
                            poker_hands = context.poker_hands,
                            wg_play_eval = true
                        }
                        SMODS.score_card(hand_card, eval_context)

                        -- Authentic Balatro Glass Card shatter risk on play evaluation
                        if SMODS.has_enhancement(hand_card, 'm_glass') and not hand_card.debuff then
                            if pseudorandom('glass') < G.GAME.probabilities.normal / 4 then
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.3,
                                    func = function()
                                        hand_card:shatter()
                                        return true
                                    end
                                }))
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. CARD UP THE SLEEVE: When held-in-hand scoring finishes, evaluate played cards as held-in-hand!
    if is_hand_scoring and not (context and (context.wg_eval or context.wg_play_eval)) then
        local sleeve_triggers = WG.get_sleeve_triggers()
        if #sleeve_triggers > 0 and G.play and G.play.cards and #G.play.cards > 0 then
            debug_log("Activating Card up the Sleeve triggers. Count: " .. #sleeve_triggers)
            -- Cache played cards for end-of-round evaluation if the hand wins
            WG.last_played_cards = {}
            for _, c in ipairs(G.play.cards) do
                if not c.shattered and not c.destroyed then
                    table.insert(WG.last_played_cards, c)
                end
            end

            local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
            local msg = (dict and dict.k_wg_sleeve) or "Up the Sleeve!"

            for t_idx, trigger_joker in ipairs(sleeve_triggers) do
                card_eval_status_text(trigger_joker, 'extra', nil, nil, nil, {
                    message = msg
                })
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        trigger_joker:juice_up(0.7, 0.5)
                        return true
                    end
                }))

                -- Evaluate each played card as held in hand
                for _, played_card in ipairs(G.play.cards) do
                    if not played_card.shattered and not played_card.destroyed then
                        debug_log("Scoring played card as held in hand: rank " .. tostring(played_card.base and played_card.base.value))
                        local eval_context = {
                            cardarea = G.hand,
                            scoring_hand = context.scoring_hand,
                            full_hand = G.play.cards,
                            scoring_name = context.scoring_name,
                            poker_hands = context.poker_hands,
                            wg_eval = true
                        }
                        SMODS.score_card(played_card, eval_context)
                    end
                end
            end
        end
    end
end

--- HOOK: SMODS.calculate_end_of_round_effects
--- Evaluates Gold Cards ($3) and Blue Seals (Planets) for played cards on winning hands.
local orig_calculate_end_of_round_effects = SMODS.calculate_end_of_round_effects
function SMODS.calculate_end_of_round_effects(context)
    local is_hand_eor = (context and context.cardarea == G.hand)
    orig_calculate_end_of_round_effects(context)

    if is_hand_eor and not (context and context.wg_eor_eval) then
        local triggers = WG.get_sleeve_triggers()
        if #triggers > 0 and WG.last_played_cards and #WG.last_played_cards > 0 then
            local dict = G.localization and G.localization.misc and G.localization.misc.dictionary
            local msg = (dict and dict.k_wg_sleeve) or "Up the Sleeve!"

            for _, trigger_joker in ipairs(triggers) do
                card_eval_status_text(trigger_joker, 'extra', nil, nil, nil, {
                    message = msg
                })
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        trigger_joker:juice_up(0.7, 0.5)
                        return true
                    end
                }))

                local eval_ctx = {
                    cardarea = G.hand,
                    end_of_round = true,
                    beat_boss = context.beat_boss,
                    wg_eor_eval = true
                }

                for _, card in ipairs(WG.last_played_cards) do
                    if not card.shattered and not card.destroyed then
                        local reps = {1}
                        local j = 1
                        while j <= #reps do
                            card.repetition_trigger = j > 1 and j - 1
                            if reps[j] ~= 1 then
                                local _, eff = next(reps[j])
                                SMODS.calculate_effect(eff, eff.card)
                            end

                            eval_ctx.playing_card_end_of_round = true
                            local effects = { eval_card(card, eval_ctx) }
                            SMODS.calculate_quantum_enhancements(card, effects, eval_ctx)
                            eval_ctx.playing_card_end_of_round = nil
                            eval_ctx.individual = true
                            eval_ctx.other_card = card

                            SMODS.calculate_card_areas('jokers', eval_ctx, effects, { main_scoring = true })
                            SMODS.calculate_card_areas('individual', eval_ctx, effects, { main_scoring = true })

                            local flags = SMODS.trigger_effects(effects, card)

                            eval_ctx.individual = nil
                            eval_ctx.repetition = true
                            eval_ctx.card_effects = effects
                            if reps[j] == 1 then
                                SMODS.calculate_repetitions(card, eval_ctx, reps)
                            end

                            eval_ctx.repetition = nil
                            eval_ctx.card_effects = nil
                            eval_ctx.other_card = nil
                            j = j + (flags.calculated and 1 or #reps)
                        end
                        card.repetition_trigger = nil
                    end
                end
            end
            WG.last_played_cards = nil
        end
    end
end

--- HOOK: Raised Fist compatibility
local card_calc_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    if self.ability and self.ability.name == 'Raised Fist' and context.cardarea == G.hand and context.individual then
        local triggers = WG.get_sleeve_triggers()
        if #triggers > 0 and G.play and G.play.cards and #G.play.cards > 0 then
            local temp_Mult, temp_ID = 15, 15
            local raised_card = nil
            local candidates = {}
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do table.insert(candidates, c) end
            end
            for _, c in ipairs(G.play.cards) do table.insert(candidates, c) end

            for _, c in ipairs(candidates) do
                if c.base and temp_ID >= c.base.id and not (SMODS.has_no_rank and SMODS.has_no_rank(c)) then
                    temp_Mult = c.base.nominal
                    temp_ID = c.base.id
                    raised_card = c
                end
            end

            if raised_card == context.other_card then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED,
                        card = self,
                    }
                else
                    return {
                        h_mult = 2 * temp_Mult,
                        card = self
                    }
                end
            end
            return nil
        end
    end
    return card_calc_joker_ref(self, context)
end
