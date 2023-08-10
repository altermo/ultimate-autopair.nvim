---FI
local M={}
local utils=require'ultimate-autopair.utils'
M.fn={
    preset={
        --initializes and takes no arg, like default.init_fns
        in_macro=function () end,
        in_tsnode=function () end,
        in_string=function () end,
        in_check=function () end,
        is_end_pair=function () end,
        is_start_pair=function () end,
        is_ambigous_pair=function () end,
        get_node=function () end,
    },
    utils={
        getmode=utils.getmode,
        gettsnode=utils.gettsnode,
        getsmartft=utils.getsmartft,
        getcmdtype=utils.getcmdtype,
    },
    _utils={
        _getlinenr=utils.getlinenr,
        _getcol=utils.getcol,
        _getline=utils.getline,
        _getlines=utils._getlines,
        _getlinecount=utils._getlinecount,
        _get_o_pos=utils._get_o_pos,
        _filter_pos=utils._filter_pos,
    },
    ---@param o core.o
    o=function (o) return o end
}
return M
