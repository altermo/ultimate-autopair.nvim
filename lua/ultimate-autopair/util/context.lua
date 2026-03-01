local M={}

---@param iconf ua.iconfig
---@return ua.context
function M.create_context(iconf)
  local _=iconf
  local bufnr=vim.api.nvim_get_current_buf()
  local row=vim.fn.line('.')
  local col=vim.fn.col('.')
  return {
    cursor_range={row-1,col-1,row-1,col-1},
    iter_lines=function (s,e)
      return coroutine.wrap(function ()
        if s<0 then
          s=s+1+vim.api.nvim_buf_line_count(bufnr)
        end
        if e<0 then
          e=e+1+vim.api.nvim_buf_line_count(bufnr)
        end
        for rows=s,e,(s<e and 1 or -1) do
          coroutine.yield(rows,vim.api.nvim_buf_get_lines(bufnr,rows-1,rows,false)[1])
        end
      end)
    end,
  }
end

---@param con ua.context
---@param range Range4
---@return string
function M.line_after_range(con,range)
    return select(2,con.iter_lines(range[3]+1,range[3]+1)()) --[[@as string]]:sub(range[4]+1)
end
---@param con ua.context
---@param range Range4
---@return string
function M.line_before_range(con,range)
    return select(2,con.iter_lines(range[1]+1,range[1]+1)()) --[[@as string]]:sub(1,range[2])
end


return M
