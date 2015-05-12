{CompositeDisposable} = require 'atom'
Comb = require 'csscomb'

module.exports = AtomCssToggle =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles the code
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-toggle:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-toggle:collapse': => @collapse()
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-toggle:extend': => @extend()
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-toggle:config-collapse': => @configureCollapse()
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-toggle:config-extend': => @configureExtend()

  deactivate: ->
    @subscriptions.dispose()

  config: (direction) ->
    cssTogglePackage = atom.packages.getLoadedPackage 'css-toggle'

    require cssTogglePackage.path + "/configs/.#{direction}.csscomb.json"

  comb: (direction) ->
    try
      comb = new Comb @config(direction)
      editor = atom.workspace.getActiveTextEditor()

      text = editor.getSelectedText()

      if ! text.length
        editor.selectAll()
        text = editor.getSelectedText()

      text = comb.processString(text, {
        syntax: editor.getGrammar().name.toLowerCase()
      })
      editor.setTextInBufferRange(editor.getSelectedBufferRange(), text)
      atom.notifications.addSuccess('Code style toggled with CSS Toggle')
      # else
      #   filePath = atom.workspace.activePaneItem.getPath()
      #   comb.processPath(filePath)
      #   atom.notifications.addInfo('File style toggled with CSS Toggle')
    catch error
      atom.notifications.addError(error.message)
      console.log error

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    range = editor.getSelectedBufferRange()
    selection = editor.getLastSelection()
    selection.selectLine(num) for num in range.getRows()

    console.log range.isEmpty()
    console.log range.isSingleLine()
    console.log range.getRows()

    text = editor.getSelectedText()
    console.log text
    console.log text.match(///^([ \t]*[^{}\n]+\{.*\}\s*)+$///i)

    # if text.match(///^([ \t]*[^{}\n]+\{.*\}\s*)+$///i)
    if text.match(///\{\s*\n///i)
      @collapse()
    else
      @extend()

  collapse: ->
    @comb('collapse')

  extend: ->
    @comb('extend')

  configure: (direction) ->
    cssTogglePackage = atom.packages.getLoadedPackage 'css-toggle'

    atom.workspace.open cssTogglePackage.path + "/configs/.#{direction}.csscomb.json"

  configureCollapse: ->
    @configure('collapse')

  configureExtend: ->
    @configure('extend')
