SubsriptionManager = require 'meshblu-core-manager-subscriptions'
http               = require 'http'

class GetSubcriptions
  constructor: (dependencies={}) ->
    {@database, @subscriptionManager} = dependencies
    @subscriptionManager ?= new SubsriptionManager database: @database

  run: (job, callback) =>
    {toUuid, responseId} = job.metadata
    @subscriptionManager.list toUuid, (error, subsriptions) =>
      return @sendResponse responseId, 500, null, callback if error?
      @sendResponse responseId, 200, subsriptions, callback

  sendResponse: (responseId, code, data, callback) =>
    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]
      rawData: JSON.stringify data

module.exports = GetSubcriptions
