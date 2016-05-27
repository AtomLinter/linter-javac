{Directory, CompositeDisposable} = require 'atom'
# require statements were moved into the provideLinter-function
_os = null
path = null
helpers = null
voucher = null
fs = null

module.exports =
  activate: (state) ->
    # state-object as preparation for user-notifications
    @state = if state then state or {}
    # language-patterns
    @patterns =
      en:
        detector: /^\d+ (error|warning)s?$/gm
        pattern: /^(.*\.java):(\d+): (error|warning): (.+)/
        translation:
          'error': 'error'
          'warning': 'warning'
      zh:
        detector: /^\d+ 个?(错误|警告)$/gm
        pattern: /^(.*\.java):(\d+): (错误|警告): (.+)/
        translation:
          '错误': 'error'
          '警告': 'warning'

    require('atom-package-deps').install('linter-javac')
    @subscriptions = new CompositeDisposable
    @subscriptions.add(
      atom.config.observe 'linter-javac.javacExecutablePath',
        (newValue) =>
          @javaExecutablePath = newValue.trim()
    )
    @subscriptions.add(
      atom.config.observe 'linter-javac.additionalClasspaths',
        (newValue) =>
          @classpath = newValue.trim()
    )
    @subscriptions.add(
      atom.config.observe 'linter-javac.additionalJavacOptions',
        (newValue) =>
          trimmedValue = newValue.trim()
          if trimmedValue
            @additionalOptions = trimmedValue.split(/\s+/)
          else
            @additionalOptions = []
      )
    @subscriptions.add(
      atom.config.observe 'linter-javac.classpathFilename',
        (newValue) =>
          @classpathFilename = newValue.trim()
    )
    @subscriptions.add(
      atom.config.observe 'linter-javac.sourcepathFilename',
        (newValue) =>
          @sourcepathFilename = newValue.trim()
    )
    @subscriptions.add(
      atom.config.observe 'linter-javac.javacArgsFilename',
        (newValue) =>
          @javacArgsFilename = newValue.trim()
    )
    @subscriptions.add(
      atom.config.observe 'linter-javac.verboseLogging',
        (newValue) =>
          @verboseLogging = (newValue == true)
    )

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    return @state

  provideLinter: ->
    # doing requirement here is lowering load-time
    if _os == null
      _os = require 'os'
      path = require 'path'
      helpers = require 'atom-linter'
      voucher = require 'voucher'
      fs = require 'fs'
      @_log 'requiring modules finished.'

    @_log 'providing linter, examining javac-callability.'

    grammarScopes: ['source.java']
    scope: 'project'
    lintOnFly: false       # Only lint on save

    lint: (textEditor) =>
      filePath = textEditor.getPath()
      wd = path.dirname filePath
      searchDir = @getProjectRootDir() || path.dirname filePath

      # Classpath
      cp = ''

      # Sourcepath - this is a fair default for many Java projects
      sp = 'src/main/java/'

      @_log 'starting to lint.'

      # Find project config file if it exists.
      cpConfig = @findConfigFile(wd, @classpathFilename)
      if cpConfig?
        # Use the location of the config file as the working directory
        wd = cpConfig.dir
        # Use configured classpath
        cp = cpConfig.content
        # Use config file location to import correct files
        searchDir = wd

      spConfig = @findConfigFile(wd, @sourcepathFilename)
      if spConfig?
        sp = spConfig.content

      # Add extra classpath if provided
      cp += path.delimiter + @classpath if @classpath

      # Add environment variable if it exists
      cp += path.delimiter + process.env.CLASSPATH if process.env.CLASSPATH

      @_log 'start searching java-files with "', searchDir, '" as search-directory.'

      lstats = fs.lstatSync searchDir

      # Arguments to javac
      args = ['-Xlint:all']
      args = args.concat(['-cp', cp]) if cp
      args = args.concat(['-sourcepath', sp]) if sp

      # add additional options to the args-array
      if @additionalOptions.length > 0
        args = args.concat @additionalOptions
        @_log 'adding', @additionalOptions.length, 'additional javac-options.'

      @_log 'collected the following arguments:', args.join(' ')

      # add javac argsfile if filename has been configured
      if @javacArgsFilename
        args.push('@' + @javacArgsFilename)
        @_log 'adding', @javacArgsFilename, 'as argsfile.'

      # Append the file to actually lint
      args.push(filePath)

      # Execute javac
      helpers.exec(@javaExecutablePath, args, {stream: 'stderr', cwd: wd})
        .then (val) =>
          @_log 'parsing:\n', val
          @parse(val, textEditor)

  parse: (javacOutput, textEditor) ->
    languageCode = @_detectLanguageCode javacOutput
    messages = []
    if languageCode
      # This regex helps to estimate the column number based on the
      #   caret (^) location.
      @caretRegex ?= /^( *)\^/
      # Split into lines
      lines = javacOutput.split /\r?\n/

      for line in lines
        match = line.match @patterns[languageCode].pattern
        if !!match
          [file, lineNum, type, mess] = match[1..4]
          lineNum-- # Fix range-beginning
          messages.push
            type: @patterns[languageCode].translation[type] || 'info'
            text: mess       # The error message
            filePath: file   # Full path to file
            range: [[lineNum, 0], [lineNum, 0]] # Set range-beginnings
        else
          match = line.match @caretRegex
          if messages.length > 0 && !!match
            column = match[1].length
            lastIndex = messages.length - 1
            messages[lastIndex].range[0][1] = column
            messages[lastIndex].range[1][1] = column + 1
      @_log 'returning', messages.length, 'linter-messages.'

    return messages

  getProjectRootDir: ->
    textEditor = atom.workspace.getActiveTextEditor()
    if !textEditor || !textEditor.getPath()
      # default to building the first one if no editor is active
      if not atom.project.getPaths().length
        return false

      return atom.project.getPaths()[0]

    # otherwise, build the one in the root of the active editor
    return atom.project.getPaths()
      .sort((a, b) -> (b.length - a.length))
      .find (p) ->
        realpath = fs.realpathSync(p)
        # TODO: The following fails if there's a symlink in the path
        return textEditor.getPath().substr(0, realpath.length) == realpath

  findConfigFile: (directory, filename) ->
    # Search for the config file starting in the given directory
    # and searching parent directories until it is found, or we go outside the
    # project base directory.
    while atom.project.contains(directory) or (directory in atom.project.getPaths())
      try
        file = path.join directory, filename
        result =
          content: fs.readFileSync(file, { encoding: 'utf-8' }).trim()
          dir: directory
        return result
      catch e
        directory = path.dirname(directory)

    return null

  _detectLanguageCode: (javacOutput) ->
    @_log 'detecting languages'
    for language, pattern of @patterns
      if javacOutput.match(pattern.detector)
        @_log 'detected the following language-code:', language
        return language

    return false

  _log: (msgs...) ->
    if (@verboseLogging && msgs.length > 0)
      javacPrefix = 'linter-javac: '
      console.log javacPrefix + msgs.join(' ')
