local M={}
function M.get_map_wrapper(conf)
    return function(mode)
        if mode=='i' and conf.map then
            return {conf.map}
        elseif mode=='c' and conf.cmap then
            return {conf.cmap}
        end
    end
end
return M
