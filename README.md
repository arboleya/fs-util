# FsUtil

Incremental utilities for NodeJS File System API.

[![Build Status](https://secure.travis-ci.org/serpentem/fs-util.png)](http://travis-ci.org/serpentem/fs-util) [![Dependency Status](https://gemnasium.com/serpentem/fs-util.png)](https://gemnasium.com/serpentem/fs-util) [![NPM version](https://badge.fury.io/js/fs-util.png)](http://badge.fury.io/js/fs-util)

# Compatibility

* Linux
* MacOSX
* Windows

# Documentation

- [FS Watcher](#fs-watcher)
  - [Usage](#fs-watcher-usage)
  - [Events](#fs-watcher-events)
  - [Example](#fs-watcher-example)
      - [Callback](#fs-watcher-callback)
      - [Method](#fs-watcher-method)
- [FS Tools](#fs-tools)
  - [Usage](#fs-tools-usage)

# Setting up

- [Installing](#installing)
  - [Developing](#developing)
  - [Building](#building)
  - [Watching](#watching)
  - [Testing](#testing)

----
<a name="fs-watcher"/>
# FS Watcher

Provides the ability to watch an entire _*tree*_ of `dirs` and `files`.

<a name="fs-watcher-usage"/>
## Usage

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch [desired_path], [regex_pattern], [recursive_notifications]
````

> `desired_path`

The path to the `dir` or `file` you wanna watch.

> `regex_pattern`

The regex to filter only the files you wanna watch.

> `recursive_notifications`

If `true` notifications will be fired for all files. If you delete a `dir`
that has many `sub dirs` and `files`, an `unwatch` and `delete` events will be
dispatched for all the children `dirs` and `files` as well.

If `false`, only one event will be dispatched for the `dir` that was actually
deleted. It can save you an overhead of events popping up when a `dir` with
big ammount of `subdirs` and `files` is deleted.

<a name="fs-watcher-events"/>
## Events
 * watch
 * unwatch
 * create
 * change
 * delete

<a name="fs-watcher-example"/>
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

<a name="fs-watcher-callback"/>
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

<a name="fs-watcher-method"/>
### Watcher's method

Besides all the Event Emiter inherited methods, the `watcher` class has one more:

> [watcher].close()

When called, this method will forcely close all persistent watcher's process and
removes all previously added listeners. Every file and folder is `unwatched`,
events will pop normally for them, and after that the instance becomes useless.

----
<a name="fs-tools"/>
# FS Tools

Provides functionalities such as `rm_rf`, `cp_r`, `mkdir_p`, `find` and `ls`.

<a name="fs-tools-usage"/>
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

----
<a name="installing"/>
# Installing

Remembers that you need to install fs-util locally in order to use it as a LIB.
You will need to `require 'fs-util` in you script, there's no reason to install
it globally with `-g`, `fs-util` won't work directly in the command line.

At least for now.

````bash
npm install fs-util
````

<a name="developing"/>
## Developing

In order to contribute you will need to `fork`, `clone` and initialize the env.

````bash
git clone git@github.com:[username]/fs-util
cd fs-util && npm install
````

<a name="building"/>
### Building

Build the `src/*.coffee` files to `lib/*.js`.

````bash
make build
````

<a name="watching"/>
### Watching

Continuously building in `watch` mode.

````bash
make watch
````

<a name="testing"/>
### Testing

Running tests suite.

````bash
make test
````