http = require 'http'

class GetSubcriptions
  constructor: (depedencies={}) ->
    {@database, @Device, @simpleAuth} = depedencies
    @database ?= new (require 'meshblu-server/lib/database')
    @Device ?= new (require 'meshblu-server/lib/models/device')
    @simpleAuth ?= new (require 'meshblu-server/lib/simpleAuth')

  run: (job, callback) =>
    code = 200
    {toUuid, fromUuid, responseId} = job.metadata
    toDeviceModel = new @Device uuid: toUuid
    fromDeviceModel = new @Device uuid: toUuid
    toDeviceModel.fetch (error, fromDevice) =>
      return @sendResponse responseId, 500, callback if error?
      fromDeviceModel.fetch (error, toDevice) =>
        return @sendResponse responseId, 500, callback if error?
        @simpleAuth.canConfigure fromDevice, toDevice, (error, canConfigure) =>
          code = 403 unless canConfigure
          @sendResponse responseId, code, callback

  sendResponse: (responseId, code, callback) =>
    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]

module.exports = GetSubcriptions
