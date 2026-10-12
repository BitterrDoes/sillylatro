
Btraddon.config_tab = function()
    return 
	{
		n = G.UIT.ROOT,
		config = { r = 0.1, minw = 10, align = 'cm', padding = 0.1, colour = G.C.BLACK },
		nodes = {
			{
				n = G.UIT.R,
				config = { r = 0.1, maxw = 20, align = 'cm', padding = 0.1, colour = G.C.BLACK },
				nodes = {
					{
						n = G.UIT.C,
						config = { r = 0.1, minw = 7, align = 'cm', padding = 0.1, colour = G.C.BLACK },
						nodes = {
							Btraddon.create_toggle_spec({ -- Bltro
								label = "{C:white}Bltro",
								desc =
								"{C:inactive}Remove every occurrence of the letter 'a'.",
								ref_table = Btraddon.config,
								ref_value = "bltro"
							}),
							Btraddon.create_toggle_spec({ -- Jalatro
								label = "{C:white}Jalatro",
								desc =
								"{C:inactive}Every word starts with a J.",
								ref_table = Btraddon.config,
								ref_value = "jala"
							}),
							Btraddon.create_toggle_spec({ -- Letter sort
								label = "{C:white}Letter Sort",
								desc = {"{C:inactive}Every text has now been sorted a-z."},
								ref_table = Btraddon.config,
								ref_value = "sort"
							}),
							Btraddon.create_toggle_spec({ -- hehe
								label = "{C:white}Disable Mouse",
								desc = {"{C:inactive}Remove Mouse controls"},
								ref_table = Btraddon.config,
								ref_value = "link"
							}),
                        },
					},
                    {
                        n = G.UIT.C,
                        config = { r = 0.1, minw = 7, align = 'cm', padding = 0.1, colour = G.C.BLACK },
                        nodes = {
                            Btraddon.create_toggle_spec({ -- DVD
                                label = "{C:white}DVD Balatro",
                                desc = {"{C:inactive}haha dvd logo.", "{C:red,s:0.6}Can and probably will give a headache!"},
                                ref_table = Btraddon.config,
                                ref_value = "dvd"
                            }),
                            Btraddon.create_toggle_spec({ -- Market plier
                                label = "{C:white}LIVE MARKIPLIER REACTION",
                                desc = {"{C:inactive}your every move is being watched", "{C:inactive}by the market pliers"},
                                ref_table = Btraddon.config,
                                ref_value = "marketplier"
                            }),
                            Btraddon.create_toggle_spec({ -- Link
                                label = "{C:white}Link from legend of zelda",
                                desc = {"{C:inactive}Control link with wasd or arrow keys", "{C:inactive}attack with enter or x"},
                                ref_table = Btraddon.config,
                                ref_value = "link"
                            }),
                        }
                    },
				}
			},
            {
                n = G.UIT.R,
                config = {align = 'bm'},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {text = "Restart game after changes*", scale=.3, align = 'cm', colour = G.C.WHITE}
                    },
                },
            },
		}
    }
end

SMODS.Sound {
	key = "bear5scream",
	path = "bear5.mp3",
}
SMODS.Atlas {
	key = "bear5",
	path = "bear5.png",
    px = 1920,
    py = 1080
}

G.FUNCS.PlaySnake = function()
    Btraddon.currentGame = "snek"
    return true
end

SMODS.current_mod.extra_tabs = function()
    return {
        {
            label = localize("k_minigamesText"),
                -- it'll be funny after all text effects are on
            tab_definition_function = function()
                return
                {
                    n = G.UIT.ROOT, config = { r = 0.1, minw = 10, align = 'cm', padding = 0.1, colour = G.C.BLACK },
                    nodes = {{
                        n = G.UIT.R,
                        config = { r = 0.1, maxw = 20, align = 'cl', padding = 0.1, colour = G.C.BLACK },
                        nodes = {
                            -- game 1
                            {
                                n = G.UIT.R,
                                config = { align = "cm", r = .1, colour = G.C.UI.CONFIG_EMBOSS, emboss = 0.05, w = 10, focus_args = { funnel_from = true } },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { r = 0.1, minw = 4, align = 'cl', padding = 0.1 },
                                        nodes = {
                                            -- image
                                            {
                                                n = G.UIT.C,
                                                config = { r = 0.1, minw = 1.1, align = 'cl', no_overflow = true },
                                                nodes = {{
                                                    n = G.UIT.O,
                                                    config = {align = 'cm', object = Sprite(0,0,1,1, G.ASSET_ATLAS["BtrSilly_TestIcon"])},
                                                }}
                                            },
                                            -- text container
                                            Btraddon.create_textbox({
                                                label = "{C:white}Snek.io",
                                                desc = {"{C:inactive}Recreation of classic 'Snake' in love2d/balatro", "{C:inactive}'Escape' to quit out"},
                                            }),
                                            -- button
                                            UIBox_button({
                                                button = "PlaySnake",
                                                label = {"Play"},
                                                colour = G.C.GREEN,
                                                col = true,
                                                minw = 2,
                                            })
                                        }
                                    }
                                }
                            },
                        }}
                    }
                }
            end,
        },
        {
            label = "BEAR5",
                -- it'll be funny after all text effects are on
            tab_definition_function = function()
                bear5s = bear5s or {}
                local bear5 = Sprite(0,0,G.ROOM_ATTACH.T.w,G.ROOM_ATTACH.T.h, G.ASSET_ATLAS["BtrSilly_bear5"])
                table.insert(bear5s, UIBox{
                    definition = {n = G.UIT.O, config = {object = bear5}},
                    config = {
                        align = "cm",
                        offset = {x = 0, y = 0},
                        major = G.ROOM_ATTACH,
                        bond = 'Weak',
                        instance_type = "POPUP"
                    }
                })
                play_sound("BtrSilly_bear5scream", 1, 0.3)
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 1.024,
                    blockable = false,
                    func = function()
                        if bear5s[1] then
                            bear5s[1]:remove()
                            bear5s[1] = nil
                            return true
                        end
                    end
                }))
                SMODS.LAST_SELECTED_MOD_TAB = "mod_desc"
                G.FUNCS["openModUI_btr_addons"]()
                return {}
            end,
        },
    }
end