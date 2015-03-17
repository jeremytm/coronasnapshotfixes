--[[
  Flattens nested display objects and groups into a single display group
  Use: flattenGroup( tallGroup )
  tallGroup should be a group, and will now be flat
--]]
local function flattenGroup( group, flatGroup, sentProps )
  
  -- Make sure original object sent here is a group
  if type( group.numChildren ) == "number" and type( group.insert ) == "function" then
    
    -- Create flat group
    local createdFlatGroup = false
    if not flatGroup then
      createdFlatGroup = true
      flatGroup=display.newGroup()
    end
    
    --if true then return end
    while group.numChildren > 0 do
      
      -- Is this a nested group?
      if type( group[1].numChildren ) == "number" and type( group[1].insert ) == "function" then
        
        local props
        if sentProps ~= nil then
          -- Update properties
          props = {
            rotation = sentProps.rotation + group[1].rotation,
            alpha = sentProps.alpha * group[1].alpha,
            xScale = sentProps.xScale * group[1].xScale,
            yScale = sentProps.yScale * group[1].yScale,
          }
        else
          -- Save properties
          props = {
            rotation = group[1].rotation,
            alpha = group[1].alpha,
            xScale = group[1].xScale,
            yScale = group[1].yScale,
          }
        end
        
        -- Simplify this group
        flattenGroup( group[1], flatGroup, props)
        
        -- Remove the empty subgroup
        group[1]:removeSelf()
      
      -- Else if this is a display object
      else
        
        -- Save anchors (When not 0.5, they get ignored by localToContent)
        local originalAnchorX = group[1].anchorX
        local originalAnchorY = group[1].anchorY
        group[1].anchorX = 0.5
        group[1].anchorY = 0.5
        
        -- Save positioning
        local cx,cy = group[1]:localToContent(0,0)
        
        -- Restore position within flat group
        group[1].x,group[1].y = flatGroup:contentToLocal(cx,cy)
        
        -- Restore anchors
        group[1].anchorX = originalAnchorX
        group[1].anchorY = originalAnchorY
        
        -- Restore rotations, alpha, etc.
        if sentProps ~= nil and sentProps.rotation ~= nil then
          group[1].rotation = sentProps.rotation + group[1].rotation
          group[1].alpha = sentProps.alpha * group[1].alpha
          group[1].xScale = sentProps.xScale * group[1].xScale
          group[1].yScale = sentProps.yScale * group[1].yScale
        end
        
        -- Insert into simple group
        flatGroup:insert(group[1])
        
      end
      
    end
    
    -- Only do this in the top level where the original flatGroup was created
    if createdFlatGroup then
      -- Transfer back to original group
      -- So we don't lose it and can manipulate it after creating the snap
      while flatGroup.numChildren > 0 do
        group:insert(flatGroup[1])
      end
      flatGroup:removeSelf()
    end
    
  end
  
  return group
  
end

local originalNewSnapshot = display.newSnapshot
local snapshotsStore = {}
display.newSnapshot = function( w, h )
  local snapshot = originalNewSnapshot( w, h ) 
  
  local originalInsert = snapshot.group.insert
  snapshot.group.insert = function( parent, obj )
    flattenGroup(obj)
    originalInsert( parent, obj )
  end
  
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