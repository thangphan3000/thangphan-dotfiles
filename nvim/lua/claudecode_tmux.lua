local M = {}

local TMUX_PANE_FIELDS = {
  'session_name',
  'window_index',
  'pane_index',
  'pane_id',
  'pane_current_command',
  'window_name',
  'pane_title',
  'pane_pid',
}

local function get_visual_selection()
  local mode = vim.fn.mode()
  local p1, p2
  if mode == 'v' or mode == 'V' or mode == '\22' then
    p1 = vim.fn.getpos 'v'
    p2 = vim.fn.getpos '.'
  else
    p1 = vim.fn.getpos "'<"
    p2 = vim.fn.getpos "'>"
    mode = vim.fn.visualmode()
  end

  local lines = vim.fn.getregion(p1, p2, { type = mode })
  if #lines == 0 then
    return nil
  end

  return {
    text = table.concat(lines, '\n'),
    start_line = math.min(p1[2], p2[2]),
    end_line = math.max(p1[2], p2[2]),
    filetype = vim.bo.filetype,
    filepath = vim.fn.expand '%:~:.',
  }
end

local function build_proc_map()
  local map = {}
  for _, line in ipairs(vim.fn.systemlist 'ps -axo pid=,ppid=,comm=') do
    local pid, ppid, comm = line:match '^%s*(%d+)%s+(%d+)%s+(.+)$'
    if pid then
      map[pid] = { ppid = ppid, comm = comm }
    end
  end
  return map
end

local function is_descendant_of(proc_map, pid, ancestor_pid)
  local cur = pid
  while cur and proc_map[cur] do
    if cur == ancestor_pid then
      return true
    end
    cur = proc_map[cur].ppid
  end
  return false
end

local function pane_runs_claude(proc_map, pane_pid)
  if not pane_pid or pane_pid == '' then
    return false
  end
  for pid, info in pairs(proc_map) do
    if info.comm and info.comm:find 'claude' then
      if is_descendant_of(proc_map, pid, pane_pid) then
        return true
      end
    end
  end
  return false
end

local function build_tmux_format()
  local parts = {}
  for _, field in ipairs(TMUX_PANE_FIELDS) do
    parts[#parts + 1] = '#{' .. field .. '}'
  end
  return table.concat(parts, '|')
end

local function split_fields(line, count)
  local fields = {}
  local pos = 1
  for i = 1, count - 1 do
    local sep = line:find('|', pos, true)
    if not sep then
      return nil
    end
    fields[i] = line:sub(pos, sep - 1)
    pos = sep + 1
  end
  fields[count] = line:sub(pos)
  return fields
end

local function parse_pane(fields)
  return {
    session = fields[1],
    win_idx = fields[2],
    pane_idx = fields[3],
    pane_id = fields[4],
    cmd = fields[5],
    win_name = fields[6],
    pane_title = fields[7],
    pid = fields[8],
  }
end

-- Claude Code sets pane title to "Claude Code [session-name]"
local function make_pane_entry(pane)
  local cc_session = pane.pane_title and pane.pane_title:match '%[([^%]]+)%]$'
  local label = cc_session
    or (pane.win_name ~= '' and pane.win_name)
    or (pane.session .. ':' .. pane.win_idx .. '.' .. pane.pane_idx)

  return {
    pane_id = pane.pane_id,
    label = label,
    named = cc_session ~= nil,
    display = string.format('%-20s  (%s win:%s pane:%s)', label, pane.session, pane.win_idx, pane.pane_idx),
  }
end

local function find_claude_panes()
  local fmt = build_tmux_format()
  local raw = vim.fn.systemlist(string.format("tmux list-panes -a -F '%s'", fmt))
  local proc_map = build_proc_map()
  local panes = {}

  for _, line in ipairs(raw) do
    local fields = split_fields(line, #TMUX_PANE_FIELDS)
    if fields then
      local pane = parse_pane(fields)
      if pane_runs_claude(proc_map, pane.pid) then
        panes[#panes + 1] = make_pane_entry(pane)
      end
    end
  end

  table.sort(panes, function(a, b)
    if a.named ~= b.named then
      return a.named
    end
    return a.label < b.label
  end)

  return panes
end

local function send_to_pane(pane_id, content)
  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, 'w')
  if not f then
    vim.notify('[claudecode-tmux] failed to create temp file', vim.log.levels.ERROR)
    return
  end
  f:write(content)
  f:close()

  local esc_pane = vim.fn.shellescape(pane_id)
  vim.fn.system(string.format('tmux load-buffer -b _claude_ctx %s', vim.fn.shellescape(tmpfile)))
  vim.fn.system(string.format('tmux paste-buffer -b _claude_ctx -t %s', esc_pane))
  vim.fn.delete(tmpfile)
  vim.fn.system(string.format('tmux switch-client -t %s', esc_pane))
  vim.fn.system(string.format('tmux select-pane -t %s', esc_pane))
end

local function format_message(sel)
  local path = sel.filepath ~= '' and sel.filepath or '[unnamed]'
  return string.format('%s#L%d-%d', path, sel.start_line, sel.end_line)
end

function M.send_selection()
  local sel = get_visual_selection()
  if not sel or sel.text == '' then
    vim.notify('[claudecode-tmux] no selection', vim.log.levels.WARN)
    return
  end

  local panes = find_claude_panes()
  if #panes == 0 then
    vim.notify('[claudecode-tmux] no Claude Code panes found in tmux', vim.log.levels.WARN)
    return
  end

  local message = format_message(sel)

  if #panes == 1 then
    send_to_pane(panes[1].pane_id, message)
    return
  end

  vim.ui.select(
    vim.tbl_map(function(p)
      return p.display
    end, panes),
    { prompt = 'Send to Claude Code session:' },
    function(_, idx)
      if idx then
        send_to_pane(panes[idx].pane_id, message)
      end
    end
  )
end

return M
