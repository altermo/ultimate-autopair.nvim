return {
    init=function (keyconf,mem)
        if keyconf.ft then
            mem[keyconf.ft]=true
        end
    end,
    filter=function (_,_,mem)
        if #mem>0 then
            if not mem[vim.o.filetype] then
                return 2
            end
        end
    end
}
