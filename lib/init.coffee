{BufferedProcess, CompositeDisposable} = require 'atom'

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
    scope: 'file'
    lintOnFly: false       # Only lint on save
    lint: (textEditor) =>
      return new Promise (resolve, reject) =>
        filePath = textEditor.getPath()
        messages = []
        process = new BufferedProcess
          command: @javaExecutablePath
          args: ['-Xlint:all', filePath]
          stderr: (data) ->
            # Regex to match the entire error/warning message including the caret (^)
            # that points to the location of the issue in the source line.
            regex = /java:(\d+): (error|warning): (.+)\r?\n.*\r?\n( *)\^/g
            while match = regex.exec(data)
              messages.push
                type: match[2],       # Should be "error" or "warning"
                text: match[3],       # The error message
                filePath: filePath,   # Full path to file
                # match[1] contains the line number, and match[4] is the number of
                # spaces before the caret, which is the column number.
                range: [[match[1] - 1, match[4].length], [match[1] - 1, match[4].length + 1]]
          exit: (code) ->
            resolve messages

        process.onWillThrowError ({error, handle}) ->
          atom.notifications.addError "Failed to run #{@javaExecutablePath}",
            detail: "#{error.message}"
            dismissable: true
          handle()
          resolve []
