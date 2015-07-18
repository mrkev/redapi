assert = require("assert")
expect = require("chai").expect
chai = require("chai")
chai.use require("chai-as-promised")
chai.should()


describe "Sokka instance", ->
  @timeout 120000 # (2 minutes for timeout should be enough)
  
  it "can be loaded without blowing up", ->
    assert.doesNotThrow -> require "../index.coffee"
    expect(require("../index.coffee")).to.exist
    expect(require("../index.coffee")).to.respondTo "getJSON"

  netprint = undefined
  beforeEach -> netprint = require("../index.coffee")

  describe "#getJSON()", ->
    it "returns non empty data", ->
      expect(netprint.getJSON()).to.eventually.have.length.above 0

    
    # have.property checks for (property, value). Change this.
    # it('returns the data we want', function(){
    #   return netprint.getJSON().should.eventually.all.have.property(
    #    'queue_name', 'printer_name', 'printer_model', 'color', 'dpi', 'duplex', 'price_per_page');
    # });
    
    it "returns the data in the types we want", ->
      expect(netprint.getJSON()).to.eventually.satisfy (data) ->
        result = true
        i = data.length - 1

        while i >= 0
          result = (typeof data[i].queue_name is "string")      and \ 
                   (typeof data[i].printer_name is "string")    and \ 
                   (typeof data[i].printer_model is "string")   and \ 
                   (typeof data[i].color is "boolean")          and \ 
                   (typeof data[i].dpi is "number")             and \ 
                   (typeof data[i].duplex is "boolean")         and \ 
                   (typeof data[i].price_per_page is "number")  and result
          i--
        result

