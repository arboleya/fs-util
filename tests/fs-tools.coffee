# ...
# requirements
fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
fsu = require '../lib/fs-util'

# ...
# outputting version
version = fs.readFileSync (path.join __dirname, '../package.json'), 'utf-8'
console.log '\nCurrent version is: ' + (JSON.parse version).version

# ...
# defining global watcher var
base_path = path.join __dirname, 'tmp-tools'
fs.mkdirSync base_path, '0755'

describe '• FS Tools', ->
  # ...
  # 1) cerating new dir with `mkdir_p`
  describe 'When making a deep-dir structure', ->
    it 'the structure must to be created', ->
      fullpath = path.join base_path, 'created/a/b/c'
      fsu.mkdir_p fullpath
      (fs.existsSync fullpath).should.equal true

  # ...
  # 2) touching file
  describe 'When touching a file', ->
    it 'the file must be touched', ->
      fullpath = path.join base_path, 'created/a/b/c/tempfile.coffee'
      fsu.touch fullpath
      (fs.readFileSync fullpath).toString().should.equal ''

  # ...
  # 3) cp_r
  describe 'When copying a structure', ->
    it 'the structure must to be copied', ->
      from = path.join base_path, 'created'
      to = path.join base_path, 'copied'
      fsu.cp_r from, to
      filepath = path.join base_path, 'copied/a/b/c/tempfile.coffee'
      (fs.readFileSync filepath).toString().should.equal ''

  # ...
  # 4) finding with dirs
  describe 'When searching a file', ->
    it 'the search must to return the proper results', ->
      found = fsu.find path.join base_path, /.coffee$/m, true
      check = [
        a = (path.join base_path, 'created/a/b/c/tempfile.coffee'),
        b = (path.join base_path, 'copied/a/b/c/tempfile.coffee')
      ]
      (found[0] is a or found[0] is b).should.equal true
      (found[1] is a or found[1] is b).should.equal true

  # ...
  # 5) finding without dirs
  describe 'When searching a directory', ->
    it 'the search must to return the proper results', ->
      check = [
        a = (path.join base_path, 'created/a/b/c/tempfile.coffee'),
        b = (path.join base_path, 'copied/a/b/c/tempfile.coffee')
      ]
      found = fsu.find path.join base_path, /c*/m, false
      (found[0] is a or found[0] is b).should.equal true
      (found[1] is a or found[1] is b).should.equal true

  # ...
  # 5) updating file
  describe 'When listing a directory', ->
    it 'the list must to return the dir contents', ->
      fullpath = path.join base_path, 'copied'
      res = fsu.ls fullpath
      res.length.should.equal 1
      res[0].should.equal (path.join fullpath, 'a')

  # ...
  # 6) deleting file
  describe 'When removing a strucuture recursively', ->
    it 'the structure must to removed recursively', ->
      fullpath = path.join base_path, 'copied'
      fsu.rm_rf fullpath
      (fs.existsSync fullpath).should.equal false