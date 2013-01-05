path =  require 'path'
fs = require 'fs'

exports.touch = touch = (filepath, encoding='utf-8')->
  dir_to = path.dirname touch
  fs.writeFileSync filepath, '', encoding

exports.rm_rf = rm_rf = (folderpath, root=true)->
  files = fs.readdirSync (path.resolve folderpath)
  for file in files
    file = path.resolve "#{folderpath}/#{file}"
    stats = fs.statSync file
    if stats.isDirectory()
      rm_rf file, false
      fs.rmdirSync file
    else
      fs.unlinkSync file
  fs.rmdirSync folderpath if root

exports.mkdir_p = mkdir_p = (fullpath, mode='0755')->
  fullpath = path.resolve fullpath
  folders = fullpath.split path.sep
  folders[0] = '/' if folders[0] is ''

  for folder, index in folders

    folderpath = path.join.apply null, ( folders.slice 0, index + 1 )
    exists = fs.existsSync folderpath

    if exists and index is folders.length - 1
      throw new Error error( "Folder exists: #{folder.red}" )
      return false
    else if !exists
      fs.mkdirSync folderpath, mode

  return true

exports.cp_r = cp_r = (from, to)->

  from = path.resolve from
  to = path.resolve to

  from = (from.slice 0, -1)  if (from.slice -1) == '/'
  to = (to.slice 0, -1)  if (to.slice -1) == '/'

  return fs.writeFileSync to, (fs.readFileSync from) unless fs.statSync(from).isDirectory()
  
  for file_from in (files = find from, /.*/, false)
    file_to = file_from.replace from, to
    dir_to = path.dirname file_to

    mkdir_p dir_to unless fs.existsSync dir_to
    fs.writeFileSync file_to, (fs.readFileSync file_from)

exports.find = find = (folderpath, pattern, include_dirs=false)->

  found = []
  files = fs.readdirSync folderpath

  for file in files

    filepath = path.join folderpath, file
    if (fs.statSync filepath).isDirectory()
      if include_dirs and filepath.match pattern
        found = found.concat filepath
      found_under = find filepath, pattern, include_dirs
      found = found.concat found_under
    else
      found.push filepath if filepath.match pattern

  return found

exports.ls = ls = (folderpath)->
  found = []
  files = fs.readdirSync folderpath

  for file in files
    filepath = path.join folderpath, file
    found.push filepath if (fs.statSync filepath).isDirectory()

  return found