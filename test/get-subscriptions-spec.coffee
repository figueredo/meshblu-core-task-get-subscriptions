http            = require 'http'
GetSubcriptions = require '../src/get-subscriptions'

describe 'GetSubcriptions', ->
  beforeEach ->
    @whitelistManager =
      canConfigure: sinon.stub()

    @sut = new GetSubcriptions
      whitelistManager: @whitelistManager

  describe '->run', ->
    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @whitelistManager.canConfigure.yields null, true
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            toUuid: 'bright-green'
            fromUuid: 'dim-green'
            responseId: 'yellow-green'
        @sut.run job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 200', ->
        expect(@newJob.metadata.code).to.equal 200

      it 'should get have the status of ', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[200]

    describe 'when called with a different valid job', ->
      beforeEach (done) ->
        @whitelistManager.canConfigure.yields null, true
        job =
          metadata:
            auth:
              uuid: 'dim-green'
              token: 'blue-lime-green'
            toUuid: 'hot-yellow'
            fromUuid: 'ugly-yellow'
            responseId: 'purple-green'
        @sut.run job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 200', ->
        expect(@newJob.metadata.code).to.equal 200

      it 'should get have the status of OK', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[200]

    describe 'when called with a job that with a device that cannot be configured', ->
      beforeEach (done) ->
        @whitelistManager.canConfigure.yields null, false
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'super-purple'
            fromUuid: 'not-so-super-purple'
            responseId: 'purple-green'
        @sut.run job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the canConfigure yields an error', ->
      beforeEach (done) ->
        @whitelistManager.canConfigure.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'puke-green'
              token: 'blue-lime-green'
            toUuid: 'green-bomb'
            fromUuid: 'green-safe'
            responseId: 'purple-green'
        @sut.run job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[500]
