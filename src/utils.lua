-- =========================================================================
-- UTILITY & IDENTIFICATION HELPERS
-- =========================================================================

WG = WG or {}

local to_big = to_big or function(x) return x end

function WG.debug_log(msg)
    if sendDebugMessage then
        sendDebugMessage("[Wayron's Ginga] " .. tostring(msg))
    end
end

local function is_sleeve_joker(c)
    if not c or c.debuff then return false end
    local k = c.config and (c.config.center_key or (c.config.center and c.config.center.key))
    if k == 'j_wg_card_in_sleeve' then return true end
    if c.ability then
        local name = c.ability.name
        if name == 'j_wg_card_in_sleeve' or name == 'Card up the Sleeve' then
            return true
        end
        if c.ability.vibe_active and c.ability.vibe_target and type(c.ability.vibe_target) == 'table' then
            return is_sleeve_joker(c.ability.vibe_target)
        end
    end
    return false
end

local function is_another_one_joker(c)
    if not c or c.debuff then return false end
    local k = c.config and (c.config.center_key or (c.config.center and c.config.center.key))
    if k == 'j_wg_another_one' then return true end
    if c.ability then
        local name = c.ability.name
        if name == 'j_wg_another_one' or name == 'Another One' then
            return true
        end
        if c.ability.vibe_active and c.ability.vibe_target and type(c.ability.vibe_target) == 'table' then
            return is_another_one_joker(c.ability.vibe_target)
        end
    end
    return false
end

local function is_copier(c)
    if not c or c.debuff then return false end
    local k = c.config and (c.config.center_key or (c.config.center and c.config.center.key))
    if k == 'j_blueprint' or k == 'j_brainstorm' then return true end
    if c.ability and (c.ability.name == 'Blueprint' or c.ability.name == 'Brainstorm') then return true end
    return false
end

--- Helper: Find all active Card up the Sleeve triggers (including Blueprint & Brainstorm)
function WG.get_sleeve_triggers()
    local triggers = {}
    if not G.jokers or not G.jokers.cards then return triggers end

    for _, joker in ipairs(G.jokers.cards) do
        if not joker.debuff then
            if is_sleeve_joker(joker) then
                table.insert(triggers, joker)
            elseif is_copier(joker) then
                local visited = { [joker] = true }
                local target = nil
                local jk_name = joker.ability and joker.ability.name or (joker.config and joker.config.center_key)

                if jk_name == 'Blueprint' or jk_name == 'j_blueprint' then
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i] == joker then target = G.jokers.cards[i+1] end
                    end
                elseif jk_name == 'Brainstorm' or jk_name == 'j_brainstorm' then
                    target = G.jokers.cards[1]
                end

                while target and is_copier(target) do
                    if visited[target] then target = nil; break end
                    visited[target] = true
                    local t_name = target.ability and target.ability.name or (target.config and target.config.center_key)
                    if t_name == 'Blueprint' or t_name == 'j_blueprint' then
                        local next_target = nil
                        for i = 1, #G.jokers.cards do
                            if G.jokers.cards[i] == target then next_target = G.jokers.cards[i+1] end
                        end
                        target = next_target
                    elseif t_name == 'Brainstorm' or t_name == 'j_brainstorm' then
                        target = G.jokers.cards[1]
                    end
                end

                if target and not target.debuff and is_sleeve_joker(target) then
                    table.insert(triggers, joker)
                end
            end
        end
    end
    return triggers
end

--- Helper: Find all active Another One triggers (including Blueprint & Brainstorm)
function WG.get_another_one_triggers()
    local triggers = {}
    if not G.jokers or not G.jokers.cards then return triggers end

    for _, joker in ipairs(G.jokers.cards) do
        if not joker.debuff then
            if is_another_one_joker(joker) then
                table.insert(triggers, joker)
            elseif is_copier(joker) then
                local visited = { [joker] = true }
                local target = nil
                local jk_name = joker.ability and joker.ability.name or (joker.config and joker.config.center_key)

                if jk_name == 'Blueprint' or jk_name == 'j_blueprint' then
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i] == joker then target = G.jokers.cards[i+1] end
                    end
                elseif jk_name == 'Brainstorm' or jk_name == 'j_brainstorm' then
                    target = G.jokers.cards[1]
                end

                while target and is_copier(target) do
                    if visited[target] then target = nil; break end
                    visited[target] = true
                    local t_name = target.ability and target.ability.name or (target.config and target.config.center_key)
                    if t_name == 'Blueprint' or t_name == 'j_blueprint' then
                        local next_target = nil
                        for i = 1, #G.jokers.cards do
                            if G.jokers.cards[i] == target then next_target = G.jokers.cards[i+1] end
                        end
                        target = next_target
                    elseif t_name == 'Brainstorm' or t_name == 'j_brainstorm' then
                        target = G.jokers.cards[1]
                    end
                end

                if target and not target.debuff and is_another_one_joker(target) then
                    table.insert(triggers, joker)
                end
            end
        end
    end
    return triggers
end

local function is_stack_overflow_joker(c)
    if not c or c.debuff then return false end
    local k = c.config and (c.config.center_key or (c.config.center and c.config.center.key))
    if k == 'j_wg_stack_overflow' then return true end
    if c.ability and c.ability.name == 'Stack Overflow' then return true end
    return false
end

--- Helper: Find all active Stack Overflow triggers (excluding copiers as it is blueprint incompatible)
function WG.get_stack_overflow_triggers()
    local triggers = {}
    if not G.jokers or not G.jokers.cards then return triggers end

    for _, joker in ipairs(G.jokers.cards) do
        if not joker.debuff and is_stack_overflow_joker(joker) then
            table.insert(triggers, joker)
        end
    end
    return triggers
end

--- Helper: Get total sell cost bonus from active WG vouchers (Scalper / Dollar Dealer)
function WG.get_voucher_consumable_bonus()
    if not G.GAME or not G.GAME.used_vouchers then return 0 end
    if G.GAME.used_vouchers['v_wg_dollar_dealer'] then
        return 3
    elseif G.GAME.used_vouchers['v_wg_scalper'] then
        return 1
    end
    return 0
end

--- Helper: Check if a card is a consumable (vanilla or modded)
function WG.is_consumable(card)
    if not card or not card.ability then return false end
    -- Exclude non-consumable card sets explicitly
    local set = card.ability.set
    if set == 'Joker' or set == 'Voucher' or set == 'Booster' or set == 'Default' or set == 'Enhanced' then
        return false
    end
    -- Standard Balatro consumable table (vanilla & most mods)
    if card.ability.consumeable or card.ability.consumable then return true end
    -- Vanilla consumable sets
    if set == 'Tarot' or set == 'Planet' or set == 'Spectral' then return true end
    -- Steamodded custom consumable types registered by other mods (e.g. Cryptid, Bunco)
    if SMODS and SMODS.ConsumableTypes and set and SMODS.ConsumableTypes[set] then return true end
    -- Stored in the player's consumable area
    if card.area and G.consumeables and card.area == G.consumeables then return true end
    return false
end
