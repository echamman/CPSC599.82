CPSC599.82 - Assignment #2
Brendan Petras Ethan Hamman Conlan Hanwell

Files Included:
duktape-1.5.1
locale
as2.c
as2.o
duk_config.h
duktape.c
duktape.h
Makefile
randy.js
ty.js
en_US.po
es.po
fr.po
de.po
README.txt

TO COMPILE
----------
In the Ass2 directory call 'make'

TO RUN
------
In the Ass2 directory call 'As2.o <javascript>'
where <javascript> is randy.js or ty.js


JAVASCRIPT
----------
The two AI files we wrote are randy.js and ty.js.
randy.js randomly selects valid positions.
ty.js attempts to tie the game always, even at the cost of a win.

DUKTAPE
-------
Standard duktape lib for having C and JS files communicate between each other.

LANG
----
The languages we chose are:
English - en_US
French - fr_FR
Spanish - es_ES
German - de_DE

The link to the program video can be found at:

<LINK>
