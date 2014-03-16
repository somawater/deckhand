require './spec_helper'
scroll = require '../../app/assets/javascripts/deckhand/node_modules/scroll'

describe 'Card scrolling', ->
  el = scope = Cards = Model = ModelStore = $timeout = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach ->
    spyOn(scroll, 'top')

  beforeEach inject (_Cards_, _Model_, _ModelStore_) ->
    Cards = _Cards_
    Model = _Model_
    ModelStore = _ModelStore_

  beforeEach inject ($rootScope, $compile, _$timeout_) ->
    $timeout = _$timeout_
    fixture = setFixtures("""
      <div ng-controller="CardListCtrl">
        <div class="card" ng-repeat="item in cards" dh-scroll-to="showCard">
          Card
        </div>
      </div>
    """)
    el = $compile(fixture)($rootScope.$new())
    scope = el.scope()

  describe 'when a new model is shown', ->
    beforeEach ->
      spyOn(ModelStore, 'find').and.returnValue(null)
      spyOn(ModelStore, 'register').and.callFake (model) ->
        {item: model}

      newModel = {}
      spyOn(Model, 'get').and.callFake (params, cb) ->
        cb(newModel)

      Cards.show('Model', 1)
      scope.$apply()

    it 'scrolls to the card representing that model', ->
      $timeout.flush()
      cardEl = el.find('.card')[0]
      expect(scroll.top).toHaveBeenCalledWith(
        document.body,
        cardEl.offsetTop,
        jasmine.any(Object)
      )
