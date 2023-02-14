local M={}
function M.setup(config)
    local mconfig=require'ultimate-autopair.config'
    mconfig.setup(config or {})
    mconfig.setup_extensions()
    require'ultimate-autopair.memory'.gen_filters()
    mconfig.create_mappings()
    require'ultimate-autopair.maps.bs'.setup()
    require'ultimate-autopair.maps.cr'.setup()
    require'ultimate-autopair.maps.sp'.setup()
    require'ultimate-autopair.maps.fastwarp'.setup()
    require'ultimate-autopair.maps.fastend'.setup()
end
return M
