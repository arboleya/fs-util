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
      fullpath = path.join base_path, 'created/a/tempfile.coffee'
      fsu.touch fullpath
      (fs.readFileSync fullpath).toString().should.equal ''

  # ...
  # 3) cp_r
  describe 'When copying a structure', ->
    it 'the structure must to be copied', ->
      from = path.join base_path, 'created'
      to = path.join base_path, 'copied'
      fsu.cp_r from, to
      filepath = path.join base_path, 'copied/a/tempfile.coffee'
      (fs.existsSync filepath).should.equal true
      (fs.statSync filepath).isFile().should.equal true
      (fs.readFileSync filepath).toString().should.equal ''

  # 4) cp
  describe 'When copying a single file', ->
    it 'the file must to be copied', ->
      from = path.join base_path, 'created/a/tempfile.coffee'
      to = path.join base_path, 'created/a/tempfile-copy.coffee'
      fsu.cp from, to
      filepath = path.join base_path, 'created/a/tempfile-copy.coffee'
      (fs.existsSync filepath).should.equal true
      (fs.statSync filepath).isFile().should.equal true
      (fs.readFileSync filepath).toString().should.equal ''

  # ...
  # 5) finding with dirs
  describe 'When searching a file', ->
    it 'the search must to return the proper results', ->
      found = fsu.find (path.join base_path), /tempfile.coffee$/m, true
      check = [
        a = (path.join base_path, 'created/a/tempfile.coffee'),
        b = (path.join base_path, 'copied/a/tempfile.coffee')
      ]
      (found[0] is a or found[0] is b).should.equal true
      (found[1] is a or found[1] is b).should.equal true

  # ...
  # 6) finding without dirs
  describe 'When searching a directory', ->
    it 'the search must to return the proper results', ->
      check = [
        a = (path.join base_path, 'created/a/tempfile.coffee'),
        b = (path.join base_path, 'copied/a/tempfile.coffee')
      ]
      found = fsu.find (path.join base_path), /tempfile.coffee/m, false
      (found[0] is a or found[0] is b).should.equal true
      (found[1] is a or found[1] is b).should.equal true

  # ...
  # 7) updating file
  describe 'When listing a directory', ->
    it 'the list must to return the dir contents', ->
      fullpath = path.join base_path, 'created/a'
      res = fsu.ls fullpath
      res.length.should.equal 3

  # ...
  # 8) deleting file
  describe 'When removing a strucuture recursively', ->
    it 'the structure must to removed recursively', ->
      fullpath = path.join base_path, 'copied'
      fsu.rm_rf fullpath
      (fs.existsSync fullpath).should.equal false
