var include = require('./lib/include'),
  moment = require('moment');

Deckhand.app.directive('ckeditor', function() {
  var link = function(scope, element, attrs, ngModel) {
    var editor;

    var setupEditor = function() {
      editor = CKEDITOR.replace(element[0]);

      // the editor may have been loaded before the form data
      scope.$watch(attrs.ngModel, function(value) {
        if (value) {
          setTimeout(function() { editor.setData(value); }, 0);
        }
      })

      editor.on('change', function() {
        ngModel.$setViewValue(editor.getData());
      })
    };

    if (window.CKEDITOR) {
      setupEditor();
    } else if (Deckhand.ckeditor != '') {
      include(Deckhand.ckeditor, function() {
        setupEditor();
      });
    }
  };

  return {require: 'ngModel', link: link};
})

.directive('dhTime', [function() {
  function link(scope, element, attrs) {
    scope.$watch('time', function(value) {
      var time = value ? new Date(value) : null;
      scope.shortTime = (time ? moment(time).fromNow() : 'never');
      scope.fullTime = (time ? moment(time).format('MMM Do, YYYY h:mm:ss a Z') : 'never');
      scope.shown = scope.shortTime;
    })
  };

  return {
    link: link,
    scope: {time: '@'},
    restrict: 'E',
    replace: true,
    template: '<span title="{{fullTime}}">{{shortTime}}</span>'
  };
}])

.directive('dhField', ['FieldFormatter', '$rootScope', 'ModelConfig',
  function(FieldFormatter, $rootScope, ModelConfig) {

  function link(scope, element, attrs) {
    scope.name = attrs.name;
    scope.format = FieldFormatter.format;
    scope.substitute = FieldFormatter.substitute;
    scope.showCard = function(model, id) {
      return $rootScope.showCard(model, id);
    };
    scope.edit = function(name, options) {
      return scope.$parent.edit(name, options);
    }
  };

  function template(tElement, tAttrs) {
    var field = ModelConfig.field(tAttrs.model, tAttrs.name, tAttrs.relation), value;

    if (!field) {
      return '{{format(item, name)}}';
    }

    if (field.delegate) {
      value = "{{format(item[name], '"+field.delegate+"')}}";
    } else if (field.multiline) {
      value = "{{format(item, name, 'multiline')}}";
    } else {
      value = "{{format(item, name)}}";
    }

    var output;

    if (field.html || field.multiline) {
      value = value.replace(/^{{|}}$/g, '');
      output = '<div ng-bind-html="'+value+'"></div>';

    } else if (field.thumbnail) {
      output = '<a target="_blank" ng-href="'+value+'"><img ng-src="'+value+'"</a>';

    } else if (field.link_to) {
      output = '<a target="_blank" ' +
        'ng-href="{{substitute(item, name, \''+field.link_to+'\')}}">'+value+'</a>';

    } else if (field.type == 'relation') {
      output = '<a ng-click="showCard(item[name]._model, item[name].id)">'+value+'</a>';

    } else if (field.type == 'time') {
      output = '<dh-time time="'+value+'"/>';

    } else {
      output = value;
    }

    if (field.editable) {
      output = '<div class="editable" ng-click="edit(name, '+JSON.stringify(field.editable)+')"><i class="glyphicon glyphicon-pencil edit-icon"></i>' + output + '</div>';
    }

    return output;
  };

  return {
    link: link,
    restrict: 'E',
    scope: {item: '='},
    template: template
  };
}]);
