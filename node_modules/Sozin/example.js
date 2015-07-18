var slf = require('./index')
slf.getJSON('spring', 'final').then(console.log)

/*
[ ...,
  { class_sect: 'SPAN 1230 106',
    date: 'Mon, Dec 15',
    time: '2:00 PM',
    location: 'URHG01: Uris Hall G01' },
  { class_sect: 'SPAN 1230 107',
    date: 'Mon, Dec 15',
    time: '2:00 PM',
    location: 'URHG01: Uris Hall G01' },
  ...
]
 */