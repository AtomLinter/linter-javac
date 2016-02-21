{Directory, CompositeDisposable} = require 'atom'
_os = null
path = null
helpers = null
voucher = null
fs = null

cpConfigFileName = '.classpath'

module.exports =
  # coffeelint: disable=max_line_length
  config:
    javacExecutablePath:
      type: 'string'
      description: 'Path to the javac executable. This setting will be used to
      call the java-compiler. The entered value should be immediately callable
      on commandline. Example: `C:\\Program Files\\Java\\jdk1.6.0_16\\bin\\javac.exe`.
      Keep in mind that placeholders like `~` do **not** work. If your
      [path-variable](https://en.wikipedia.org/wiki/PATH_\(variable\))
      is set properly it should not be necessary to change the default.'
      default: 'javac'
    additionalClasspaths:
      type: 'string'
      description: 'Additional classpaths to be used (for the `-cp`-option)
      when calling javac, separate multiple paths using the right
      path-delimiter for your os (`:`/`;`).
      Be aware that existing classpath-definitions from
      the environment variable "CLASSPATH" will be merged into the argument,
      as well as the content of your optional
      [`.classpath`-files](https://atom.io/packages/linter-javac).
      Example: `/path1:/path2` will become `javac -cp :/path1:/path2`.
      Keep in mind that placeholders like `~` do **not** work.'
      default: ''
    additionalJavacOptions:
      type: 'string'
      default: ''
      description: 'Your additional options will be inserted between
      the javac-command and the sourcefiles. Example: `-d /root/class-cache`
      will become `javac -Xlint:all -d /root/class-cache .../Test.java`
      take a look to the
      [javac-docs](http://docs.oracle.com/javase/8/docs/technotes/tools/unix/javac.html)
      for further information on valid options. Keep in mind that placeholders
      like `~` do **not** work.'


  activate: (state) ->
    # state-object as preparation for user-notifications
    @state = if state then state or {}
    @state = {}

    require('atom-package-deps').install('linter-javac')
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-javac.javacExecutablePath',
      (newValue) =>
        @javaExecutablePath = newValue.trim()
    @subscriptions.add atom.config.observe 'linter-javac.additionalClasspaths',
      (newValue) =>
        @classpath = newValue.trim()
    @subscriptions.add atom.config.observe 'linter-javac.additionalJavacOptions',
      (newValue) =>
        trimmedValue = newValue.trim()
        if trimmedValue
          @additionalOptions = trimmedValue.split(/\s+/)
        else
          @additionalOptions = []

  # coffeelint: enable=max_line_length

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    return @state

  provideLinter: ->
    if _os == null
      _os = require 'os'
      path = require 'path'
      helpers = require 'atom-linter'
      voucher = require 'voucher'
      fs = require 'fs'

    grammarScopes: ['source.java']
    scope: 'project'
    lintOnFly: false       # Only lint on save
    lint: (textEditor) =>
      filePath = textEditor.getPath()
      wd = path.dirname filePath
      searchDir = @getProjectRootDir()
      # Classpath
      cp = ''

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
          args = args.concat(['-cp', cp]) if cp

          # add additional options to the args-array
          if @additionalOptions.length > 0
            args = args.concat @additionalOptions

          args.push.apply(args, files)




          # TODO: remove this quick fix
          # count the size of expected execution-command
          # see issue #58 for further details
          cliLimit = if _os.platform() == 'win32' then 7900 else 130000
          expectedCmdSize = @javaExecutablePath.length
          sliceIndex = 0
          for arg in args
            expectedCmdSize++ # add prepending space
            if (typeof arg) == 'string'
              expectedCmdSize += arg.length
            else
              expectedCmdSize += arg.toString().length
            if expectedCmdSize < cliLimit
              sliceIndex++

          if sliceIndex < (args.length - 1)
            # coffeelint: disable=max_line_length
            console.warn """
linter-javac: The lint-command is presumed to break the limit of #{cliLimit} characters on the #{_os.platform()}-platform.
Dropping #{args.length - sliceIndex} source files, as a result javac may not resolve all dependencies.
"""
            # coffeelint: enable=max_line_length
            args.push(filePath)
            args = args.slice(0, sliceIndex)




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
