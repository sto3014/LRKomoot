---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dieterstockhausen.
--- DateTime: 05.05.21 19:19
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'

local logger = require("Logger")

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

local Utils = {}
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

function Utils.arraySize(array)
    local count = 0
    for _ in pairs(array) do count = count + 1 end
    return count
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

function Utils.startsWith(str, start)
    return str:sub(1, #start) == start
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

function Utils.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.copyfile(old_path, new_path)
    local old_file = io.open(old_path, "rb")
    local new_file = io.open(new_path, "wb")
    local old_file_sz, new_file_sz = 0, 0
    if not old_file or not new_file then
        return false
    end
    while true do
        local block = old_file:read(2^13)
        if not block then
            old_file_sz = old_file:seek( "end" )
            break
        end
        new_file:write(block)
    end
    old_file:close()
    new_file_sz = new_file:seek( "end" )
    new_file:close()
    return new_file_sz == old_file_sz
end

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

function Utils.getSessionFile(albumPath)
    return LrPathUtils.child(Utils.getComDir(albumPath), "session.txt")
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getPhotosFile(albumPath)
    return LrPathUtils.child(Utils.getComDir(albumPath), "photos.txt")
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getComDir(albumPath)
    local comDir = _G.TMP_DIR .. albumPath
    if (not LrFileUtils.exists(comDir)) then
        LrFileUtils.createAllDirectories(comDir)
    end
    return comDir
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getQueueEntryBaseName()
    return "queue-entry"
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getQueueDir()
    return _G.QUEUE_DIR
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getQueueEntry()
    return LrFileUtils.chooseUniqueFileName(LrPathUtils.child( Utils.getQueueEntryDir(), Utils.getQueueEntryBaseName()))
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.getQueueEntry()
    local queueDir = _G.TMP_DIR .. "/queue"
    if (not LrFileUtils.exists(queueDir)) then
        LrFileUtils.createAllDirectories(queueDir)
    end
    return queueDir .. "/queue-entry"
end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
--[[---------------------------------------------------------------------------

-----------------------------------------------------------------------------]]
function Utils.createQueueEntry(comment)
    local queueEntryPath = LrFileUtils.chooseUniqueFileName(Utils.getQueueEntry())
    local f = assert(io.open(queueEntryPath , "w"))
    f:write(comment)
    f:close()
    return LrPathUtils.leafName(queueEntryPath)
end
--[[---------------------------------------------------------------------------

-----------------------------------------------------------------------------]]
function Utils.waitForPredecessors(queueEntry)
    logger.trace("waitForPredecessors() start")
    logger.trace("queueEntry=" .. queueEntry)
    local done = false
    while done ~= true do
        local modDatesToQueueEntry = {}
        for currentQueueEntry in LrFileUtils.directoryEntries(Utils.getQueueDir()) do
            local leafName = LrPathUtils.leafName(currentQueueEntry)
            if (Utils.startsWith(leafName, Utils.getQueueEntryBaseName())) then
                logger.trace("leafName=" .. leafName)
                modDatesToQueueEntry[LrFileUtils.fileAttributes(currentQueueEntry).fileModificationDate] = leafName
            end
        end
        local modDates = {}
        for n in pairs(modDatesToQueueEntry) do
            table.insert(modDates, n)
        end
        table.sort(modDates)
        local entryToBeProcessed = modDatesToQueueEntry[modDates[1]]

        if (entryToBeProcessed == nil) then
            logger.trace("No entry found. Should only happen if user delete all files. Proceed processing.")
            done = true
        else
            logger.trace("entryToBeProcessed=" .. entryToBeProcessed)
            if (entryToBeProcessed == queueEntry) then
                logger.trace("Processing...")
                done = true
            else
                logger.trace("Waiting...")
                LrTasks.sleep(2)
            end
        end
    end
    logger.trace("waitForPredecessors() end")
end

--[[---------------------------------------------------------------------------
deleteQueueEntry()
-----------------------------------------------------------------------------]]
function Utils.deleteQueueEntry(queueEntry)
    logger.trace("delete queue-entry \"" .. queueEntry .. "\"")
    LrFileUtils.delete(LrPathUtils.child(Utils.getQueueDir(), queueEntry))
end
--[[---------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function Utils.split (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--[[---------------------------------------------------------------------------
getCatName()
-----------------------------------------------------------------------------]]
function Utils.getCatName ()
    local activeCatalog = LrApplication.activeCatalog()
    local catName = LrPathUtils.removeExtension(LrPathUtils.leafName(activeCatalog:getPath()))
    local i = string.find(catName, "-v")
    if (i ~= nil and i > 1) then
        catName = string.sub(catName, 1, i - 1)
    end
    return catName
end
return Utils