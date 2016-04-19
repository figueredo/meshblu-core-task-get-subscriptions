http                = require 'http'
SubscriptionManager = require 'meshblu-core-manager-subscriptions'

class GetSubcriptions
  constructor: ({datastore, @subscriptionManager, uuidAliasResolver}) ->
    @subscriptionManager ?= new SubscriptionManager {datastore, uuidAliasResolver}

  do: (job, callback) =>
    {toUuid, responseId} = job.metadata
    @subscriptionManager.subscriberList toUuid, (error, data) =>
      return @sendResponse responseId, 500, null, callback if error?
      @sendResponse responseId, 200, data, callback

  sendResponse: (responseId, code, data, callback) =>
    callback null,
      metadata:
        responseId: responseId
        code: code
        status: http.STATUS_CODES[code]
      rawData: JSON.stringify data

module.exports = GetSubcriptions
