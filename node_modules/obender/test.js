var assert = require('assert');
var expect = require('chai').expect;
var chai   = require('chai');

chai.should();

describe('Obender', function(){

	it('can be loaded without blowing up', function () {
		assert.doesNotThrow(function () {require('./index.js')});
		expect(require('./index.js')).to.not.be.undefined;
	});

	it('responds to what we expect it to respond', function () {
		expect(require('./index.js')).to.respondTo('remap');
	});

	var remap, object;
	beforeEach(function(){
		remap  = require('./index.js').remap;
		object = {          
		    'Queue Name'    : 'wsh1',
		    'Printer Name'  : 'WSH Browsing Library 1',
		    'Printer Model' : 'Xerox Phaser 4510DT',
		    'Color'         : 'B/W',
		    'DPI'           : '600',
		    'Duplex'        : 'Two-sided',
		    '¢/Pg'          : '9'
		}
	});


	describe('#remap()', function() {	

		it('doesn\'t crash on non-found or empty property names.', function(){
				remap(
					{'Queue Name'		: 'queue_name',
					 'Printer Name'		: 'printer_name',
					 'Printer Model'	: 'printer_model',
					  4					: 'black_and_white', // Doesn't exist
					  null				: 'dpi',
					  undefined			: 'duplex',
					 '¢/Pg'			    : 'price_per_page'
					}, object);

				var yofrankie = 
					{ queue_name: 'wsh1',
		        	  printer_name: 'WSH Browsing Library 1',
		        	  printer_model: 'Xerox Phaser 4510DT',
		        	  'Color': 'B/W',
		        	  'DPI': '600',
		        	  'Duplex': 'Two-sided',
		        	  price_per_page: '9'
		        	}

				expect(object).to.deep.equal(yofrankie);
		}); // ✓


		describe('(on property names only)', function () {
				
			it('works for changing property names', function(){
					remap(
						{'Queue Name'		: 'queue_name',
						 'Printer Name'		: 'printer_name',
						 'Printer Model'	: 1,
						 'Color'			: 2,
						 'DPI'				: 'dpi',
						 'Duplex'			: 3,
						 '¢/Pg'			    : 'price_per_page'
						}, object);

					var yofrankie = 
						{ queue_name: 'wsh1',
			        	  printer_name: 'WSH Browsing Library 1',
			        	  '1': 'Xerox Phaser 4510DT',
			        	  '2': 'B/W',
			        	  dpi: '600',
			        	  '3': 'Two-sided',
			        	  price_per_page: '9'
			        	}

					expect(object).to.deep.equal(yofrankie);
			}); // ✓

			it('can handle empty values', function(){
					remap(
						{'Queue Name'		: '',										// Will stay the same 
						 'Printer Name'		: 'printer_name',							// First come first serve.
						 'Printer Model'	: 'printer_name',							//   - will stay the same.
						 'Color'			:  null,									// Will stay the same 
						 'DPI'				:  undefined,								// Will stay the same 
						 'Duplex lol'		:  null,									// Not found, stays the same
						 '¢/Pg'			    : 'yo'
						}, object);

					var yofrankie = 
						{ '': 'wsh1',
			        	  printer_name: 'WSH Browsing Library 1',
			        	  'Printer Model': 'Xerox Phaser 4510DT',
			        	  'Color': 'B/W',
			        	  'DPI': '600',
			        	  'Duplex': 'Two-sided',
			        	  yo: '9'
			        	}

					expect(object).to.deep.equal(yofrankie);
			}); // ✓

			it('can handle repetitions', function(){
				var object = 
					{'One'		: true,										
					 'Two'		: true,										
					 'Three'	: true,	
					}

					remap(
						{'One'		: 'one',										
						 'Two'		: 'two',							
						 'Three'	: 'two',							
						}, object);

					var yofrankie = 
						{'one'		: true,										
						 'two'		: true,										
						 'Three'	: true,	
			        	}

					expect(object).to.deep.equal(yofrankie);
			}); // ✓

			it('works for changing property names with function modifiers', function(){
					remap(
						{'Queue Name'		: function (value) { return 'dude'; },				
						 'Printer Name'		: function (value) { return  5; },			// Empty. Will stay the same.		
						 'Printer Model'	: function (value) { return  null; },		// Empty. Will stay the same.
						 'Color'			: function (value) { return  undefined; },	// Empty. Will stay the same.
						 'DPI'				: function (value) { throw   new Error('message'); },// Error. Will stay the same.
						 'Duplex'			: function (value) { return ''; },			// Empty. Will stay the same.
						 '¢/Pg'			    : function (value) { return 'dude'; }
						}, object);

					var yofrankie = 
						{  dude: 'wsh1',
			        	  '5': 'WSH Browsing Library 1',
			        	  'Printer Model': 'Xerox Phaser 4510DT',
			        	  'Color': 'B/W',
			        	  'DPI': '600',
			        	  '': 'Two-sided',
			        	  '¢/Pg': '9'
			        	}

					expect(object).to.deep.equal(yofrankie);
			}); // ✓

			// TODO: it will use literals for arrays and empty objects?
		});



		describe('(on property names and object values)', function () {
			it('works for changing names and values', function(){
					remap(
						{'Queue Name'		:  new Boolean(true),
						 'Printer Name'		:  new Number(4),
						 'Printer Model'	:  new String('printer_model'),
						 'Color'			: {'color'			: function (value) { return value === 'Color'; } },
						 'DPI'				:  'dpi',
						 'Duplex'			: {'duplex' 		: function (value) { return value === 'Two-sided'; } },
						 '¢/Pg'			 	: {'price_per_page' : function (value) { return parseFloat(value) / 100; } }
						}, object);	

					var expected = 
						{ true: 'wsh1',
			        	  '4': 'WSH Browsing Library 1',
			        	  printer_model: 'Xerox Phaser 4510DT',
			        	  color: false,
			        	  dpi: '600',
			        	  duplex: true,
			        	  price_per_page: 0.09
			        	}

			        

			        expect(object).to.deep.equal(expected);
			});

			// it works for objects {[null, undefined]:
			// 
			// add mode {'key': func, 'val': func} ??

			it('doesn\'t crash from unproperly formatted mapping objects', function(){
					remap(
						{'Queue Name'		:  'queue_name',
						 'Printer Name'		:  'printer_name',
						 'Printer Model'	:  'printer_model',
						 'Color'			: {'color'			: 'lol?' },
						 'DPI'				:  'dpi',
						 'Duplex'			: {'duplex' 		: function (value) { return value === "Two-sided"; } },
						 '¢/Pg'			 	:  100 
						}, object);	

					var expected = 
						{ queue_name: 'wsh1',
			        	  printer_name: 'WSH Browsing Library 1',
			        	  printer_model: 'Xerox Phaser 4510DT',
			        	  color: 'lol?',
			        	  dpi: '600',
			        	  duplex: true,
			        	  '100': '9'
			        	}

			        expect(object).to.deep.equal(expected);
			});

			it('Handles error on bending functions correctly', function(){
					remap(
						{'Queue Name'		:  'queue_name',
						 'Printer Name'		:  'printer_name',
						 'Printer Model'	:  'printer_model',
						 'Color'			: {'color'			: function (value) { return value === 'Color'; } },
						 'DPI'				:  'dpi',
						 'Duplex'			: {'duplex' 		: function () {} },
						 '¢/Pg'			 	: {'price_per_page' : function (value) { throw new Error(); } }
						}, object);	

					var expected = 
						{ queue_name: 'wsh1',
			        	  printer_name: 'WSH Browsing Library 1',
			        	  printer_model: 'Xerox Phaser 4510DT',
			        	  color: false,
			        	  dpi: '600',
			        	  duplex: 'Two-sided',
			        	  price_per_page: '9'
			        	}

			        expect(object).to.deep.equal(expected);
			});
		});
	});
});
