/* global require, module, console */
'use strict';


var Promise = require('es6-promise').Promise;
var remap   = require('obender').remap;
var xml2js  = require('xml2js');
var rp      = require('request-promise');

// Descriptions from database.
var descdb = require('./descdb.js');
/**
 * Katara v0.0.1
 *
 * Exports for the module.
 * @return {NetPrintSource}
 */
module.exports = (function () {

    function RedRosterSource(url, options) {
        var self = this;
        self._url = url;
        self.interval = options ? options.interval : 604800000 / 7; // One day
        self.data = options ? options.cache : {};
        // We will clear the data every day to get fresh, updated info.
        self.timer = setTimeout(self.clear, self.interval);
    }

    /**
     * Queries official XML roster source for course informaiton.
     * @param  {String} subj Subject key of XML source to query.
     * @param  {String} term Term key of XML source to query
     * @return {Promise}     I swear I'll return some converted JSON, 
     *                       unless it doesn't.
     */
    RedRosterSource.prototype.query = function(subj, term) {
        term = (term === undefined || term === null ? 'FA14' : term);
        subj =  subj === undefined || subj === null ? ''     : subj;

        var self  = this;
        var url   = self._url + term + '/' + subj + (subj === '' ? '' : '/') + 'xml/';

        var tereshkova = new Promise(function (resolve, reject) {

            // Query XML
            return rp(url)

            // Convert to JSON
            .then(JSON_from_XML)

            // Remove them crazy dollar signs.
            .then(undollarify)

            // End this chain.
            .then(resolve)

            // Ohai.
            .catch(reject);

        });

        if (subj === '') {
            
            // Fix the homepage's madness
            tereshkova.then(remap_homepage);

        } else {

            // Fix the subject page's madness
            tereshkova.then(remap_courses)

            // Add CID
            .then(cidify)

            // Inject descriptions
            .then(inject_descriptions)

            // Parse meeting times
            .then(midnightmillify)


            //.then(numberify)

        }

        return tereshkova

            // Cache the data
            .then(function (data) {
                self.data[term] = self.data[term] || {};
                self.data[term][subj] = data;

                return data;
            })

            .catch(console.trace);
    };


    RedRosterSource.prototype.clear = function() {
        this.data = null;
    };

    RedRosterSource.prototype.getJSON = function(subj, term) {

        if (this.data[term] === undefined || 
            this.data[term][subj] === undefined) {
            return this.query(subj, term);

        } else {
            return Promise.resolve(this.data[term][subj]);
        }
    };

    return new RedRosterSource('http://registrar.sas.cornell.edu/courses/roster/');
})();

var cidify = function (data) {
    console.log('Adding ids');
    data.courses.forEach(function (course) {
        var cid = course.subject_key + course.catalog_number; //+ '-' + course.sections[0].associated_class;

        // Add id's for courses
        // if (course.sections.length > 1) consolelog(course.subject_key, course.catalog_number, course.sections)
        course.course_id = cid;
        // and for sections
        
        course.sections.forEach(function (sct) {
            sct.course_id = cid;
        });
    });

    return data;
};


var midnightmillify = function (data) {
    data.courses.forEach(function (course) {
        course.sections.forEach(function (section) {
            section.meeting.start_tm = midnightMillis(section.meeting.start_time);
            section.meeting.end_tm = midnightMillis(section.meeting.end_time);
        });
    });

    return data;
};

require('datejs');

/**
 * Converts string time representation to milliseconds since midnight.
 * @param  {String} time Time to convert
 * @return {Number}      Milliseconds since midnight represented by the given 
 *                       time.
 */
var midnightMillis = function (time) {
  return  Date.parse('July 26th, 2014, ' + time) - 
      Date.parse('July 26th, 2014, 12:00AM');
};


var inject_descriptions = function (data) {
    console.log('Adding descriptions');
    data.courses.forEach(function (course) {
        Object.keys(descdb.forCID(course.course_id)).forEach(function (key) {
            course[key] = descdb.forCID(course.course_id)[key];
        });
    });

    return data;
};


var remap_homepage = function (data) {
    
    // Term
    data.term = data.subjects.term;

    // Subject Array
    var subjarr = [];
    for (var subj in data.subjects.subject) {
        var obj = data.subjects.subject[subj];

        // Rename stuff
        remap({
            'subject' : 'key',
            'subject_ldescr' : 'name'
        }, obj);

        // --XML ++JSON
        delete obj.xml;
        // obj.json = 'http://api-mrkev.rhcloud.com/redapi/roster?' + obj.key;


        subjarr.push(data.subjects.subject[subj]);
    }

    data.subjects = subjarr;

    return data;
};

/**
 * Renames stuff.
 * @param  {[type]} subject [description]
 * @return {[type]}         [description]
 */
