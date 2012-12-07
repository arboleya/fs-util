Incremental utilities for NodeJS File System API.

[![Build Status](https://secure.travis-ci.org/serpentem/fs-util.png)](http://travis-ci.org/serpentem/fs-util)
> Version 0.2.0

# FS Watcher

Provides the ability to watch an entire _*tree*_ of `dirs` and `files`.

## Compatibility

* Linux
* MacOSX
* Windows

## Usage

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch [desired_path], [regex_filter], [recursive_notifications]
````

> `desired_path`

The path to the `dir` you wanna watch (ie. 'my/path'), `file` is not accept.

> `regex_filter`

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

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch 'desired/path', /.coffee$/m, true
watcher.on 'watch', (f)-> console.log 'WATCHED ' + [f.type, f.location]
watcher.on 'unwatch', (f)-> console.log 'UNWATCHED ' + [f.type, f.location]
watcher.on 'create', (f)-> console.log 'CREATED ' + [f.type, f.location]
watcher.on 'change', (f)-> console.log 'CHANGED ' + [f.type, f.location]
watcher.on 'delete', (f)-> console.log 'DELETED ' + [f.type, f.location]
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

# Installing

````bash
npm install fs-util
````

## Developing

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

* Current output:

````bash
 • FS Watcher
    When watching a directory tree
      ✓ the `watch` event should be emitted properly 
    When creating a dir inside that tree
      ✓ the `watch` and `create` event should be emitted properly 
    When deleting this dir
      ✓ the `unwatch` and `delete` events should be emitted properly 
    When creating a file inside the watched dir
      ✓ the `created` and `watch` events should be emitted properly 
    When updating this file (a little delay needed here, pay no mind)
      ✓ the `change` event should be emitted properly (1001ms)
    When deleting this file
      ✓ the `unwatch` and `delete` events should be emitted properly 
    When moving an existent structure inside the watched tree
      ✓ the `create` and `watch` events should be emitted properly for all files and dirs (85ms)
    When deleting this structure
      ✓ the `delete` and `unwatch` events should be emitted properly for all files and dirs 


  8 tests complete (1 seconds)
````

# TODO

List of **TODO** features besides the current `[FS Tree Watcher].watch`:

* `mkdir [-p]`
* `rm [-r] [-f]`
* `search`
* `cp [-r]`
* `mv`