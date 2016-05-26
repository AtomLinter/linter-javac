# This file contains all dedicated to issue #94
# see: https://github.com/AtomLinter/linter-javac/issues/94

path = require 'path'

_helpers = require path.join(__dirname, '_spec-helpers.coffee')

describe 'linter-javac', ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage 'linter-javac'
      atom.packages.activatePackage 'language-java'

  describe 'when using a symlink-dir as project-base', ->
    beforeEach ->
      java_file = path.join(__dirname, 'sym-fixtures', 'Test.java')
      @linter = require(path.join(__dirname, '..', 'lib', 'init.coffee'))
        .provideLinter()
      waitsForPromise =>
        atom.workspace.open(java_file)
        .then (newtextEditor) =>
          @textEditor = newtextEditor

    it 'shouldn not throw an exception if a file is saved', ->
      @textEditor.setText 'public class Test {}'
      linting = () =>
        return @linter.lint(@textEditor)

      expect(linting).not.toThrow()

  describe 'when using a symlink as a higher directory of the project', ->
    beforeEach ->
      java_file = path.join(
        __dirname, 'sym-fixtures', 'sub-directory', 'Test.java'
      )
      @linter = require(path.join(__dirname, '..', 'lib', 'init.coffee'))
        .provideLinter()
      waitsForPromise =>
        atom.workspace.open(java_file)
        .then (newtextEditor) =>
          @textEditor = newtextEditor

    it 'shouldn not throw an exception if a file is saved', ->
      @textEditor.setText 'public class Test {}'
      linting = () =>
        return @linter.lint(@textEditor)

      expect(linting).not.toThrow()
