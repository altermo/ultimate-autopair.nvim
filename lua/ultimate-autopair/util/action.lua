---@class ua.actions: TODO

local keys={
    key_bs=vim.keycode'<bs>',
    key_del=vim.keycode'<del>',
    key_left=vim.keycode'<left>',
    key_right=vim.keycode'<right>',
    key_end=vim.keycode'<end>',
    key_home=vim.keycode'<home>',
    key_up=vim.keycode'<up>',
    key_down=vim.keycode'<down>',
    key_noundo=vim.keycode'<C-g>U',
    key_i_ctrl_o=vim.keycode'<C-\\><C-o>',
}

---@param action ua.actions
---@return string
return function(action)
  local out={}

  local mode=vim.fn.mode()
  local key_left,key_right
  if mode=='i' or mode=='R' then
    key_left=keys.key_noundo..keys.key_left
    key_right=keys.key_noundo..keys.key_right
  else
    key_left=keys.key_left
    key_right=keys.key_right
  end

  for _,act in ipairs(action) do
    if type(act)=='string' then
      table.insert(out,act)
    elseif act[1]=='h' then
      table.insert(out,key_left:rep(act[2]))
    elseif act[1]=='l' then
      table.insert(out,key_right:rep(act[2]))
    elseif act[1]=='delete' then
      if act[2] then
          table.insert(out,keys.key_bs:rep(act[2]))
      end
      if act[3] then
          table.insert(out,keys.key_del:rep(act[3]))
      end
    else
      error'TODO'
    end
  end

  return table.concat(out,'')
end
