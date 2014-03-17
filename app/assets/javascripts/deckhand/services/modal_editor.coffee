qs = require("querystring")

Deckhand.app.factory 'ModalEditor', [
  'ModelConfig', '$modal', 'Cards', 'AlertService', '$filter'
  (ModelConfig, $modal, Cards, AlertService, $filter) ->

    processResponse = (response) =>
      AlertService.add "success", response.success
      AlertService.add "warning", response.warning
      AlertService.add "info", response.info
      Cards.refresh(item) for item in response.changed

      result = response.result
      Cards.show result._model, result.id if result and result._model

    {
      act: (action, item) ->
        formParams = {act: action, type: "action"}

        if item
          formParams.model = item._model
          title = "#{item._label}: #{$filter('readableMethodName')(action)}"
        else
          title = $filter("readableMethodName")(action)

        url = Deckhand.templatePath + "?" + qs.stringify(formParams)

        modalInstance = $modal.open(
          templateUrl: url
          controller: "ModalFormCtrl"
          resolve:
            context: ->
              item: item
              title: title
              formParams: formParams
              verb: "act"
        )
        modalInstance.result.then processResponse

      edit: (item, name) ->
        url = null
        if name
          options = ModelConfig.field(item._model, name).editable
          nested = options.nested
          item = item[name] if nested
        else
          nested = false

        formParams = {type: 'edit', model: item._model}

        if name and not nested # single-field editing
          formParams.edit_fields = [name]

          if options?.with == 'ckeditor'
            url = 'modal-ckeditor'
          else
            url = Deckhand.templatePath + "?" + qs.stringify(formParams)

          # this is a workaround for an issue with Angular where it doesn't
          # stringify parameters the same way that Node's querystring does,
          # e.g. http://stackoverflow.com/questions/18318714/angularjs-resource-cannot-pass-array-as-one-of-the-parameters
          formParams["edit_fields[]"] = formParams.edit_fields
          delete formParams.edit_fields
        else # all editable fields at once
          url = Deckhand.templatePath + "?" + qs.stringify(formParams)

        $modal.open(
          templateUrl: url
          controller: "ModalFormCtrl"
          resolve:
            context: ->
              item: item
              title: "edit"
              formParams: formParams
              verb: "update"
              name: name
        ).result.then processResponse

      processResponse: processResponse
    }
]
