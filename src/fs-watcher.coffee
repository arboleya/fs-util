# dependencies
fs = require 'fs'
os = require 'os'
path = require 'path'
util = require 'util'
{EventEmitter} = require 'events'

# Alternative approach for `fs.watch` used or watching folder under win32
# platform, for more info check: https://github.com/joyent/node/issues/4337
class Win32FolderWatcher

  prev: null
  curr: null
  interval: null

  constructor:( @location, @listener, @interval = 30 )->
    @curr = fs.statSync @location
    @interval_id = setInterval @check, 30

  check:=>
    return @listener() unless fs.existsSync @location
    @prev = @curr
    @curr = fs.statSync @location
    for k, v of @curr
      if @prev[k] isnt v
        return @listener()

  close:->
    clearInterval @interval_id


# Watch files for changes.
class FileWatcher

  constructor:(@watcher, @location, @parent, @dispatch_created = false)->
    @config()
    @init()
    @watch()

  config:()->
    @type = 'file'
    @curr = fs.statSync @location

  init:->
    @watcher.emit 'create', @ if @dispatch_created

  watch:()->
    options = persistent: @watcher.persistent
    @_ref = fs.watch @location, options, @onchange
    @watcher.emit 'watch', @

  unwatch:()->
    @_ref.close()
    @watcher.emit 'unwatch', @

  onchange:()=>
    # skips change event when the file is deleted and itself is who's
    # dispatching it and not the parent folder (tricky)
    unless fs.existsSync @location
      @prev = @curr
      @curr = null
      return    
    
    @prev = @curr
    @curr = fs.statSync @location

    if @curr.mtime > @prev.mtime
      @watcher.emit 'change', @

  delete:->
    @unwatch()
    @parent.tree[@location] = null
    delete @parent.tree[@location]
    @watcher.emit 'delete', @


# Watch folder for changes.
class DirWatcher

  constructor:(@watcher, @location, @parent, @dispatch_created = false)->
    @config()
    @init()
    @watch()

  config:()->
    @type = 'dir'
    @tree = {}
    @curr = fs.statSync @location

  init:()->
    for name in (fs.readdirSync @location)
      fullpath = path.resolve "#{@location}/#{name}"
      if fs.statSync( fullpath ).isDirectory()
        dir = new DirWatcher @watcher, fullpath, @, @dispatch_created
        @tree[fullpath] = dir
      else if fs.statSync( fullpath ).isFile()
        continue unless @watcher.pattern.test fullpath
        file = new FileWatcher @watcher, fullpath, @, @dispatch_created
        @tree[fullpath] = file

    @watcher.emit 'create', @ if @dispatch_created

  watch:()->
    # win32 comes to say `HI`
    if os.platform() is 'win32'
      @_ref = new Win32FolderWatcher @location, @onchange
    else
      options = persistent: @watcher.persistent
      @_ref = fs.watch @location, options, @onchange

    @watcher.emit 'watch', @

  unwatch:()->
    @_ref.close()
    @watcher.emit 'unwatch', @

  onchange:()=>
    # skips change event when the folder is deleted and itself is who's
    # dispatching it and not the parent folder (tricky)
    unless fs.existsSync @location
      @prev = @curr
      @curr = null
      return

    # updating prev/curr stats
    @prev = @curr
    @curr = fs.statSync @location

    # getting a diff form the folder tree
    ls = @diff()

    # handling deleted files and folders
    deleted.delete() for deleted in ls.deleted

    # handling created files and folders
    for created in ls.created
      if fs.statSync( created ).isDirectory()
        @tree[created] = new DirWatcher @watcher, created, @, true
      else if fs.statSync( created ).isFile()
        @tree[created] = new FileWatcher @watcher, created, @, true

  diff:->
    prev = @tree
    curr = {}

    for name in (fs.readdirSync @location)
      fullpath = path.resolve "#{@location}/#{name}"
      curr[fullpath] = fullpath

    status = deleted: [], created: []

    # find created ones
    for k, v of curr
      unless prev[k]?
        status.created.push v

    # find deleted ones
    for k, v of prev
      unless curr[k]?
        status.deleted.push v

    return status

  delete:->
    item.delete() for location, item of @tree if @watcher.recursive
    @unwatch()
    @parent.tree[@location] = null
    delete @parent.tree[@location]
    @watcher.emit 'delete', @

# Hybrid watcher, handle the watching process for folder and files under
# the given location according all passed options.
class Watcher extends EventEmitter

  constructor:(root, @pattern, @persistent = true, @recursive = false)->
    @config root

    # simple hack to allow user to listen for `watch` event even in the
    # initialization
    setTimeout =>
      @init()
    , 1

  config:( root )->
    @root = path.resolve root
    unless fs.existsSync @root
      throw new Error "Not found: #{@root}"

  init:()->
    @tree = new DirWatcher @, @root, @

# Single point exporting.
exports.watch = (root, pattern, persistent, recursive)->
  new Watcher root, pattern, persistent, recursive