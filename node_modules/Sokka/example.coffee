netprint = require './index.coffee'
netprint.getJSON().then (info) ->
  console.log info

# { queue_name: 'wsh1',
#   printer_name: 'WSH Browsing Library 1',
#   printer_model: 'Xerox Phaser 4510DT',
#   color: false,
#   dpi: '600',
#   duplex: true,
#   price_per_page: 0.09 } ]

