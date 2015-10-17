#                                                                              #
#                              RedAPI server                                   #
#                                                                              #

config  = (require 'config-multipaas')()
express = (require 'express')
cors    = (require 'cors')

app     = express()
router  = express.Router()

app.use(cors());

#
# Set up the routes
#

(require './routes/food')        (-> router)
(require './routes/open_status') (-> router)

router
  .route('/')
  .get (req, res) ->
    res.sendFile __dirname + '/info.txt'
    return console.log process.version

app
  .use('/', router)
  .listen config.get('PORT'), config.get('IP'), ->
    console.log "Good stuff happens on #{config.get('IP')}:#{config.get('PORT')}"
