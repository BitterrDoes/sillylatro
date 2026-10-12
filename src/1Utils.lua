G.C.UI.CONFIG_EMBOSS = HEX("4c5257")
function Btraddon.create_textbox(args)
    if not args then args = {} print("dumbass forgot to arg") end
    args.scale = args.scale or 1
    args.w = args.w or 6
    args.label = args.label or ''
    args.desc = args.desc or nil
    args.label_scale = args.label_scale or 1.5
    args.desc_scale = args.desc_scale or 1

    local descNodes = nil
    if args.desc ~= nil then
        local nodes = {}

        if type(args.desc) == "string" then
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cl", minw = args.w + .2 },
                    nodes = SMODS.localize_box(loc_parse_string(args.desc),
                        { scale = args.desc_scale, colour = G.C.BLACK, align = "cl" })

                },
            }
        else -- table or crash, your choice
            for _, string in pairs(args.desc) do
                table.insert(nodes,{
                    n = G.UIT.R,
                    config = { align = "cl", minw = args.w + .2 },
                    nodes = SMODS.localize_box(loc_parse_string(string), { scale = args.desc_scale, colour = G.C.BLACK, align = "cl" })
                })
            end 
        end

        descNodes = {
            n = G.UIT.R,
            config = { align = "cm", minw = args.w },
            nodes = nodes
        }
    end

    return {
        n = G.UIT.C,
        config = { align = "cm", minw = args.w },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", minw = args.w },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cl", minw = args.w + .2 },
                        nodes = SMODS.localize_box(loc_parse_string(args.label),
                            { scale = args.label_scale, colour = G.C.BLACK, align = "cl" })
                    },
                }
            },
            descNodes
        }
    }
end

function Btraddon.create_toggle_spec(args)
    args = args or {}
    args.active_colour = args.active_colour or G.C.RED
    args.inactive_colour = args.inactive_colour or G.C.BLACK
    args.w = args.w or 6
    args.h = args.h or 5
    args.scale = args.scale or 1
    args.label = args.label or ''
    args.desc = args.desc or nil
    args.label_scale = args.label_scale or 1.5
    args.desc_scale = args.desc_scale or 1
    args.ref_table = args.ref_table or {}
    args.ref_value = args.ref_value or 'test'

    local check = Sprite(0, 0, 0.5 * args.scale, 0.5 * args.scale, G.ASSET_ATLAS["icons"], { x = 1, y = 0 })
    check.states.drag.can = false
    check.states.visible = false

    local info = nil
    if args.info then
        info = {}
        for k, v in ipairs(args.info) do
            table.insert(info, {
                n = G.UIT.R,
                config = { align = "cm", minh = 0.05 },
                nodes = {
                    { n = G.UIT.T, config = { text = v, scale = 0.25, colour = G.C.UI.TEXT_LIGHT } }
                }
            })
        end
        info = { n = G.UIT.R, config = { align = "cm", minh = 0.05 }, nodes = info }
    end

    local t ={
        n = args.col and G.UIT.C or G.UIT.R,
        config = { align = "cm", r = .1, colour = G.C.UI.CONFIG_EMBOSS, emboss = 0.05, w = 100, focus_args = { funnel_from = true } },
        nodes = {{
            n = args.col and G.UIT.C or G.UIT.R,
            config = { align = "cl", padding = .1, focus_args = { funnel_from = true } },
            nodes = {
                -- textbox
                Btraddon.create_textbox(args),
                -- button
                {n = G.UIT.C, config = { align = "cr", minw = 0.3 * args.w },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "cr", r = 0.1, colour = G.C.BLACK },
                            nodes = {{
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    r = 0.1,
                                    padding = 0.03,
                                    minw = 0.4 * args.scale,
                                    minh = 0.4 * args.scale,
                                    outline_colour = G.C.WHITE,
                                    outline = 1.2 * args.scale,
                                    line_emboss = 0.5 * args.scale,
                                    ref_table = args,
                                    colour = args.inactive_colour,
                                    button = 'toggle_button',
                                    button_dist = 0.2,
                                    hover = true,
                                    toggle_callback = args.callback,
                                    func = 'toggle',
                                    focus_args = { funnel_to = true }
                                },
                                nodes = {
                                    { n = G.UIT.O, config = { object = check } },
                                }
                            }}
                        }
                    }
                },
            }
        }}
    }

    if args.info then
        t = {
            n = args.col and G.UIT.C or G.UIT.R,
            config = { align = "cm" },
            nodes = {
                t,
                info,
            }
        }
    end
    return t
end

function math.btr_clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end