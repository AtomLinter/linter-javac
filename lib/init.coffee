{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'
helpers = require 'atom-linter'
fs = require 'fs'
cpConfigFileName = '.classpath'

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
    require('atom-package-deps').install('linter-javac')
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
      files = @getFilesEndingWith(@getProjectRootDir(), ".java")
      # Classpath
      cp = null

      # Find project config file if it exists.
      cpConfig = @findClasspathConfig(wd)
      if cpConfig?
        # Use the location of the config file as the working directory
        wd = cpConfig.cfgDir
        # Use configured classpath
        cp = cpConfig.cfgCp

      # Add extra classpath if provided
      cp += path.delimiter + @classpath if @classpath

      # Add environment variable if it exists
      cp += path.delimiter + process.env.CLASSPATH if process.env.CLASSPATH

      # Arguments to javac
      args = ['-Xlint:all']
      args = args.concat(['-cp', cp]) if cp?
      args.push.apply(args, files)

      # Execute javac
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

  getProjectRootDir: ->
    return atom.project.rootDirectories[0].path

  getFilesEndingWith: (startPath, endsWith) ->
    foundFiles = []
    if !fs.existsSync(startPath)
      return foundFiles
    files = fs.readdirSync(startPath)
    i = 0
    while i < files.length
      filename = path.join(startPath, files[i])
      stat = fs.lstatSync(filename)
      if stat.isDirectory()
        foundFiles.push.apply(foundFiles, @getFilesEndingWith(filename, endsWith))
      else if filename.indexOf(endsWith, filename.length - (endsWith.length)) >= 0
        foundFiles.push.apply(foundFiles, [filename])
        #Array::push.apply foundFiles, filename
      i++
    return foundFiles


  findClasspathConfig: (d) ->
    # Search for the .classpath file starting in the given directory
    # and searching parent directories until it is found, or we go outside the
    # project base directory.
    while atom.project.contains(d) or (d in atom.project.getPaths())
      try
        result =
          cfgCp: fs.readFileSync( path.join(d, cpConfigFileName), { encoding: 'utf-8' } )
          cfgDir: d
        result.cfgCp = result.cfgCp.trim()
        return result
      catch e
        d = path.dirname(d)

    return null
