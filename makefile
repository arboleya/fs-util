build:
	node_modules/coffee-script/bin/coffee -j lib/fs-util.js -c src/*.coffee

test.clean:
	rm -rf tests/tmp

test: test.clean
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