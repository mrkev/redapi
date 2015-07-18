## Cool stuff with obender. Remaping.

You get some json from the server in ew state. It's time to bend it.

	var remap  = require('obender').remap;
	
	var object = ... // Some JSON with properties that have spaces and unconventional 
					 // characters and poorly formatted values.
					 
	remap(
		{'Queue Name'		: 'queue_name',
		 'Printer Name'		: 'printer_name',
		 'Printer Model'	: 'printer_model',
		 'Color'			: {'color': function (value) { return value === 'Color'; } },
		 'DPI'				: 'dpi',
		 'Duplex'			: {'duplex' : function (value) { return value === "Two-sided"; } },
		 '¢/Pg'			 : {'price_per_page' : function (value) { return parseFloat(value) / 100; } }
		},
		object);	 // Object is nice now wyayayya party.
		
		
remap changes names and values. Feed it what the object should be called, or what it should look like and how to convert it.