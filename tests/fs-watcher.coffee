# requirements
fs = require 'fs'
path = require 'path'
fsu = require '../lib/fs-util'

# reset tmp folder
base_path = path.resolve "#{__dirname}/tmp"
fs.rmdirSync base_path if fs.existsSync base_path
fs.mkdirSync base_path

watcher = null

# 1) watching folder
describe 'When watching a directory tree', ->

  it 'the `watch` event should be emitted properly', (done)->
    watcher = fsu.watch base_path, /.coffee$/m
    watcher.once 'watch', (f)->
      f.location.should.equal base_path
      done()

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

# 3) deleting folder
describe 'When deleting a folder inside that tree', ->

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

# 4) creating file
# -> TODO

# 5) updating file
# -> TODO

# 6) deleting file
# -> TODO

# 7) Creating a folder with many sub fs (folders and files)
# -> TODO

# 8) Deleting a folder with many sub fs (folders and files)
# -> TODO