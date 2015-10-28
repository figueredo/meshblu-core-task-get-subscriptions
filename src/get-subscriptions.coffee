http = require 'http'
WhitelistManager = require 'meshblu-core-manager-whitelist'

class GetSubcriptions
  constructor: (dependencies={}) ->
    {@database, @whitelistManager} = dependencies
    @whitelistManager ?= new WhitelistManager database: @database

  run: (job, callback) =>
    code = 200
    {toUuid, fromUuid, responseId} = job.metadata
    @whitelistManager.canConfigure toUuid, fromUuid, (error, canConfigure) =>
      return @sendResponse responseId, 500, callback if error?
      code = 403 unless canConfigure
      @sendResponse responseId, code, callback

  sendResponse: (responseId, code, callback) =>
    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]

module.exports = GetSubcriptions
