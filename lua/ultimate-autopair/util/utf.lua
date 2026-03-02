---@class ua.utf: userdata

local M={}

---@param s string
---@return ua.utf
function M.new(s)
  local data=newproxy(true)
  getmetatable(data)[1]=s
  return data
end

---@param u ua.utf
---@return string
function M.raw(u)
  return getmetatable(u)[1]
end

---@param u ua.utf
---@return number
function M.len(u)
  return vim.fn.strcharlen(M.raw(u))
end

---@param u ua.utf
---@param start integer
---@param finish integer?
---@return string
function M.sub(u,start,finish)
  start=(start>0 and start-1) or start
  if finish and finish~=-1 then
    finish=finish<0 and finish+1 or finish
    return vim.fn.slice(M.raw(u),start,finish)
  else
    return vim.fn.slice(M.raw(u),start)
  end
end

return M
