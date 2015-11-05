http            = require 'http'
GetSubcriptions = require '../src/get-subscriptions'

describe 'GetSubcriptions', ->
  beforeEach ->
    @subscriptionManager =
      list: sinon.stub()

    @sut = new GetSubcriptions
      subscriptionManager: @subscriptionManager

  describe '->do', ->
    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @subscriptionManager.list.yields null, [
          {subscriberUuid: 'bright-green', emitterUuid: 'purple-blue', type: 'blue'}
          {subscriberUuid: 'bright-green', emitterUuid: 'purple', type: 'blue-purple'}
        ]
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 200', ->
        expect(@newJob.metadata.code).to.equal 200

      it 'should get have the status of ', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[200]

      it 'should have the raw data', ->
        expect(@newJob.rawData).to.equal JSON.stringify [
          {subscriberUuid: 'bright-green', emitterUuid: 'purple-blue', type: 'blue'}
          {subscriberUuid: 'bright-green', emitterUuid: 'purple', type: 'blue-purple'}
        ]

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @subscriptionManager.list.yields null, [
          {subscriberUuid: 'hot-yellow', emitterUuid: 'kinda-blue', type: 'green-and-something-else'}
          {subscriberUuid: 'hot-yellow', emitterUuid: 'kinda-green', type: 'blue-and-something-else'}
        ]
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'hot-yellow'
            fromUuid: 'ugly-yellow'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 200', ->
        expect(@newJob.metadata.code).to.equal 200

      it 'should get have the status of OK', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[200]

      it 'should have the raw data', ->
        expect(@newJob.rawData).to.equal JSON.stringify [
          {subscriberUuid: 'hot-yellow', emitterUuid: 'kinda-blue', type: 'green-and-something-else'}
          {subscriberUuid: 'hot-yellow', emitterUuid: 'kinda-green', type: 'blue-and-something-else'}
        ]

    describe 'when called and the subscription list yields an error', ->
      beforeEach (done) ->
        @subscriptionManager.list.yields new Error("dark shadow grey")
        job =
          metadata:
            auth:
              uuid: 'bluer-than-you'
              token: 'red-med'
            toUuid: 'no bo blue'
            fromUuid: 'semi-black-almost-grey'
            responseId: 'i-wish-i-was-blue'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'i-wish-i-was-blue'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[500]
