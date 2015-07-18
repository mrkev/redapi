var academic_calendar = require('./index');
var object = academic_calendar.getJSON(2014).then(function (data) {
  console.dir(data[0])
});

// [ { term: 'Fall 2014',
//     events: 
//     [ { Date: 'August 11',
//         description: 'Course Add/Drop Begins',
//         days_of_week: 'Monday' },
//       { Date: 'August 19',
//         description: 'Check for Holds Preventing Registration',
//         days_of_week: 'Tuesday' },
//       { Date: 'August 22',
//         description: 'New Student Check-in (new undergraduates)',
//         days_of_week: 'Friday' },
//   
//         ...
//   
//       { Date: 'December 15-18',
//         description: 'Exams',
//         days_of_week: 'Monday - Thursday' },
//       { Date: 'December 20',
//         description: 'January Graduation Recognition',
//         days_of_week: 'Saturday' } ] },
//   { term: 'Winter 2014-15',
//     events: [ ... ] },
//   { term: 'Spring 2015',
//     events: [ ... ] },
//   { term: 'Summer 2015',
//     events: [ ... ] } ]