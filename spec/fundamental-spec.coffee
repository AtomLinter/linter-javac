# This file contains all specs to ensure the fundamental functionality of
# this plugin.

_path = require 'path'


_helpers = require _path.join(__dirname, '_helpers.coffee')


describe 'linter-javac', ->
  describe 'provideLinter()', ->
    beforeEach ->
      @linter = require _path.join(__dirname, '..', 'lib', 'init.coffee')
      @texteditor = _helpers.texteditorFactory _path.join(__dirname, 'fixtures')

    describe 'when using a faulty java-source file', ->
      it 'returns all bugs in the linter-message-array', ->
        expect(true).toBe false

    describe 'when using a correct java-source file', ->
      it 'returns an empty linter-message-array', ->
        expect(true).toBe false

    describe 'when using an empty java-source file', ->
      it 'returns an empty linter-message-array', ->
        expect(true).toBe false
