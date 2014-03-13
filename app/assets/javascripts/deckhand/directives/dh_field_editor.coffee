Deckhand.app.directive 'dhFieldEditor', [
  'Model', '$log', 'AlertService', '$timeout', 'Cards', 'ModalEditor', '$upload'
  (Model, $log, AlertService, $timeout, Cards, ModalEditor, $upload) ->

    updateText = (scope, value) ->
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
      scope.editType = attrs.editType

      scope.$on 'startEditing', ->
        $log.debug "startEditing: #{scope.editType}"

        unless scope.setupRanOnce
          scope.setupRanOnce = true
          switch scope.editType
            when 'text'
              setupTextInputHandlers(scope, element, dhField)

        switch scope.editType
          when 'text'
            scope.previousValue = scope.item[scope.name]
            $timeout (-> element[0].focus()), 20
          when 'upload'
            $timeout ->
              element[0].click()
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

    setupTextInputHandlers = (scope, element, dhField) ->
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
            updateText scope, newValue if newValue != scope.previousValue

    template = (tElement, tAttrs) ->
      switch tAttrs.editType
        when 'text'
          "<input class='form-control' type='text' ng-model='item[name]'/>"
        when 'upload'
          "<input type='file' ng-file-select=\"onFileSelect($files)\"/>"
        when 'ckeditor'
          "<textarea></textarea>"
        when 'nested'
          '<span></span>'
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