# This file contains all dedicated to issue #94
# see https://github.com/AtomLinter/linter-javac/issues/34

_fs = require 'fs'
_path = require 'path'


_helpers = require _path.join(__dirname, '_spec-helpers.coffee')


describe 'linter-javac', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage 'linter-javac'
      atom.packages.activatePackage 'language-java'

  describe 'when parsing chinese javac-output', ->
    beforeEach ->
      # This file is actually not important, we just open any textEditor
      java_file = _path.join(__dirname, 'fixtures', 'BrokenWorld.java')
      @linter_output = _fs.readFileSync(
        _path.join(__dirname, 'fixtures', 'chinese_javac_output.txt'),
        'utf8'
      )

      waitsForPromise =>
        atom.workspace.open(java_file)
        .then (newTextEditor) =>
          @textEditor = newTextEditor
          @linterBase = require(
            _path.join(__dirname, '..', 'lib', 'init.coffee')
          )

    it 'should detect all errors and warnings', ->
      expect(@linterBase.parse(@linter_output, @textEditor).length).toBe(4)

    it 'should translate the first message-type to error', ->
      firstMessage = @linterBase.parse(@linter_output, @textEditor)[0]
      expect(firstMessage.type).toMatch('error')

    it 'should translate the last message-type to warning', ->
      firstMessage = @linterBase.parse(@linter_output, @textEditor)[3]
      expect(firstMessage.type).toMatch('warning')
