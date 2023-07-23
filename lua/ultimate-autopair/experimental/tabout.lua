local M={}
M.I={}
local default=require'ultimate-autopair.configs.default.utils'
local utils=require'ultimate-autopair.utils'
function M.I.tbl_find(tbl,pair_end)
    for k,v in ipairs(tbl) do
        if v.start_pair==pair_end.start_pair then
            return k
        end
    end
end
function M.gettabout(o,col)
    local stack={}
    local i=col+1
    while i<=#o.line do
        local pair_start=default.start_pair(i,o,true)
        local pair_end=default.end_pair(i,o)
        if pair_start then
            table.insert(stack,1,pair_start)
            i=i+#pair_start.pair
        elseif pair_end then
            local k=M.I.tbl_find(stack,pair_end)
            if k then table.remove(stack,k)
            i=i+#pair_end.pair
            else return i end
        else
            i=i+1
        end
    end
end
function M.tabout(o,col)
    local ret=M.gettabout(o,col)
    if ret then return utils.movel(ret-col) end
end
function M.wrapp_tabout(_)
    return function (o)
        return M.tabout(o,o.col)
    end
end
function M.init(conf,mconf,ext)
    if conf.enable==false then return end
    local m={}
    m.iconf=conf
    m.conf=conf.conf or {}
    m.map=mconf.map~=false and conf.map
    m.cmap=mconf.cmap~=false and conf.cmap
    m.p=conf.p or 10
    m.extensions=ext
    m[default.type_pair]={'tabout'}
    m.check=M.wrapp_tabout(m)
    m.get_map=default.get_mode_map_wrapper(m.map,m.cmap)
    m.rule=function () return true end
    m.filter=function() return true end
    default.init_extensions(m,m.extensions)
    default.init_check_map(m)
    m.doc='autopairs tabout key map'
    return m
end
function M.setup()
    local config=require'ultimate-autopair.config'
    config.add_conf({config_type='raw',M.init({
        map='<A-tab>',
    },{},{})})
    config.init()
end
return M
