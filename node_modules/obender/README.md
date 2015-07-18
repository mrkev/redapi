
Obender [![Build Status](https://secure.travis-ci.org/mrkev/obender.png?branch=master)](https://travis-ci.org/mrkev/obender)
===============

Obender is an object bender

	('')  .^.  ('')		
	 \ ' ('_') ' /		 ____  ____  _____ _      ____  _____ ____
	   \       / 		/  _ \/  _ \/  __// \  /|/  _ \/  __//  __\
	    l . . l			| / \|| | //|  \  | |\ ||| | \||  \  |  \/|
	    I . . I			| \_/|| |_\\|  /_ | | \||| |_/||  /_ |    /
	   /./---\.\		\____/\____/\____\\_/  \|\____/\____\\_/\_\
	  ///     \\\		


## Cool stuff with obender. Remaping.

You've been there. You get some json from the server in eww state and you 
'litteraly can't even'. 

	
	var remap  = require('obender').remap;
	
	var object = {			
		'Queue Name'	: 'wsh1',					// < Umm spaces on names sux
		'Printer Name'	: 'WSH Browsing Library 1',	//   cuz we can't be like
		'Printer Model'	: 'Xerox Phaser 4510DT',	//   object.printer_model /:
		'Color'			: 'B/W',					// < Should be a boolean tho
		'DPI'			: '600',					// < Ugh... strings smh
		'Duplex'		: 'Two-sided',				// < Could be a boolean too.
		'¢/Pg'			 : '9'					 	 // < '¢/Pg'? ru kidding me?
	}

	// 
	// ^--- Eww. What the hell is up with this data.
	// 
		

So you're all like 'ugh' and then you use obender.
	
	remap(
		{'Queue Name'	 :  'queue_name',
		 'Printer Name'	 :  'printer_name',
		 'Printer Model' :  'printer_model',
		 'DPI'			 :  'dpi',
		 'Color'		 : {'color'  : function (value) { 
		 									return value === 'Color'; } },
		 'Duplex'		 : {'duplex' : function (value) { 
		 									return value === "Two-sided"; } },
		 '¢/Pg'		  : {'price_per_page' : function (value) { 
		 									return parseFloat(value) / 100; } }
		}, object);	   

		// Object will be nice now wyayayya party.

And your object is nice. BAM.

	console.dir(object);

	// >> { queue_name: 'wsh1',
	//      printer_name: 'WSH Browsing Library 1',
	//      printer_model: 'Xerox Phaser 4510DT',
	//      color: false,
	//      dpi: '600',
	//      duplex: true,
	//      price_per_page: 0.09 }

		
.remap changes names and values. Feed it what the object should be called, or what it should look like and how to convert it.