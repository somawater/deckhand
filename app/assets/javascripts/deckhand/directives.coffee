include = require('./lib/include')
moment = require('moment')
scroll = require("scroll")

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

.directive 'dhScrollTo', ->
  (scope, element, attrs) ->
    scope.$on attrs.dhScrollTo, (event, item) ->
      if (item == scope.item)
        scroll.top document.documentElement, element[0].offsetTop,
          duration: 800
          ease: 'outQuint'

.directive 'dhTime', ->
  link = (scope, element, attrs) ->
    scope.$watch 'time', (value) ->
      if value
        time = moment(new Date(value))
        scope.shortTime = time.fromNow()
        element.attr 'title', time.format('MMM Do, YYYY h:mm:ss a Z')
      else
        scope.shortTime = 'never'

  {
    link: link
    scope: {time: '@'}
    restrict: 'E'
    replace: true
    template: '<span title="{{fullTime}}">{{shortTime}}</span>'
  }

.directive 'dhField', [
  'FieldFormatter', '$rootScope', 'ModelConfig', 'Cards', 'ModalEditor'
  (FieldFormatter, $rootScope, ModelConfig, Cards, ModalEditor) ->

    link = (scope, element, attrs) ->
      scope.name = attrs.name
      scope.format = FieldFormatter.format
      scope.substitute = FieldFormatter.substitute
      scope.show = Cards.show

      scope.edit = (type) ->
        switch type
          when 'text', 'upload'
            if !scope.editing
              scope.$broadcast 'startEditing'
              scope.editing = true
          else
            ModalEditor.edit(scope.item, scope.name)

    controller = ['$scope', ($scope) ->
      this.stopEditing = ->
        $scope.editing = false

      return this
    ]

    template = (tElement, tAttrs) ->
      field = ModelConfig.field(tAttrs.model, tAttrs.name, tAttrs.relation)
      value = null

      return '{{format(item, name)}}' unless field

      if field.delegate
        value = "{{format(item[name], '#{field.delegate}')}}"
      else if field.multiline
        value = "{{format(item, name, 'multiline')}}"
      else
        value = "{{format(item, name)}}"

      if field.html or field.multiline
        value = value.replace(/^{{|}}$/g, '')
        output = "<div ng-bind-html=\"#{value}\"></div>"

      else if field.thumbnail
        output = "<a target='_blank' ng-href=\"#{value}\"><img ng-src=\"#{value}\"</a>"

      else if field.link_to
        output = "<a target='_blank' ng-href=\"{{substitute(item, name, '#{field.link_to}')}}\">
          #{value}</a>"

      else if field.type == 'relation'
        output = "<a ng-click=\"show(item[name]._model, item[name].id)\">#{value}</a>"

      else if field.type == 'time'
        output = "<dh-time time='#{value}'/>"

      else
        output = value

      if field.editable
        editType = if field.editable.with == 'ckeditor'
          'ckeditor'
        else if field.editable.nested
          'nested'
        else if field.type == 'file'
          'upload'
        else
          'text'

        output =
          "<div class='dh-field editable'
                ng-click=\"edit('#{editType}')\"
                ng-class='{editing: editing, image: #{field.thumbnail}}'>
            <i class='glyphicon glyphicon-pencil edit-icon'></i>
            <div ng-hide='editing'>#{output}</div>
            <dh-field-editor ng-show='editing' item='item' name='name' edit-type=\"#{editType}\"/>
          </div>"

      else
        output =
          "<div class='dh-field' ng-class='{image: #{field.thumbnail}}'>
            #{output}
          </div>"

      return output

    {
      link: link
      restrict: 'E'
      replace: true
      scope: {item: '='}
      template: template
      controller: controller
    }
]

.directive 'dhFieldEditor', [
  'Model', '$log', 'AlertService', '$timeout', 'Cards', 'ModalEditor', '$upload'
  (Model, $log, AlertService, $timeout, Cards, ModalEditor, $upload) ->

    update = (scope, value) ->
      $log.debug "#{scope.originalValue} => #{value}"
      params =
        id: scope.item.id
        non_file_params:
          model: scope.item._model
          form: {}
      params.non_file_params.form[scope.name] = value
      Model.update params, null, ModalEditor.processResponse, (response) ->
        scope.item[scope.name] = scope.originalValue
        AlertService.add 'danger', (response.data?.error or 'The change was not saved')

    link = (scope, element, attrs, dhField) ->
      scope.editType = attrs.editType

      scope.$on 'startEditing', ->
        $log.debug "startEditing: #{scope.editType}"
        unless scope.setup
          scope.setup = true
          switch scope.editType
            when 'text'
              setupTextEditing(scope, element, dhField)

        switch scope.editType
          when 'text'
            $timeout -> element[0].focus()
          when 'upload'
            $timeout ->
              element[0].click()
              $timeout -> dhField.stopEditing()

      scope.onFileSelect = ($files) ->
        $upload.upload(
          url: Deckhand.showPath
          method: 'PUT'
          fileFormDataName: "form[#{scope.name}]"
          file: $files[0]
          data:
            id: scope.item.id
            model: scope.item._model
        ).success(ModalEditor.processResponse)
        .error (response) ->
          AlertService.add 'danger', (response.data?.error or 'The upload failed')

    setupTextEditing = (scope, element, dhField) ->
      unwatch = scope.$watch 'item[name]', (value) ->
        scope.originalValue = value
        unwatch()

      element.on 'keydown', (event) ->
        if event.which is 27 # esc
          scope.$apply -> dhField.stopEditing()
        true

      element.on 'blur', (event) ->
        scope.$apply ->
          scope.item[name] = scope.originalValue
          dhField.stopEditing()

      element.on 'keypress', (event) ->
        if event.which is 13 # enter
          scope.$apply ->

            newValue = scope.item[scope.name]
            update scope, newValue if newValue != scope.originalValue

    template = (tElement, tAttrs) ->
      switch tAttrs.editType
        when 'text'
          "<input class='form-control' type='text' ng-model='item[name]' autofocus/>"
        when 'upload'
          "<input type='file' ng-file-select=\"onFileSelect($files)\"/>"
        when 'ckeditor'
          "<textarea></textarea>"
        else
          $log.error "edit type \"#{tAttrs.editType}\" not implemented yet"

    {
      require: '^dhField'
      link: link
      restrict: 'E'
      replace: true
      scope: {item: '=', name: '='}
      template: template
    }
]
