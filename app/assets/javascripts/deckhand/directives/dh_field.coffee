Deckhand.app.directive 'dhField', [
  'FieldFormatter', '$rootScope', 'ModelConfig', 'Cards', 'ModalEditor'
  (FieldFormatter, $rootScope, ModelConfig, Cards, ModalEditor) ->

    link = (scope, element, attrs) ->
      scope.name = attrs.name
      scope.format = FieldFormatter.format
      scope.substitute = FieldFormatter.substitute
      scope.show = Cards.show

      scope.edit = (type) ->
        switch type
          when 'checkbox'
            null # handled by ng-change immediately
          when 'text', 'upload', 'select'
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

      return '<span>{{format(item, name)}}</span>' unless field

      if field.delegate
        args = ['item[name]', "'#{field.delegate}'"]
      else
        args = ['item', 'name']

      args.push "'multiline'" if field.multiline

      value = "{{format(#{args.join(", ")})}}"

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
        else if field.type == 'boolean'
          'checkbox'
        else if field.choices
          'select'
        else
          'text'

        choices = "edit-choices=\"o.key as o.value for o in item.#{field.name}_choices\"" if editType is 'select'

        middle = if editType is 'checkbox'
          output
        else
          "<i class='glyphicon glyphicon-pencil edit-icon'></i>
           <div ng-hide='editing'>#{output}</div>"

        output = "<div class='dh-field editable'
                       ng-click=\"edit('#{editType}')\"
                       ng-class='{editing: editing, image: #{field.thumbnail}}'>
                    #{middle}
                    <dh-field-editor ng-show='editing' item='item' name='name' edit-type=\"#{editType}\" #{choices}/>
                  </div>"
      else
        output = "<div class='dh-field' ng-class='{image: #{field.thumbnail}}'>#{output}</div>"

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
