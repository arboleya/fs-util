Incremental utilities for NodeJS File System API.

[![Build Status](https://secure.travis-ci.org/serpentem/fs-util.png)](http://travis-ci.org/serpentem/fs-util)
> Version 0.3.3

## Compatibility

It just works.

* Linux
* MacOSX
* Windows

# Documentation

- [FS Watcher](#watcher)
- [FS Tools](#tools)

<a name="watcher"/>
# FS Watcher

Provides the ability to watch an entire _*tree*_ of `dirs` and `files`.

## Usage

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch [desired_path], [regex_pattern], [recursive_notifications]
````

> `desired_path`

The path to the `dir` you wanna watch (ie. 'my/path'), `file` is not accept.

> `regex_pattern`

The regex to filter only the files you wanna watch, i.e. `/.coffee$/m`.

> `recursive_notifications`

If `true` notifications will be fired for all files. If you delete a `dir`
that has many `sub dirs` and `files`, an `unwatch` and `delete` events will be 
ispatched for all the children `dirs` and `files` as well.

If `false`, only one event will be dispatched for the `dir` that was actually
deleted. It can save you an overhead of events popping up when a `dir` with
big ammount of `subdirs` and `files` is deleted.

## Events
 * watch
 * unwatch
 * create
 * change
 * delete

## Example

Bellow is a very basic usage example that can be found in the
[examples](https://github.com/serpentem/fs-util/tree/master/examples) folder.

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch 'desired/path', /.coffee$/m, true
watcher.on 'watch', (f)-> console.log 'WATCHED ' + [f.type, f.location]
watcher.on 'unwatch', (f)-> console.log 'UNWATCHED ' + [f.type, f.location]
watcher.on 'create', (f)-> console.log 'CREATED ' + [f.type, f.location]
watcher.on 'change', (f)-> console.log 'CHANGED ' + [f.type, f.location]
watcher.on 'delete', (f)-> console.log 'DELETED ' + [f.type, f.location]

watcher.close()
````

### Callback's argument

All callbacks receives only *one* argument which is the related `[f]ile` to
the event.

It has the following properties:

> [f].location

Fullpath `location` of the item.

>  [f].type

Item `type`, can be `dir` or `file`.

>  [f].prev

Last stat of the file, it's an instance of [fs.Stats](http://nodejs.org/api/fs.html#fs_class_fs_stats).

>  [f].curr

Current stat of the file, it's an instance of [fs.Stats](http://nodejs.org/api/fs.html#fs_class_fs_stats).

>  [f].tree

The complete `tree` of subitems (`files` and `dirs`) under that point.

* _Applies only when `f.type` is `dir`_

### Watcher's method

Besides all the Event Emiter inherited methods, the `watcher` class has one more:

> [watcher].close()

When called, this method will forcely close all persistent watcher's process and
removes all previously added listeners. Every file and folder is `unwatched`,
events will pop normally for them, and after that the instance becomes useless.

<a name="tools"/>
# FS Tools

Provides functionalities such as `rm_rf`, `cp_r`, `mkdir_p`, `find` and `ls`.

## Usage

````coffeescript
fsu = require 'fs-util'
fsu.mkdirp [dir_path]
fsu.touch [file_path], [encoding='utf-8']
fsu.copy [from_path], [to_path]
fsu.find [path], [regex_pattern], [include_dirs]
fsu.ls [path]
fsu.rm_rm [path]
````

> `*path`

Absolute or relative `paths` are accepted, you take care of your things.

> `encoding`

The `file` encoding when `touching` it.

> `regex_pattern`

Your search pattern, i.e. `/.coffee$/m`.

> `include_dirs`

When `true` will include the `dirs` in the search, otherwise only `files`.

# Installing

````bash
npm install fs-util
````

## Resolving dependencies

````bash
cd fs-util && npm install
````

### Building

````bash
make build
````

### Testing

````bash
make test
````