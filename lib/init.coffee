module.exports =
  config:
    javaExecutablePath:
      type: 'string'
      default: null

  activate: ->
    console.log 'activate linter-javac'
