var include = require('./lib/include');

Deckhand.directive('ckeditor', function() {
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
    } else if (DeckhandGlobals.ckeditor != '') {
      include(DeckhandGlobals.ckeditor, function() {
        setupEditor();
      });
    }
  };

  return {require: 'ngModel', link: link};
})

.directive('dhField', ['FieldFormatter', '$rootScope', function(FieldFormatter, $rootScope) {
  function link(scope, element, attrs) {
    scope.name = attrs.name;
    scope.format = FieldFormatter.format;
    scope.substitute = FieldFormatter.substitute;
    scope.showCard = function(model, id) {
      return $rootScope.showCard(model, id);
    };
  };

  return {
    link: link,
    restrict: 'E',
    scope: {item: '=item'},
    template: function(tElement, tAttrs) {
      // TODO pass options globally instead of to each item?
      var options = JSON.parse(tAttrs.options), value;

      if (options.delegate) {
        value = "{{format(item[name], '"+options.delegate+"')}}";
      } else {
        value = "{{format(item, name)}}";
      }

      if (options.html) {
        value = value.replace(/^{{|}}$/g, '');
        return '<div ng-bind-html="'+value+'"></div>';

      } else if (options.thumbnail) {
        return '<a target="_blank" ng-href="'+value+'"><img ng-src="'+value+'"</a>';

      } else if (options.link_to) {
        return '<a target="_blank" ' +
          'ng-href="{{substitute(item, name, \''+options.link_to+'\')}}">'+value+'</a>';

      } else if (options.link_to_item) {
        return '<a ng-click="showCard(item._model, item.id)">'+value+'</a>';

      } else {
        var types = DeckhandGlobals.fieldTypes[tAttrs.model];
        var type = (types ? types[tAttrs.name] : null);
        if (type == 'relation') {
          return '<a ng-click="showCard(item[name]._model, item[name].id)">'+value+'</a>';
        } else {
          return value;
        }
      }
    }
  };
}])