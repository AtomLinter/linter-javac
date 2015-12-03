{Directory, CompositeDisposable} = require 'atom'
path = require 'path'
helpers = require 'atom-linter'
voucher = require 'voucher'
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
    require('atom-package-deps').install()
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
      searchDir = @getProjectRootDir()
      # Classpath
      cp = null

      # Find project config file if it exists.
      cpConfig = @findClasspathConfig(wd)
      if cpConfig?
        # Use the location of the config file as the working directory
        wd = cpConfig.cfgDir
        # Use configured classpath
        cp = cpConfig.cfgCp
        # Use config file location to import correct files
        searchDir = wd

      # Add extra classpath if provided
      cp += path.delimiter + @classpath if @classpath

      # Add environment variable if it exists
      cp += path.delimiter + process.env.CLASSPATH if process.env.CLASSPATH

      atom.project.repositoryForDirectory(new Directory(searchDir))
        .then (repo) =>
          @getFilesEndingWith searchDir, '.java', repo?.isPathIgnored.bind(repo)
        .then (files) =>
          # Arguments to javac
          args = ['-Xlint:all']
          args = args.concat(['-cp', cp]) if cp?
          args.push.apply(args, files)

          # Execute javac
          helpers.exec(@javaExecutablePath, args, {stream: 'stderr', cwd: wd})
            .then (val) =>
              @parse(val, textEditor)

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
    textEditor = atom.workspace.getActiveTextEditor()
    if !textEditor || !textEditor.getPath()
      # default to building the first one if no editor is active
      if (0 == atom.project.getPaths().length)
        return false

      return atom.project.getPaths()[0]

    # otherwise, build the one in the root of the active editor
    return atom.project.getPaths()
      .sort((a, b) -> (b.length - a.length))
      .find (p) ->
        realpath = fs.realpathSync(p)
        return textEditor.getPath().substr(0, realpath.length) == realpath

  getFilesEndingWith: (startPath, endsWith, ignoreFn) ->
    foundFiles = []
    folderFiles = []
    voucher fs.readdir, startPath
      .then (files) ->
        folderFiles = files
        Promise.all files.map (f) ->
          filename = path.join startPath, f
          voucher fs.lstat, filename
      .then (fileStats) =>
        mapped = fileStats.map (stats, i) =>
          filename = path.join startPath, folderFiles[i]
          if ignoreFn?(filename)
            return undefined
          else if stats.isDirectory()
            return @getFilesEndingWith filename, endsWith, ignoreFn
          else if filename.endsWith(endsWith)
            return [ filename ]

        Promise.all(mapped.filter(Boolean))

      .then (fileArrays) ->
        [].concat.apply([], fileArrays)

  findClasspathConfig: (d) ->
    # Search for the .classpath file starting in the given directory
    # and searching parent directories until it is found, or we go outside the
    # project base directory.
    while atom.project.contains(d) or (d in atom.project.getPaths())
      try
        file = path.join d, cpConfigFileName
        result =
          cfgCp: fs.readFileSync(file, { encoding: 'utf-8' })
          cfgDir: d
        result.cfgCp = result.cfgCp.trim()
        return result
      catch e
        d = path.dirname(d)

    return null
