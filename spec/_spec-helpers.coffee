# Helpers for the specs of this plugin

# Generates a primitive stub of the atom-texteditor-object to provide a path
this.texteditorFactory = (texteditorPath) ->
  getPath: () ->
    texteditorPath
