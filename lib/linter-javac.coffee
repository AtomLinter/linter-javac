{exec, child} = require 'child_process'
linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
fs = require 'fs'
path = require 'path'

class LinterJavac extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  # TODO: research if there are other java resources must be added
  @syntax: 'source.java'

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  # arg : '-J-Duser.country=US' will fix the regex match problem on non-english os -- by luo cheng
  cmd: 'javac -Xlint:all -J-Duser.country=US'

  linterName: 'javac'

  # A regex pattern used to extract information from the executable's output.
  regex: 'java:(?<line>\\d+): ((?<error>error)|(?<warning>warning)): (?<message>.+)[\\n\\r]'

  constructor: (editor) ->
    super(editor)

    #include jar libs path to javac
    jarLibs = @findJarLibs()
    if jarLibs.length > 0
      pathJoinSep=':'
      if process.platform == "win32"
        pathJoinSep=';'
      @cmd = @cmd + ' -Djava.ext.dirs=' + (jarLibs.join pathJoinSep)

    atom.config.observe 'linter-javac.javaExecutablePath', =>
      @executablePath = atom.config.get 'linter-javac.javaExecutablePath'

  destroy: ->
    atom.config.unobserve 'linter-javac.javaExecutablePath'

  errorStream: 'stderr'
  
  findJarLibs: ->
    jarLibs = []
    searchJarLibs = (projectPath) ->
      if fs.statSync(projectPath).isDirectory()
        files = fs.readdirSync(projectPath);
        files.forEach (file) ->
          searchJarLibs path.join(projectPath, file);
      else
        if (projectPath.indexOf '.jar') == (projectPath.length-4)
          libDir = path.dirname projectPath
          if (jarLibs.indexOf libDir) < 0
            jarLibs.push libDir

    searchJarLibs atom.project.path
    console.log 'jar libs : ', jarLibs
    jarLibs

module.exports = LinterJavac
