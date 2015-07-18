/* global require, console, module,  __dirname */
'use strict';	

var remap	 = require('obender').remap;
var jsdom	 = require('jsdom');

var jquery = require('fs').readFileSync(__dirname + '/vendor/jquery.min.js', 'utf-8');
var t2json = require('fs').readFileSync(__dirname + '/vendor/jquery.tabletojson.js', 'utf-8');

/**
 * Tenzin, v0.0.0
 * 
 * Exports for the module.
 * @return {AcademicCalSource}
 */
module.exports = (function () {

	function AcademicCalSource() {
		var self = this;
		self.url = 'http://www.cornell.edu/academics/calendar/';
		self.data = null;
	}

	// http://www.cornell.edu/academics/calendar/?year=2014-15
	AcademicCalSource.prototype.query = function(ayear) {
		var self  = this;
		var url   = self.url + '?year=' + ayear + '-' + (++ayear % 2000) + '.cfm';

		return (new Promise(function (resolve, reject) {
			var config = {
				url : url,
				src : [jquery, t2json]
			}

			config.done = function (err, window) {

			  var $ = window.jQuery;

			  if (err !== null) reject(err);
			  
			  self.data = [];

			  $('table').each(function() {
			  	var tmp = $(this).tableToJSON();
			  	var term_title = $(this).find('caption').text();

			  	for (var i = tmp.length - 1; i >= 0; i--) {
			  		remap(
			  			{ 'Event'             : {'description'
			  														: function (val) { return val.replace('¹²³⁴⁵⁶⁷⁸⁹⁰', ''); }},
			  			  'Day(s) of the Week': {'days_of_week'
			  														: function (val) { return val.replace('¹²³⁴⁵⁶⁷⁸⁹⁰', ''); }},
			  			  'date'              : {'date'
			  			  				    				: function (val) { return val.replace('¹²³⁴⁵⁶⁷⁸⁹⁰', ''); }},
 							}, tmp[i]);
			  	}

			  	var obj = {
			  		term : term_title.trim(),
			  		events : tmp
			  	};

			  	self.data.push(obj);
			  });

			  resolve(self.data);
			};


			jsdom.env(config);

		}))
	};

	AcademicCalSource.prototype.clear = function() { this.data = null; };

	AcademicCalSource.prototype.getJSON = function(academic_year) {
		return this.query(academic_year);
	};

	return new AcademicCalSource();
})();

