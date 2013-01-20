build:
	node_modules/coffee-script/bin/coffee -j lib/fs-util.js -c src/*.coffee

watch:
	node_modules/coffee-script/bin/coffee -wj lib/fs-util.js -c src/*.coffee

test.clean:
	rm -rf tests/tmp-* tests/a

bump.minor:
	node_modules/coffee-script/bin/coffee build/bumper.coffee --minor

bump.major:
	node_modules/coffee-script/bin/coffee build/bumper.coffee --major

bump.patch:
	node_modules/coffee-script/bin/coffee build/bumper.coffee --patch

test: test.clean build
	node_modules/mocha/bin/mocha tests/* \
		--compilers coffee:coffee-script \
		--require should --reporter spec

publish:
	git tag $(v)
	git push origin $(v)
	git push origin master
	npm publish

re-publish:
	git tag -d $(v)
	git tag $(v)
	git push origin :$(v)
	git push origin $(v)
	git push origin master -f
	npm publish -f