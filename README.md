Incremental utilities for NodeJS File System API.

[![Build Status](https://secure.travis-ci.org/serpentem/fs-util.png)](http://travis-ci.org/serpentem/fs-util)

# FS Tree Watcher

Provides the ability to watch an entire _*tree*_ of `folders` and `files`.

* Events:
 * watch
 * unwatch
 * create
 * change
 * delete


## Usage

````coffeescript
fsu = require 'fs-util'
watcher = fsu.watch 'desired/path', /.coffee$/m
watcher.on 'watch', (f)-> console.log 'WATCHED ' + [f.type, f.location]
watcher.on 'unwatch', (f)-> console.log 'UNWATCHED ' + [f.type, f.location]
watcher.on 'create', (f)-> console.log 'CREATED ' + [f.type, f.location]
watcher.on 'change', (f)-> console.log 'CHANGED ' + [f.type, f.location]
watcher.on 'delete', (f)-> console.log 'DELETED ' + [f.type, f.location]
````

### Arguments

All callbacks receives one argument which is the related `item` to the event.

It has the following properties:

#### [item].location

Fullpath `location` of the item.

##### [item].type

Item `type`, can be `dir` or `file`.

##### [item].prev

Last stat of the file, it's an instance of [fs.Stats](http://nodejs.org/api/fs.html#fs_class_fs_stats).

##### [item].curr

Current stat of the file, it's an instance of [fs.Stats](http://nodejs.org/api/fs.html#fs_class_fs_stats).

##### [item].tree

The complete `tree` of subitems (`files` and `folders`) under that point.

* _Applies only when `item.type` is `folder`_

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

# TODO

List of **TODO** features besides the current `[FS Tree Watcher].watch`:

* `mkdir [-p]`
* `rm [-r] [-f]`
* `search`
* `cp [-r]`
* `mv`

**Note**: _There are also some tests to be finished and tested across different
platforms, such as Osx, Linux and Windows._