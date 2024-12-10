local hook=require'ultimate-autopair.hook'
local utils=require'ultimate-autopair.utils'
local open_pair=require'ultimate-autopair.open_pair'

---@class ua.pair.hook
---@field [1] string
---@field [2] string
---@field [3] string
---@field start_insert_type 'empty'|'almost'|'full'|nil --default is 'almost'


local M={}
---@param callback fun(con:ua.context.pos):ua.actions?
local function create_pair_hook(callback,pair_hook,doc,fallback,priority)
    local mode,key=unpack(pair_hook)
    return hook.create_hook(callback,mode,key,doc,fallback,priority)
end
---@return string?,string,string,string
local function eval_pair(pair,other_pair,con,r)
    if type(pair)=='string' then
        if r==true then
            return other_pair,pair,other_pair,pair
        else
            return pair,other_pair,pair,other_pair
        end
    end
    local start_pair,end_pair,opts=pair(con)
    return start_pair,end_pair,opts and opts[1] or start_pair,opts and opts[2] or end_pair
end
---@param conf ua.iconfig._pair
---@return ua.hook[],ua.hook[],number,number
function M.init(conf)
    local start_pair_conf=conf._start_pair
    local end_pair_conf=conf._end_pair
    local start_pair=start_pair_conf._match
    local end_pair=end_pair_conf._match

    local start_hooks_conf=start_pair_conf._hooks
    local start_doc=('autopairs start pair: %s,%s'):format(start_pair,end_pair)
    local start_hooks={}
    local start_pair_p=type(start_pair)=='string' and #start_pair or math.huge
    for _,hook_conf in ipairs(start_hooks_conf) do
        local ins_type=hook_conf.insert_type
        table.insert(start_hooks,create_pair_hook(function (con)
            if start_pair_conf.multiline==false then
                con=utils.make_con_singleline(con)
            end
            if ins_type=='empty' then
                if type(start_pair)=='function' then
                    error('TODO: err at config merging')
                end
                assert(type(start_pair)=='string')
                error('TODO')
            elseif ins_type=='full' then
                local tcon=utils.conset(con,{forward=false})
                local match_start_pair,match_end_pair,true_start_pair,true_end_pair=eval_pair(start_pair,end_pair,tcon)
                if not match_start_pair then return end
                if not utils.endswith(con.line_pre,true_start_pair) then return end
                error('TODO')
            else
                local tcon=utils.conset(con,{forward=false,start_pair_ins=true})
                local match_start_pair,match_end_pair,true_start_pair,true_end_pair=eval_pair(start_pair,end_pair,tcon)
                if not match_start_pair then return end
                if not utils.endswith(con.line_pre,utils.utf8sub(true_start_pair,1,-2)) then return end
                local fn=function () return true end
                --TODO: be able to disable smart counting
                if match_start_pair==match_end_pair then
                    if open_pair.open_ambiguous_pairs(con.row,con.col,match_start_pair,con.source,fn,fn,{},'both') then
                        return
                    end
                else
                    local count1=open_pair.count_start_pair(con.row,con.col,match_start_pair,match_end_pair,con.source,fn,fn,{})
                    local count2=open_pair.count_end_pair(con.row,con.col,match_start_pair,match_end_pair,con.source,fn,fn,{})
                    if count1<count2 then return end
                end
                return {
                    utils.utf8sub(true_start_pair,-1),
                    true_end_pair,
                    {'h',true_end_pair},
                }
            end
        end,hook_conf,start_doc,start_pair_conf.fallback,start_pair_conf.priority))
    end

    local end_hooks_conf=end_pair_conf._hooks
    local end_doc=('autopairs end pair: %s,%s'):format(start_pair,end_pair)
    local end_hooks={}
    local end_pair_p=type(end_pair)=='string' and #end_pair or math.huge
    for _,hook_conf in ipairs(end_hooks_conf) do
        table.insert(end_hooks,create_pair_hook(function (con)
            if end_pair_conf.multiline==false then
                con=utils.make_con_singleline(con)
            end
            local tcon=utils.conset(con,{forward=true})
            local match_start_pair,match_end_pair,true_start_pair,true_end_pair=eval_pair(end_pair,start_pair,tcon,true)
            if not match_start_pair then return end
            if not utils.startwith(con.line_pos,true_end_pair) then return end
            local fn=function () return true end
            --TODO: be able to disable smart counting
            if match_start_pair==match_end_pair then
                --if there's an uneven number of ambiguous pairs or if were not in a pair
                local open_pair_before=open_pair.open_ambiguous_pairs(con.row,con.col,match_start_pair,con.source,fn,fn,{})
                if not open_pair_before then return end
                local open_pair_after=open_pair.open_ambiguous_pairs(con.row,con.col,match_start_pair,con.source,fn,fn,{},true,1)
                if open_pair_after then return end
            else
                local count1=open_pair.count_start_pair(con.row,con.col,match_start_pair,match_end_pair,con.source,fn,fn,{})
                local count2=open_pair.count_end_pair(con.row,con.col,match_start_pair,match_end_pair,con.source,fn,fn,{})
                if count1==0 or count1>count2 then return end
            end
            return {
                {'l',true_end_pair},
            }
        end,hook_conf,end_doc,end_pair_conf.fallback,end_pair_conf.priority))
    end
    return start_hooks,end_hooks,start_pair_p,end_pair_p
end
return M
