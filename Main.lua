-- Note: press ctrl+k ctrl+0

-- variables
Btraddon = SMODS.current_mod

-- load addons
print("Sillylatro | Now loading")
for _, file in pairs(NFS.getDirectoryItems(Btraddon.path.. "/Addons")) do
    assert(SMODS.load_file("Addons/"..file, "btr_addons"))()
	print("Sillylatro | Loaded : ".. file)
end

-- configs | taken from a mod i dont remember
G.C.UI.CONFIG_EMBOSS = HEX("4c5257")
function create_toggle_spec(args)
    args = args or {}
    args.active_colour = args.active_colour or G.C.RED
    args.inactive_colour = args.inactive_colour or G.C.BLACK
    args.w = args.w or 6
    args.h = args.h or 5
    args.scale = args.scale or 1
    args.label = args.label or 'shake yo booty?'
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

    local tyesd = nil

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

        tyesd = {
            n = G.UIT.R,
            config = { align = "cm", minw = args.w },
            nodes = nodes
        }
    end

    local t =
    {
        n = args.col and G.UIT.C or G.UIT.R,
        config = { align = "cm", r = .1, colour = G.C.UI.CONFIG_EMBOSS, emboss = 0.05, w = 100, focus_args = { funnel_from = true } },
        nodes = {
            {
                n = args.col and G.UIT.C or G.UIT.R,
                config = { align = "cl", padding = .1, focus_args = { funnel_from = true } },
                nodes = {
                    {
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
                            tyesd
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cr", minw = 0.3 * args.w },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = "cr", r = 0.1, colour = G.C.BLACK },
                                nodes = {
                                    {
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
                                    },
                                }
                            }
                        }
                    },
                }
            },
        }
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

Btraddon.config_tab = function()
    return 
	{
		n = G.UIT.ROOT,
		config = { r = 0.1, minw = 10, align = 'cm', padding = 0.1, colour = G.C.BLACK },
		nodes = {
			{
				n = G.UIT.R,
				config = { r = 0.1, minw = 10, align = 'cl', padding = 0.1, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.T,
						config = {text="Cosmetic", colour = G.C.WHITE, scale=1, align = "tm"}
					},
					{
						n = G.UIT.C,
						config = { r = 0.1, minw = 10, align = 'bm', padding = 0.1, colour = G.C.BLACK },
						nodes = {
							create_toggle_spec({ -- Bltro
								label = "{C:white}Bltro",
								desc =
								"{C:inactive}Remove every occurrence of the letter 'a'.",
								ref_table = Btraddon.config,
								ref_value = "bltro"
							}),
							create_toggle_spec({ -- Jalatro
								label = "{C:white}Jalatro",
								desc =
								"{C:inactive}Every word starts with a J.",
								ref_table = Btraddon.config,
								ref_value = "jala"
							}),
							create_toggle_spec({ -- Letter sort
								label = "{C:white}Letter Sort",
								desc = {"{C:inactive}Every text has now been sorted a-z."},
								ref_table = Btraddon.config,
								ref_value = "sort"
							}),
							create_toggle_spec({ -- DVD
								label = "{C:white}DVD Balatro",
								desc = {"{C:inactive}haha dvd logo.", "{C:red,s:0.6}Can and probably will give a headache!"},
								ref_table = Btraddon.config,
								ref_value = "dvd"
							}),
							create_toggle_spec({ -- Market plier
								label = "{C:white}LIVE MARKIPLIER REACTION",
								desc = {"{C:inactive}your every move is being watched", "{C:inactive}by the market pliers"},
								ref_table = Btraddon.config,
								ref_value = "marketplier"
							}),
						}
					},
				}
			},
		}
    }
end

Btraddon.calculate = function(self, context)
    if Btraddon.config.marketplier and Btraddon.show_marketplier then
        if context.end_of_round and context.main_eval then
            if not context.game_over then
                Btraddon.set_markstate("blindwin")
            else
                Btraddon.set_markstate("death")
            end
        elseif context.press_play then
            Btraddon.set_markstate("prayge")
        elseif context.after and not G.GAME.markstate == "death" then
            G.E_MANAGER:add_event(Event({
                func = function()
                    Btraddon.set_markstate()
                    return true
                end
            }))
        elseif context.starting_shop then
            Btraddon.set_markstate()
        end
    end
end

if Btraddon.config.marketplier then
    local oldDel = Game.delete_run
    function Game.delete_run(self)
        Btraddon.hide_marketplier()
        oldDel(self)
    end
    local oldWin = win_game
    function win_game()
        Btraddon.set_markstate("win")
        oldWin()
    end
    
    local oldStart = Game.start_run
    function Game.start_run(...)
        Btraddon.show_marketplier()
        Btraddon.set_markstate()
        oldStart(...)
    end
end
