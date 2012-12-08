# ...
# requirements
fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
fsu = require '../lib/fs-util'

# ...
# defining global watcher var
watcher = null
base_path = path.join __dirname, 'tmp-watcher'
fs.mkdirSync base_path, '0755'

# ...
# helper methods for tests #7 and #8
build_paths = ->
  ls = {}
  ls[location] = location for location in locations = [
    (path.join base_path, 'a/b/c/d/e/cinco.coffee'),
    (path.join base_path, 'a/b/c/d/e'),
    (path.join base_path, 'a/b/c/d/quatro.coffee'),
    (path.join base_path, 'a/b/c/d'),
    (path.join base_path, 'a/b/c/tres.coffee'),
    (path.join base_path, 'a/b/c'),
    (path.join base_path, 'a/b/dois.coffee'),
    (path.join base_path, 'a/b'),
    (path.join base_path, 'a/um.coffee'),
    (path.join base_path, 'a')
  ]
  ls.length = locations.length
  ls

create_structure = ()->
  # build dirs
  fs.mkdirSync dir for dir in [
    a = (path.join __dirname, 'a'),
    b = (path.join __dirname, 'a/b'),
    c = (path.join __dirname, 'a/b/c'),
    d = (path.join __dirname, 'a/b/c/d'),
    e = (path.join __dirname, 'a/b/c/d/e')
  ]

  # build files
  fs.writeFileSync file, '' for file in [
    (path.join a, 'um.coffee'),
    (path.join b, 'dois.coffee'),
    (path.join c, 'tres.coffee'),
    (path.join d, 'quatro.coffee'),
    (path.join e, 'cinco.coffee')
  ]

  # move structure into tmp dir
  exec "cd #{__dirname} && mv a #{base_path}"

delete_structure = ->
  exec "cd #{base_path} && rm -rf a"

describe '• FS Watcher', ->
  # ...
  # 1) watching dir
  describe 'When watching a directory tree', ->
    it 'the `watch` event should be emitted properly', (done)->

      watcher = fsu.watch base_path, /.coffee$/m, true
      watcher.once 'watch', (f)->
        f.location.should.equal base_path
        done()

  # ...
  # 2) creating dir
  describe 'When creating a dir inside that tree', ->
    it 'the `watch` and `create` event should be emitted properly', (done)->

      dirpath = path.resolve "#{base_path}/app"
      created = false

      # on dir creation, `create` event should come before the `watch` event
      watcher.once 'create', (f)->
        created = true
        f.location.should.equal dirpath

      watcher.once 'watch', (f)->
        created.should.equal true
        f.location.should.equal dirpath
        done()

      fs.mkdirSync dirpath

  # ...
  # 3) deleting dir
  describe 'When deleting this dir', ->

    it 'the `unwatch` and `delete` events should be emitted properly', (done)->

      dirpath = path.resolve "#{base_path}/app"
      unwatched = false

      # on dir deletion, `unwatch` event should come before the `delete` event
      watcher.once 'unwatch', (f)->
        unwatched = true
        f.location.should.equal dirpath

      watcher.once 'delete', (f)->
        unwatched.should.equal true
        f.location.should.equal dirpath
        done()

      fs.rmdirSync dirpath

  # ...
  # 4) creating file
  describe 'When creating a file inside the watched dir', ->

    it 'the `created` and `watch` events should be emitted properly', (done)->

      filepath = path.resolve "#{base_path}/file.coffee"
      created = false

      # on file creation, `create` event should come before the `watch` event
      watcher.once 'create', (f)->
        created = true
        f.location.should.equal filepath

      watcher.once 'watch', (f)->
        created.should.equal true
        f.location.should.equal filepath
        done()

      fs.writeFileSync filepath, 'first line\n', 'utf-8'

  # ...
  # 5) updating file
  describe 'When updating this file (a little delay needed here, pay no mind)', ->

    it 'the `change` event should be emitted properly', (done)->
      
      filepath = path.resolve "#{base_path}/file.coffee"
      watcher.once 'change', (f)->
        f.location.should.equal filepath
        done()

      # gives time to fs process the watching action before modifying the file
      # in order to provoke the 'change' event`
      setTimeout ->
        fs.appendFileSync filepath, 'second line\n', 'utf-8'
      , 1000

  # ...
  # 6) deleting file
  describe 'When deleting this file', ->

    it 'the `unwatch` and `delete` events should be emitted properly', (done)->

      filepath = path.resolve "#{base_path}/file.coffee"
      unwatched = false

      # on dir deletion, `unwatch` event should come before the `delete` event
      watcher.once 'unwatch', (f)->
        unwatched = true
        f.location.should.equal filepath

      watcher.once 'delete', (f)->
        unwatched.should.equal true
        f.location.should.equal filepath
        done()

      fs.unlinkSync filepath

  # ...
  # 7) Creating a dir with many sub fs (dirs and files)
  describe 'When moving an existent structure inside the watched tree', ->

    it 'the `create` and `watch` events should be emitted properly for all files and dirs', (done)->

      # paths for comparison
      ls = build_paths()
      created = 0
      watched = 0

      # setting up listeners
      watcher.on 'create', (f)->
        created++ if (f.location.should.equal ls[f.location])

      watcher.on 'watch', (f)->
        watched++ if (f.location.should.equal ls[f.location])
        if watched is ls.length and created is ls.length
          done()

      create_structure()

  # ...
  # 8) Deleting a dir with many sub fs (dirs and files)
  describe 'When deleting this structure', ->

    it 'the `delete` and `unwatch` events should be emitted properly for all files and dirs', (done)->
      
      ls = build_paths()
      unwatched = 0
      deleted = 0

      # setting up listeners
      watcher.on 'unwatch', (f)->
        unwatched++ if (f.location.should.equal ls[f.location])

      watcher.on 'delete', (f)->
        deleted++ if (f.location.should.equal ls[f.location])
        if unwatched is ls.length and deleted is ls.length
          done()

      delete_structure()