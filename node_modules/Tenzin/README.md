Tenzin
=================

Academic calendar module for the RedAPI. Can be used to mine fresh info about Cornell's academic calendar.


	var academic_calendar = require('Tenzin');
	
	// Calling a year will return the academic calendar starting with that year
	// (In this case, 2014-15)
	academic_calendar.getJSON(2014)

		// Yay got the data
		.then(function (data) {...})
		
		// On noes, something went wrong!
		.catch(function (error) {...});


Note: this is the package officialy used at `http://api-mrkev.rhcloud.com/redapi/academic_calendar`. Check it out, tweak, suggest changes, post issues and enjoy!