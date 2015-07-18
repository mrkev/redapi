Sokka [![Build Status](https://travis-ci.org/mrkev/Sokka.svg?branch=master)](https://travis-ci.org/mrkev/Sokka)
=====

Net print module for the RedAPI. Can be used to fetch info about Cornell netprint in general.

    var netprint = require('Sokka');
    netprint.getJSON().then(function (data) {...}, function (error) {...}); 
