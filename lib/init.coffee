{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'

module.exports =

  config:
    javaExecutablePath:
      type: 'string'
      title: 'Path to the javac executable'
      default: 'javac'

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-javac.javaExecutablePath',
      (newValue) =>
        @javaExecutablePath = newValue

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    grammarScopes: ['source.java']
    scope: 'project'
    lintOnFly: false       # Only lint on save
    lint: (textEditor) =>
      return new Promise (resolve, reject) =>
        filePath = textEditor.getPath()
        wd = path.dirname filePath
        lines = []
        process = new BufferedProcess
          command: @javaExecutablePath
          args: ['-Xlint:all', '-cp', wd, filePath]
          stderr: (data) ->
            lines = lines.concat(data.split /\r?\n/)

          exit: (code) ->
            # Regex to match the error/warning line
            regex = /^(.*\.java):(\d+): (error|warning): (.+)/
            # This regex helps to estimate the column number based on the caret (^) location
            caretRegex = /^( *)\^/
            messages = []
            for line in lines
              if line.match regex
                [file, line, type, mess] = line.match(regex)[1..4]
                messages.push
                  type: type,       # Should be "error" or "warning"
                  text: mess,       # The error message
                  filePath: file,   # Full path to file
                  range: [[line - 1, 0], [line - 1, 0]]
              else if line.match caretRegex
                column = line.match(caretRegex)[1].length
                if messages.length > 0
                  messages[messages.length - 1].range[0][1] = column
                  messages[messages.length - 1].range[1][1] = column + 1

            resolve messages

        process.onWillThrowError ({error, handle}) ->
          atom.notifications.addError "Failed to run #{@javaExecutablePath}",
            detail: "#{error.message}"
            dismissable: true
          handle()
          resolve []
