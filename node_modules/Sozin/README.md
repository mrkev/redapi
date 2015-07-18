Sozin
=================

Exam scheldule module for the RedAPI. Can be used to mine fresh info about Cornell's exam scheldule.


	var exam_info = require('Sozin');
	
	// Will accept 'fall' / 'spring' terms, and 'prelim' / 'final' exam types.
	exam_info.getJSON('fall', 'prelim')

		// Yay got the data
		.then(function (data) {...})
		
		// On noes, something went wrong!
		.catch(function (error) {...});


Note: This mines the data from the links at `http://registrar.sas.cornell.edu/Sched/exams.html`, and thus only contains information for the current schoolyear.