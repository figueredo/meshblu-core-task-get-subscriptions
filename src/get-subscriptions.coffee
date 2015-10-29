SubsriptionManager = require 'meshblu-core-manager-whitelist'
WhitelistManager   = require 'meshblu-core-manager-subscriptions'
http               = require 'http'

class GetSubcriptions
  constructor: (dependencies={}) ->
    {@database, @whitelistManager, @subscriptionManager} = dependencies
    @whitelistManager ?= new WhitelistManager database: @database
    @subscriptionManager ?= new SubsriptionManager database: @database

  run: (job, callback) =>
    {toUuid, fromUuid, responseId} = job.metadata
    @whitelistManager.canConfigure toUuid, fromUuid, (error, canConfigure) =>
      return @sendResponse responseId, 500, null, callback if error?
      return @sendResponse responseId, 403, null, callback unless canConfigure
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
