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
        elseif context.after and G.GAME.markstate ~= "death" then
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