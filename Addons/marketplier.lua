SMODS.Atlas {
    key = 'Marketplier',
    px = 450,
    py = 360,
    path = 'marketpliers.png',
    frames = 12,
    fps = 12,
    atlas_table = 'ANIMATION_ATLAS'
}

Btraddon.sprite = nil
Btraddon.menu = nil

local FRAMES = 12
local ANIMS = {
    base   = { row = 0 },
    death  = { row = 1, hold = true },
    win    = { row = 2 },
    prayge = { row = 3 },
    blindwin = { row = 4 },
}

local function get_anim()
    local state = G.GAME and G.GAME.markstate or "base"
    return ANIMS[state] or ANIMS.base
end

local function apply_state()
    local s = Btraddon.sprite
    if not s then return end

    local anim = get_anim()
    local start = G.TIMERS.REAL

    s.animate = function(self)
        local fps = self.atlas.fps or 12
        local n = math.floor((G.TIMERS.REAL - start) * fps)
        local frame = anim.hold and math.min(n, FRAMES - 1) or (n % FRAMES)
        if self.current_animation then
            self.current_animation.current = frame
        end
        if self.sprite_pos.x ~= frame or self.sprite_pos.y ~= anim.row then
            self:set_sprite_pos({ x = frame, y = anim.row })
        end
    end

    s:set_sprite_pos({ x = 0, y = anim.row })
end

function Btraddon.marketplier()
    local atlas = G.ANIMATION_ATLAS['BtrSilly_Marketplier']
    if not atlas then
        return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {}}
    end

    Btraddon.sprite = AnimatedSprite(0, 0, 4.5, 3.6, atlas, { x = 0, y = get_anim().row })
    apply_state()

    return {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n = G.UIT.O, config = {object = Btraddon.sprite}}
    }}
end

--  base / nil / death
function Btraddon.set_markstate(state)
    if G.GAME.markstate == state then return end
    G.GAME.markstate = state
    apply_state()
end

-- behold the pliers
function Btraddon.show_marketplier()
    if Btraddon.menu then Btraddon.hide_marketplier() end
    Btraddon.menu = UIBox {
        definition = Btraddon.marketplier(),
        config = {
            align = "cr",
            offset = {x = -3, y = 0},
            major = G.ROOM_ATTACH,
            bond = 'Weak',
            instance_type = "POPUP"
        }
    }
end

-- hide away the pliers
function Btraddon.hide_marketplier()
    if Btraddon.menu then
        Btraddon.menu:remove()
        Btraddon.menu = nil
        Btraddon.sprite = nil
    end
end