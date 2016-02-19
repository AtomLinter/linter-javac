# This file contains all specs to ensure the base-functionality of
# this plugin.

_path = require 'path'


_helpers = require _path.join(__dirname, '_spec-helpers.coffee')


describe 'linter-javac', ->
  beforeEach ->
    #atom.workspace.destroyActivePaneItem
    waitsForPromise ->
      atom.packages.activatePackage 'linter-javac'
      atom.packages.activatePackage 'language-java'



  describe 'when using a faulty java-source file', ->
    beforeEach ->
      javaFile = _path.join(__dirname, 'fixtures', 'BrokenWorld.java')
      waitsForPromise =>
        atom.workspace.open(javaFile)
        .then (whatever) =>
          @texteditor = whatever
          @linter = require(_path.join(__dirname, '..', 'lib', 'init.coffee'))
          .provideLinter()

    it 'returns at least 8 messages in the linter-message-object', ->
      waitsForPromise( =>
        @linter.lint(@texteditor).then( (messages) ->
          expect(messages.length).toBeGreaterThan(7)
        )
      )



  describe 'when using a correct java-source file', ->
    beforeEach ->
      javaFile = _path.join(__dirname, 'fixtures', 'HelloWorld.java')
      waitsForPromise =>
        atom.workspace.open(javaFile)
        .then (whatever) =>
          @texteditor = whatever
          @linter = require(_path.join(__dirname, '..', 'lib', 'init.coffee'))
          .provideLinter()

    it 'returns an empty linter-message-object', ->
      result = {}
      expect(JSON.stringify(@linter.lint(@texteditor)))
        .toEqual(JSON.stringify(result))



  describe 'when using an empty java-source file', ->
    beforeEach ->
      javaFile = _path.join(__dirname, 'fixtures', 'EmptyWorld.java')
      waitsForPromise =>
        atom.workspace.open(javaFile)
        .then (whatever) =>
          @texteditor = whatever
          @linter = require(_path.join(__dirname, '..', 'lib', 'init.coffee'))
          .provideLinter()

    it 'returns an empty linter-message-object', ->
      result = {}
      expect(JSON.stringify(@linter.lint(@texteditor)))
        .toEqual(JSON.stringify(result))
