{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'
helpers = require 'atom-linter'
CSON = require 'season'
configFileName = '.linter-javac.cson'

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

      # Classpath
      cp = null

      # Find project config file if it exists.
      {cfg, cfgDir} = @findConfig(wd)
      if cfg?
        # Use the location of the config file as the working directory
        wd = cfgDir if cfgDir?
        # Get classpath configuration if provided
        cp = cfg.classpath if cfg.classpath?

      # Add extra classpath if provided
      cp += path.delimiter + @classpath if @classpath

      # Add environment variable if it exists
      cp += path.delimiter + process.env.CLASSPATH if process.env.CLASSPATH

      args = ['-Xlint:all']
      args = args.concat(['-cp', cp]) if cp?
      args.push filePath
      helpers.exec(@javaExecutablePath, args, {stream: 'stderr', cwd: wd})
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

  findConfig: (d) ->
    # Search for the .linter-javac.cson file starting in the given directory
    # and searching parent directories until it is found, or we go outside the
    # project base directory.
    while atom.project.contains(d) or (d in atom.project.getPaths())
      try
        return { cfg: CSON.readFileSync( path.join(d, configFileName) ), cfgDir: d }
      catch e
        d = path.dirname(d)

    return {cfg: null, cfgDir: null}