var remap_courses = function (subject) {
    // Term, dateloaded, datetime_loaded
    subject.term          = subject.courses.term;
    subject.date_load     = subject.courses.date_load;
    subject.datetime_load = subject.courses.datetime_load;

    // // Courses Array
    // var crsarr = [];
    // for (var crs in subject.courses.course) {
    //  var obj = subject.courses.course[crs];
    //  
    //  // For course_title, units, etc.
    //  remove_singleton_string_arrays(obj);
    //  remap({
    //      'course_title' : 'title',
    //      'grading_basis_sdescr' : 'grading_basis',
    //      'subject' : 'subject_key',
    //      'catalog_nbr': 'catalog_number'
    //  }, obj);
    //  crsarr.push(obj);
    // }
    // 
    // subject.courses = crsarr;

    magic(subject, 'courses', 'course', function (obj) {
        remove_singleton_string_arrays(obj);
        remap({
            'course_title' : 'title',
            'grading_basis_sdescr' : 'grading_basis',
            'subject' : 'subject_key',
            'catalog_nbr': 'catalog_number',
            'class_descr': 'class_description'
        }, obj);


        // TODO claring 'outsides'.
        open_array('crosslists', obj);
        magic(obj, 'crosslists', 'course', function (crss) {
            remove_singleton_string_arrays(crss);
            remap({
                'catalog_nbr' : 'catalog_number',
                'subject' : 'subject_key'
            }, crss);
        });

        open_array('sections', obj);
        magic(obj, 'sections', 'section', function (sct) {
            remove_singleton_string_arrays(sct);
            open_array('meeting', sct);

            remap({
                'catalog_nbr' : 'catalog_number',
                'consent_ldescr' : 'consent_description',
                'subject' : 'subject_key'
            }, sct);

            if (sct.meeting) {
                remove_singleton_string_arrays(sct.meeting);
                remap({
                    'facility_ldescr' : 'facility',
                    'meeting_pattern_sdescr' : 'pattern'

                    // 'start_time' : 'start_time_str',
                    // 'end_time' : 'end_time_str',

                    // 'start_date' : 'start_date_str',
                    // 'end_date' : 'end_date_str',

                }, sct.meeting);

                if (sct.meeting.instructors !== undefined)  {
                    open_array('instructors', sct.meeting); 
                    magic(sct.meeting, 'instructors', 'instructor', function () {});
                }
            }
            
            open_array('notes', sct);
            magic(sct, 'notes', 'note', function () {}); // TODO: Does magic work with null -function
        });


        open_array('topics', obj);
        magic(obj, 'topics', 'topic', function () {});

    });

    return subject;
};

/**
 * Makes the contents of object.outside those of 
 * object.outside.inside, where object.outside.inside is an array.
 * It runs function func(obj) once for each child of object.outside.inside.
 * @return {[type]} [description]
 */
var magic = function (object, outside, inside, func) {

    // Die if outside doesn't exist.
    if (object[outside] === undefined) {
        console.dir(object);
        console.dir(object[outside]);
        throw new Error('DAMN MAGIC');
    }
    
    // If outside is empty, make it an empty array
    if (object[outside][inside] === '' || 
        object[outside][inside] === {}) {
        object[outside][inside] = [];
    }

    // Do the magic
    var arr = [];
    for (var crs in object[outside][inside]) {
        var obj = object[outside][inside][crs];
        func(obj);
        arr.push(obj);
    }
    
    object[outside] = arr;
};

/**
 * For every property of this object, checks if property is an array with a
 * single string object. If so, it gets rid of the array and sets the property
 * to that string
 * @param  {[type]} obj The object to be checked
 */
var remove_singleton_string_arrays = function (obj) {
    for (var prop in obj) {
        if (Array.isArray(obj[prop]) && 
            obj[prop].length === 1 && 
            typeof obj[prop][0] === 'string') {
            obj[prop] = obj[prop][0];
        }
    }
};

var open_array = function (prop, obj) {
    if (Array.isArray(obj[prop]) && 
        obj[prop].length === 1) {
        obj[prop] = obj[prop][0];
    }
};

var JSON_from_XML = function (data) {
    
    var parser = new xml2js.Parser();

    return new Promise(function (resolve, reject) {

        parser.parseString(data, function (err, result) {
            if (err instanceof Error) reject(err);

            console.log('Done parsing roster XML.', result);

            resolve(result);

        });
        
    });

};

var undollarify = function (object) {
    if (typeof object !== 'object') return;

    unwind(object, '$');

    for (var prop in object) {
        undollarify(object[prop]);
    }

    return object;
};

/**
 * Unwinds property attr in object if it's an object, giving all of attr's properties
 * to object
 * @param  {Object} object [description]
 * @param  {String} attr   [description]
 */
var unwind = function (object, attr) {
    for (var attrname in object) {
        if (attrname === attr) {

            for (var childattr in object[attr]) {
                if (object[childattr] === undefined) {
                    object[childattr] = object[attr][childattr];
                    delete object[attr][childattr];

                } else {
                    console.error ('Error undollarfying');
                    console.log(object);
                    console.log ('Object already has property ' + childattr);
                }
            }

            if (Object.keys(object[attr]).length === 0) delete object[attr];

        }
    }
};