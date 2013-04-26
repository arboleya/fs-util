.PHONY: build

CS=node_modules/coffee-script/bin/coffee
VERSION=`$(CS) build/bumper.coffee --version`

setup:
	npm install


build:
	$(CS) -j lib/fs-util.js -c src/*.coffee

watch:
	$(CS) -wj lib/fs-util.js -c src/*.coffee


test.clean:
	rm -rf tests/tmp-* tests/a

test: test.clean build
	node_modules/mocha/bin/mocha tests/* \
		--compilers coffee:coffee-script \
		--require should --reporter spec


bump.minor:
	$(CS) build/bumper.coffee --minor

bump.major:
	$(CS) build/bumper.coffee --major

bump.patch:
	$(CS) build/bumper.coffee --patch


publish:
	git tag $(VERSION)
	git push origin $(VERSION)
	git push origin master
	npm publish

re-publish:
	git tag -d $(VERSION)
	git tag $(VERSION)
	git push origin :$(VERSION)
	git push origin $(VERSION)
	git push origin master -f
	npm publish -f