include = require('../lib/include')

Deckhand.app.directive 'ckeditor', ->
  link = (scope, element, attrs, ngModel) ->
    editor = null

    setupEditor = ->
      editor = CKEDITOR.replace(element[0])

      # the editor may have been loaded before the form data
      scope.$watch attrs.ngModel, (value) ->
        if (value)
          setTimeout (-> editor.setData value), 0

      editor.on 'change', ->
        ngModel.$setViewValue(editor.getData())

    if window.CKEDITOR
      setupEditor()
    else if Deckhand.ckeditor != ''
      include Deckhand.ckeditor, setupEditor

  {require: 'ngModel', link: link}
