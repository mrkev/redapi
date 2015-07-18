'use strict';
/**
 * Descriptions and the like. FA14 only atm.
 * @return {[type]} [description]
 */
module.exports = (function () {
	
	function AviaryCannaryMadness (src) {
		this.db = require(src);
	}

	AviaryCannaryMadness.prototype.forCID = function(cid) {
		if (this.db[cid]) {
			return {
				rid : this.db[cid].rid,
				class_description : this.db[cid].htmldesc
			};
		}

		return {};
	};

	return new AviaryCannaryMadness('./descdb.json');

})();