# dependencies
fs = require 'fs'
os = require 'os'
path = require 'path'
util = require 'util'
{EventEmitter} = require 'events'

# ...
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
    options = persistent: @watcher.persistent, interval: 250
    fs.watchFile @location, options, @onchange

    # win32 comes to say `HI` - as Windows always rise EPERM error when deleting
    # things, it's need to listen for an error and just suppress it. For more
    # info check: https://github.com/joyent/node/issues/4337
    if /^win/.test os.platform()
      @_ref.on 'error', -> 
    
    @watcher.emit 'watch', @

  unwatch:()->
    fs.unwatchFile @location, @onchange
    @watcher.emit 'unwatch', @

  onchange:()=>
    # skips change event when the file is deleted and itself is who's
    # dispatching it and not the parent dir (tricky)
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

# ...
# Watch dir for changes.
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
        for pattern in @watcher.patterns
          if pattern.test fullpath
            file = new FileWatcher @watcher, fullpath, @, @dispatch_created
            @tree[fullpath] = file
            break

    @watcher.emit 'create', @ if @dispatch_created

  watch:()->
    options = persistent: @watcher.persistent, interval: 250
    fs.watchFile @location, options, @onchange

    # win32 comes to say `HI` - as Windows always rise EPERM error when deleting
    # things, it's need to listen for an error and just suppress it. For more
    # info check: https://github.com/joyent/node/issues/4337
    if /^win/.test os.platform()
      @_ref.on 'error', -> 


    @watcher.emit 'watch', @

  unwatch:( propagate )->
    if propagate
      for location, item of @tree
        item.unwatch propagate 
    fs.unwatchFile @location
    @watcher.emit 'unwatch', @

  onchange:()=>
    # If dir is deleted
    unless fs.existsSync @location
      @prev = @curr
      @curr = null

      # if the deleted dir IS THE ROOT dir
      if @location is @watcher.root
        @delete()

      return

    # updating prev/curr stats
    @prev = @curr
    @curr = fs.statSync @location

    # getting a diff form the dir tree
    ls = @diff()

    # handling deleted files and dirs
    deleted.delete() for deleted in ls.deleted

    # handling created files and dirs
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
      isdir = (fs.statSync fullpath).isDirectory()

      for pattern in @watcher.patterns
        if isdir or pattern.test fullpath
          curr[fullpath] = fullpath
          break

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

  delete:( dispatch_event = true )->
    for location, item of @tree
      item.delete @watcher.recursive
    @unwatch()
    @parent.tree[@location] = null
    delete @parent.tree[@location]
    @watcher.emit 'delete', @ if dispatch_event

# Hybrid watcher, handle the watching process for dir and files under
# the given location according all passed options.
class Watcher extends EventEmitter

  constructor:(root, patterns, @recursive = false, @persistent = true)->
    @config root
    @patterns = [].concat (patterns or /.+/)

    # simple hack to allow user to listen for `watch` event even in the
    # initialization
    setTimeout =>
      @init()
    , 1

  config:( root )->
    @tree = {}
    @root = path.resolve root
    unless fs.existsSync @root
      throw new Error "Not found: #{@root}"

  init:()->
    if (fs.statSync @root).isDirectory()
      @tree[@root] = new DirWatcher @, @root, @
    else if (fs.statSync @root).isFile()
      @tree[@root] = new FileWatcher @, @root, @

  close:( )->

    item = @tree[@root]
    if item.type is 'dir'
      item.unwatch true
    else
      item.unwatch()

    @removeAllListeners 'create'
    @removeAllListeners 'watch'
    @removeAllListeners 'change'
    @removeAllListeners 'unwatch'
    @removeAllListeners 'delete'

# Single point exporting.
exports.watch = (root, patterns, recursive, persistent)->
  new Watcher root, patterns, recursive, persistent