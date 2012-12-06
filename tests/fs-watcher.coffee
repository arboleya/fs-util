# ...
# requirements
fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
fsu = require '../src/fs-watcher'

# ...
# helper methods for tests #7 and #8
build_paths = ->
  [
    (path.join __dirname, 'tmp/a/b/c/d/e/cinco.coffee'),
    (path.join __dirname, 'tmp/a/b/c/d/e'),
    (path.join __dirname, 'tmp/a/b/c/d/quatro.coffee'),
    (path.join __dirname, 'tmp/a/b/c/d'),
    (path.join __dirname, 'tmp/a/b/c/tres.coffee'),
    (path.join __dirname, 'tmp/a/b/c'),
    (path.join __dirname, 'tmp/a/b/dois.coffee'),
    (path.join __dirname, 'tmp/a/b'),
    (path.join __dirname, 'tmp/a/um.coffee'),
    (path.join __dirname, 'tmp/a')
  ]

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

  # move structure into tmp folder
  exec "cd #{__dirname} && mv a tmp/"

delete_structure = ->
  dirpath = path.join __dirname, 'tmp'
  exec "cd #{dirpath} && rm -rf a"

# ...
# defining global watcher var
watcher = null
base_path = path.join __dirname, 'tmp'
fs.mkdirSync base_path


# ...
# 1) watching folder
describe 'When watching a directory tree', ->
  it 'the `watch` event should be emitted properly', (done)->

    watcher = fsu.watch base_path, /.coffee$/m, true
    watcher.once 'watch', (f)->
      f.location.should.equal base_path
      done()

# ...
# 2) creating folder
describe 'When creating a folder inside that tree', ->
  it 'the `watch` and `create` event should be emitted properly', (done)->

    dirpath = path.resolve "#{base_path}/app"
    created = false

    # on folder creation, `create` event should come before the `watch` event
    watcher.once 'create', (f)->
      created = true
      f.location.should.equal dirpath

    watcher.once 'watch', (f)->
      created.should.equal true
      f.location.should.equal dirpath
      done()

    fs.mkdirSync dirpath

# ...
# 3) deleting folder
describe 'When deleting this folder', ->

  it 'the `unwatch` and `delete` events should be emitted properly', (done)->

    dirpath = path.resolve "#{base_path}/app"
    unwatched = false

    # on folder deletion, `unwatch` event should come before the `delete` event
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
describe 'When creating a file inside the watched folder', ->

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
    # in order to provoke the 'change' event
    setTimeout ->
      fs.appendFileSync filepath, 'second line\n', 'utf-8'
    , 1000

# ...
# 6) deleting file
describe 'When deleting this file', ->

  it 'the `unwatch` and `delete` events should be emitted properly', (done)->

    filepath = path.resolve "#{base_path}/file.coffee"
    unwatched = false

    # on folder deletion, `unwatch` event should come before the `delete` event
    watcher.once 'unwatch', (f)->
      unwatched = true
      f.location.should.equal filepath

    watcher.once 'delete', (f)->
      unwatched.should.equal true
      f.location.should.equal filepath
      done()

    fs.unlinkSync filepath

# ...
# 7) Creating a folder with many sub fs (folders and files)
describe 'When moving an existent structure inside the watched tree', ->

  it 'the `create` and `watch` events should be emitted properly for all files and folders', (done)->

    # paths for comparison
    created_paths = build_paths()
    watched_paths = build_paths()

    # setting up listeners
    watcher.on 'create', (f)->
      f.location.should.equal created_paths.shift()

    watcher.on 'watch', (f)->
      f.location.should.equal watched_paths.shift()
      if watched_paths.length is 0
        watcher.removeAllListeners()
        done()

    create_structure()

# ...
# 8) Deleting a folder with many sub fs (folders and files)
describe 'When deleting this structure', ->

  it 'the `delete` and `unwatch` events should be emitted properly for all files and folders', (done)->
    
    # paths for comparison
    deleted_paths = build_paths()
    unwatched_paths = build_paths()

    # setting up listeners
    watcher.on 'unwatch', (f)->
      f.location.should.equal unwatched_paths.shift()

    watcher.on 'delete', (f)->
      f.location.should.equal deleted_paths.shift()
      if deleted_paths.length is 0
        watcher.removeAllListeners()
        done()

    delete_structure()