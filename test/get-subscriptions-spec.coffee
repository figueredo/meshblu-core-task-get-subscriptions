http            = require 'http'
GetSubcriptions = require '../src/get-subscriptions'

describe 'GetSubcriptions', ->
  beforeEach ->
    @simpleAuth =
      canConfigure: sinon.stub()

    @toDevice =
      fetch: sinon.stub()

    @fromDevice =
      fetch: sinon.stub()

    @Device = sinon.stub()

    @database =
      subsciptions:
        find: sinon.stub()

    @sut = new GetSubcriptions
      simpleAuth: @simpleAuth
      Device: @Device
      database: @database

  describe '->run', ->
    describe 'when called with a valid job', ->
      beforeEach (done) ->
        @toDevice.fetch.yields null, uuid: 'bright-green', owner: 'dim-green'
        @fromDevice.fetch.yields null, uuid: 'dim-green'
        @Device.withArgs('bright-green').returns @toDevice
        @Device.withArgs('dim-green').returns @fromDevice

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
        @toDevice.fetch.yields null, uuid: 'hot-yellow', owner: 'ugly-yellow'
        @fromDevice.fetch.yields null, uuid: 'ugly-yellow'
        @Device.withArgs('hot-yellow').returns @toDevice
        @Device.withArgs('ugly-yellow').returns @fromDevice
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
        @getDevice.withArgs 'super-purple'
          .yields null, uuid: 'super-purple'
        @getDevice.withArgs 'not-so-super-purple'
          .yields null, uuid: 'not-so-super-purple'
        @simpleAuth.canConfigure.yields null, false
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

    describe 'when called and the toUuid getDevice yields an error', ->
      beforeEach (done) ->
        @getDevice.withArgs 'green-bomb'
          .yields new Error("oh no")
        @getDevice.withArgs 'green-safe'
          .yields null, uuid: 'green-safe'
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

  describe 'when called and the fromUuid getDevice yields an error', ->
    beforeEach (done) ->
      @getDevice.withArgs 'green-bomb'
        .yields null, uuid: 'green-bomb'
      @getDevice.withArgs 'green-safe'
        .yields new Error("oh boy")
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
