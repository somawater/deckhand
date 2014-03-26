Deckhand.app.directive 'dhFieldEditor', [
  '$compile', 'Model', '$log', 'AlertService', '$timeout', 'Cards', 'ModalEditor', '$upload'
  ($compile, Model, $log, AlertService, $timeout, Cards, ModalEditor, $upload) ->

    updateValue = (scope, value) ->
      $log.debug "#{scope.previousValue} => #{value}"
      params =
        id: scope.item.id
        non_file_params:
          model: scope.item._model
          form: {}
      params.non_file_params.form[scope.name] = value
      Model.update params, null, ModalEditor.processResponse, (response) ->
        scope.item[scope.name] = scope.previousValue
        AlertService.add 'danger', (response.data?.error or 'The change was not saved')

    link = (scope, element, attrs, dhField) ->
      element.html(getTemplate(scope, attrs))

      $compile(element.contents())(scope)

      fieldElement = element.children().first()

      scope.$on 'startEditing', ->
        $log.debug "startEditing: #{scope.editType}"

        unless scope.setupRanOnce
          scope.setupRanOnce = true
          switch scope.editType
            when 'text'
              setupTextInputHandlers(scope, fieldElement, dhField)
            when 'select'
              setupSelectInputHandlers(scope, element, dhField)

        switch scope.editType
          when 'text', 'select'
            scope.previousValue = scope.item[scope.name]
            $timeout (-> fieldElement[0].focus()), 20
          when 'upload'
            $timeout ->
              fieldElement[0].click()
              dhField.stopEditing()

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

      scope.onCheckboxChange = ->
        updateValue scope, scope.item[scope.name]

    setupTextInputHandlers = (scope, element, dhField) ->
      setupDefaultInputHandlers(scope, element, dhField)

    setupSelectInputHandlers = (scope, element, dhField) ->
      setupDefaultInputHandlers(scope, element, dhField)

      element.on 'change', (event) ->
        scope.$apply ->
          newValue = scope.item[scope.name]
          updateValue scope, newValue if newValue != scope.previousValue
          dhField.stopEditing()

    setupDefaultInputHandlers = (scope, element, dhField) ->
      element.on 'keydown', (event) ->
        if event.which is 27 # esc
          @blur()
          scope.$apply ->
            scope.item[scope.name] = scope.previousValue

      element.on 'blur', ->
        scope.$apply ->
          dhField.stopEditing()

      element.on 'keypress', (event) ->
        if event.which is 13 # enter
          @blur()
          scope.$apply ->
            newValue = scope.item[scope.name]
            updateValue scope, newValue if newValue != scope.previousValue

    getTemplate = (scope, attrs) ->
      switch scope.editType
        when 'text'
          "<input class='form-control' type='text' ng-model='item[name]'/>"
        when 'upload'
          "<input type='file' ng-file-select=\"onFileSelect($files)\"/>"
        when 'ckeditor'
          "<textarea></textarea>"
        when 'nested'
          '<span></span>'
        when 'checkbox'
          #TODO not sure why explicit unhide is necesarry
          #"<input type='checkbox' ng-model='item[name]' ng-change=\"onCheckboxChange()\" ng-hide='false'/>"
          "<button type='button' class='btn btn-xs btn-checkbox' ng-class='item[name] ? \"btn-success\" : \"\"'
                   ng-model='item[name]' ng-change=\"onCheckboxChange()\" ng-hide='false'
                   btn-checkbox btn-checkbox-true='true' btn-checkbox-false='false'><span class='glyphicon glyphicon-off'></span></button>"
        when 'select'
          "<select ng-model='item[name]' ng-options='" + attrs.editChoices + "'/>"
        else
          $log.error "edit type \"#{scope.editType}\" not implemented yet"

    {
      require: '^dhField'
      link: link
      restrict: 'E'
      replace: true
      scope:
        item: '='
        name: '='
        editType: '@'
    }
]
