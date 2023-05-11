local M={}
function M.call(m,ext)
     local rule=m.rule
     m.rule=function ()
          if ext.conf.ft and not vim.tbl_contains(ext.conf.ft,vim.o.filetype) then
          elseif ext.conf.nft and vim.tbl_contains(ext.conf.nft,vim.o.filetype) then
          elseif m.conf.ft and not vim.tbl_contains(m.conf.ft,vim.o.filetype) then
          elseif m.conf.nft and vim.tbl_contains(m.conf.nft,vim.o.filetype) then
          else
               return rule()
          end
     end
end
return M
