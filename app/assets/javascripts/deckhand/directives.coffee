include = require('./lib/include')
moment = require('moment')

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

Deckhand.app.directive 'dhTime', ->
  link = (scope, element, attrs) ->
    scope.$watch 'time', (value) ->
      time = if value then new Date(value) else null
      scope.shortTime = if time then moment(time).fromNow() else 'never'
      scope.fullTime = if time then moment(time).format('MMM Do, YYYY h:mm:ss a Z') else 'never'
      scope.shown = scope.shortTime

  {
    link: link
    scope: {time: '@'}
    restrict: 'E'
    replace: true
    template: '<span title="{{fullTime}}">{{shortTime}}</span>'
  }

Deckhand.app.directive 'dhField', ['FieldFormatter', '$rootScope', 'ModelConfig',
  (FieldFormatter, $rootScope, ModelConfig) ->

    link = (scope, element, attrs) ->
      scope.name = attrs.name
      scope.format = FieldFormatter.format
      scope.substitute = FieldFormatter.substitute
      scope.showCard = (model, id) -> $rootScope.showCard(model, id)
      scope.edit = (name, options) -> scope.$parent.edit(name, options)

    template = (tElement, tAttrs) ->
      field = ModelConfig.field(tAttrs.model, tAttrs.name, tAttrs.relation)
      value = null

      return '{{format(item, name)}}' unless field

      if field.delegate
        value = "{{format(item[name], '"+field.delegate+"')}}"
      else if field.multiline
        value = "{{format(item, name, 'multiline')}}"
      else
        value = "{{format(item, name)}}"

      if field.html or field.multiline
        value = value.replace(/^{{|}}$/g, '')
        output = "<div ng-bind-html=\"'#{value}'\"></div>"

      else if field.thumbnail
        output = "<a target='_blank' ng-href=\"'#{value}'\"><img ng-src=\"'#{value}'\"</a>"

      else if field.link_to
        output = "<a target='_blank' ng-href=\"{{substitute(item, name, '#{field.link_to}')}}\">
          #{value}</a>"

      else if field.type == 'relation'
        output = "<a ng-click=\"showCard(item[name]._model, item[name].id)\">#{value}</a>"

      else if field.type == 'time'
        output = "<dh-time time='#{value}'/>"

      else
        output = value

      if field.editable
        output = "<div class='editable'
          ng-click=\"edit(name, '#{JSON.stringify(field.editable)}')\">
          <i class='glyphicon glyphicon-pencil edit-icon'></i>
          #{output}</div>"

      return output

    {
      link: link
      restrict: 'E'
      scope: {item: '='}
      template: template
    }
]