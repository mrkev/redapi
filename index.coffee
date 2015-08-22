#                                                                              #
#                              RedAPI server                                   #
#                                                                              #

config  = require('config-multipaas')()
express = require('express')
cors    = require('cors')

app     = express()
router  = express.Router()

app.use(cors());

# routes_netprint           = require './routes_netprint'
# routes_roster             = require './routes_roster'
# routes_academic_calendar  = require './routes_academic_calendar'
# routes_exam_calendar      = require './routes_exam_calendar'

#
# Set up the routes
#

## Home

router
  .route('/')
  .get (req, res) ->
    res.sendFile __dirname + '/info.txt'
    console.log process.version
    return

(require './routes_food')(-> router)


# ## Roster@Katara
# #
# router
#   .route('/roster')
#   .get routes_roster.current_term

# router
#   .route('/roster/:term')
#   .get routes_roster.term

# router
#   .route('/roster/:term/:subject')
#   .get routes_roster.subject

## Printing@Sokka

# router
#   .route('/print')
#   .get routes_netprint.all_printers

# ## Academic_Calendar@Tenzin
# router
#   .route('/academic_calendar/:ac_year')
#   .get routes_academic_calendar.cal_for_year

# ## Exam_Calendar@Sozin
# router
#   .route('/exam_calendar/:term/:type')
#   .get routes_exam_calendar.cal_for_type_term

#
# Start the server
#
app
  .use('/', router)
  .listen config.get('PORT'), config.get('IP'), ->
    console.log "Good stuff happens on #{config.get('IP')}:#{config.get('PORT')}"
