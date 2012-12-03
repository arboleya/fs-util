# ...
# requirements
fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
fsu = require '../src/fs-watcher'

# ...
# reset tmp folder
base_path = path.resolve "#{__dirname}/tmp"
fs.rmdirSync base_path if fs.existsSync base_path
fs.mkdirSync base_path

# ...
# defining global watcher var
watcher = null

# ...
# helper methods for tests #7 and #8
build_paths =->
  [
    (path.resolve "#{__dirname}/tmp/a/b/c/d/e/cinco.coffee"),
    (path.resolve "#{__dirname}/tmp/a/b/c/d/e"),
    (path.resolve "#{__dirname}/tmp/a/b/c/d/quatro.coffee"),
    (path.resolve "#{__dirname}/tmp/a/b/c/d"),
    (path.resolve "#{__dirname}/tmp/a/b/c/tres.coffee"),
    (path.resolve "#{__dirname}/tmp/a/b/c"),
    (path.resolve "#{__dirname}/tmp/a/b/dois.coffee"),
    (path.resolve "#{__dirname}/tmp/a/b"),
    (path.resolve "#{__dirname}/tmp/a/um.coffee"),
    (path.resolve "#{__dirname}/tmp/a")
  ]

create_structure = (after_create)->
  dirs = 'a/b/c/d/e'
  touches = "a/um.coffee
            a/b/dois.coffee
            a/b/c/tres.coffee
            a/b/c/d/quatro.coffee
            a/b/c/d/e/cinco.coffee"
  cmd = "cd #{__dirname} && mkdir -p #{dirs} && touch #{touches}"
  exec cmd, ()-> after_create()

move_structure =->
  from = path.resolve "#{__dirname}/a"
  to = path.resolve "#{__dirname}/tmp"
  exec "mv #{from} #{to}"

delete_structure =->
  dirpath = path.resolve "#{__dirname}/tmp/a"
  exec "rm -rf #{dirpath}"



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
describe 'When updating this (1000ms delay needed here, pay no mind)', ->

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

    # creating and moving the whole structure
    create_structure -> move_structure()

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

    # deleting the whole structure
    delete_structure()