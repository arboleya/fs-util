fsu = require '../../lib/fs-util'
watcher = fsu.watch 'src', /.coffee$/m, true

watcher.on 'watch', (f)-> console.log 'WATCHED ' + [f.type, f.location]
watcher.on 'unwatch', (f)-> console.log 'UNWATCHED ' + [f.type, f.location]
watcher.on 'create', (f)-> console.log 'CREATED ' + [f.type, f.location]
watcher.on 'change', (f)-> console.log 'CHANGED ' + [f.type, f.location]
watcher.on 'delete', (f)-> console.log 'DELETED ' + [f.type, f.location]