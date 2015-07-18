var assert = require('assert');
var expect = require('chai').expect;

var index = './index.js';

describe('Katara', function(){

	it('can be loaded without blowing up', function () {
		assert.doesNotThrow(function () {require(index)});
		expect(require(index)).to.not.be.undefined;
	});

	it('responds to what we expect it to respond', function () {
		expect(require(index)).to.respondTo('getJSON');
		expect(require(index)).to.respondTo('query');
		expect(require(index)).to.respondTo('clear');

	});

});