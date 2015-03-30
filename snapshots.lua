local originalNewSnapshot = display.newSnapshot
local snapshotsStore = {}
display.newSnapshot = function( w, h )
  local snapshot = originalNewSnapshot( w, h )
  
  snapshotsStore[ #snapshotsStore + 1 ] = snapshot 
  return snapshot
end

local onSystemEvent = function( event )
  if event.type == "applicationResume" then
    local removes = {}
    for i,snapshot in pairs(snapshotsStore) do
      if snapshot and snapshot.invalidate then
        snapshot:invalidate()
      elseif not snapshot or not snapshot.invalidate then
        removes[#removes+1] = i
      end
    end
    for i=#removes,1,-1 do
      local s = removes[i]
      if snapshotsStore[s] then
        if snapshotsStore[s].removeSelf then
          snapshotsStore[s]:removeSelf()
        end
        snapshotsStore[s] = nil
      end
      table.remove(snapshotsStore,s)
    end
  end
end
Runtime:addEventListener( "system", onSystemEvent )