module.exports =
  config:
    javaExecutablePath:
      type: 'string'
      default: ''

  activate: ->
    console.log 'activate linter-javac'
