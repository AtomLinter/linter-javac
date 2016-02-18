# This file contains all specs to ensure the fundamental functionality of
# this plugin.

_path = require 'path'


_helpers = require _path.join(__dirname, '_spec-helpers.coffee')

describe 'linter-javac', ->
  describe 'provideLinter()', ->
    beforeEach ->
      # get linter-module
      linterJavac = require(
        _path.join(__dirname, '..', 'lib', 'init.coffee')
      )

      # inject javaExecutablePath
      linterJavac.javaExecutablePath = 'javac'

      # inject additionalOptions
      linterJavac.additionalOptions = []

      # instantiate linter-worker
      @linter = linterJavac.provideLinter()

      # stab texteditor, to assure stubbing
      @texteditor = null


    describe 'when using a faulty java-source file', ->
      beforeEach ->
        # set proper texteditor-path to the faulty fixture
        @texteditor = _helpers.texteditorFactory(
          _path.join(__dirname, 'fixtures', 'BrokenWorld.java')
        )

      it 'returns at least 8 messages in the linter-message-object', ->
        waitsForPromise( =>
          @linter.lint(@texteditor).then( (messages) ->
            expect(messages.length).toBeGreaterThan(7)
          )
        )


    describe 'when using a correct java-source file', ->
      beforeEach ->
        # set a proper texteditor-path to the working fixture
        @texteditor = _helpers.texteditorFactory(
          _path.join(__dirname, 'fixtures', 'HelloWorld.java')
        )

      it 'returns an empty linter-message-object', ->
        result = {}
        expect(JSON.stringify(@linter.lint(@texteditor)))
          .toEqual(JSON.stringify(result))


    describe 'when using an empty java-source file', ->
      beforeEach ->
        # set a proper texteditor-path to the empty fixture
        @texteditor = _helpers.texteditorFactory(
          _path.join(__dirname, 'fixtures', 'EmptyWorld.java')
        )

      it 'returns an empty linter-message-object', ->
        result = {}
        expect(JSON.stringify(@linter.lint(@texteditor)))
          .toEqual(JSON.stringify(result))
