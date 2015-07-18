Katara [![Build Status](https://secure.travis-ci.org/mrkev/rorster.png?branch=master)](https://travis-ci.org/mrkev/generator-typescript)
=================


Roster module for the RedAPI. Can be used to fetch info about Cornell roster in general. Uses promises. They're awesome.


	var roster = require('katara')();
	
	roster.getJSON('CS', 'FA14').then(console.log, console.trace);
	
	// Note: Currently only FA14 is tested, though it *should* work with other terms. Info about issues apreciated.

Note: this is the package officialy used at `http://api-mrkev.rhcloud.com/redapi/roster`.

--------------

You can set optoins too:

	var roster = require('katara')({interval : 86400000, cache : object });
	
Interval : How many 