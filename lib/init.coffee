{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'
helpers = require 'atom-linter'

module.exports =
  config:
    javaExecutablePath:
      type: 'string'
      title: 'Path to the javac executable'
      default: 'javac'
    classpath:
      type: 'string'
      title: "Extra classpath for javac"
      default: ''

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-javac.javaExecutablePath',
      (newValue) =>
        @javaExecutablePath = newValue
    @subscriptions.add atom.config.observe 'linter-javac.classpath',
      (newValue) =>
        @classpath = newValue.trim()

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    grammarScopes: ['source.java']
    scope: 'project'
    lintOnFly: false       # Only lint on save
    lint: (textEditor) =>
      filePath = textEditor.getPath()
      wd = path.dirname filePath
      # Use the text editor's working directory as the classpath, and add user's
      # classpath (if it exists) and/or environment variable
      cp = wd
      cp += path.delimiter + @classpath if @classpath
      cp += path.delimiter + process.env.CLASSPATH if process.env.CLASSPATH
      args = ['-Xlint:all', '-cp', cp, filePath]
      
      helpers.exec(@javaExecutablePath, args, {stream: 'stderr'})
        .then (val) => return @parse(val, textEditor)

  parse: (javacOutput, textEditor) ->
    # Regex to match the error/warning line
    errRegex = /^(.*\.java):(\d+): ([\w \-]+): (.+)/
    # This regex helps to estimate the column number based on the
    #   caret (^) location.
    caretRegex = /^( *)\^/
    # Split into lines
    lines = javacOutput.split /\r?\n/
    messages = []
    for line in lines
      if line.match errRegex
        [file, lineNum, type, mess] = line.match(errRegex)[1..4]
        messages.push
          type: type       # Should be "error" or "warning"
          text: mess       # The error message
          filePath: file   # Full path to file
          range: [[lineNum - 1, 0], [lineNum - 1, 0]]
      else if line.match caretRegex
        column = line.match(caretRegex)[1].length
        if messages.length > 0
          messages[messages.length - 1].range[0][1] = column
          messages[messages.length - 1].range[1][1] = column + 1
    return messages
