
.SUFFIXES: .coffee .js

.coffee.js:
	coffee -cb $<

SRC=cowbuilder.coffee moo_party.coffee
JS=$(SRC:.coffee=.js)


website: js
	( [ -d ../js ] || mkdir ../js/ ) 
	cp $(JS) ../js/
	cp ../js_lib/jquery-3.2.1.slim.min.js ../js
	cp ../js_lib/lz-string.min.js ../js

js: $(JS)

clean:
	rm *.js
	rm -rf ../js/

test:
	(cat cowbuilder.coffee cowtest.coffee | coffee -s)



