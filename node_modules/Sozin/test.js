var assert = require('assert');
var expect = require('chai').expect;
var chai   = require('chai');

chai.use(require('chai-as-promised'));
chai.should();

describe('Sokka', function(){
	
	this.timeout(120000); // (2 minutes for timeout should be enough)

	/**
	 * Test that the module work wont crash anything.
	 */
	it('can be loaded without blowing up', function () {
		assert.doesNotThrow(function () {require('./index.js')});
		expect(require('./index.js')).to.not.be.undefined;
		expect(require('./index.js')).to.respondTo('getJSON');
	});
});
