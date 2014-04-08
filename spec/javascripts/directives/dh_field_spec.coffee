require '../spec_helper'

describe 'dhField directive', ->
  scope = compile = element = inner = FieldFormatter = ModelConfig = null

  beforeEach ->
    angular.mock.module 'Deckhand'

    inject ($rootScope, $compile, _FieldFormatter_, _ModelConfig_) ->
      scope = $rootScope
      compile = $compile
      FieldFormatter = _FieldFormatter_
      ModelConfig = _ModelConfig_

    spyOn(ModelConfig, 'field').and.returnValue(null)
    spyOn(FieldFormatter, 'format').and.returnValue('formatted')
    spyOn(FieldFormatter, 'substitute').and.returnValue('substituted')

  mockField = (field, value) ->
    ModelConfig.field.and.returnValue(field)
    FieldFormatter.format.and.returnValue(if value? then value else 'formatted')
    field

  render = (html) ->
    html = '<dh-field item="item" model="Campaign" name="\'title\'"></dh-field>' unless html
    element = angular.element(html)
    compile(element)(scope)
    scope.$digest()
    inner = element.children().first()

  expectToBeDhField = (setup) ->
    describe 'is dh-field', ->
      beforeEach -> setup()

      it 'wraps ', ->
        expect(element.prop('tagName').toLowerCase()).toEqual('dh-field')

  describe 'with no field', ->
    setup = ->
      mockField(null)
      render()

    beforeEach -> setup()

    expectToBeDhField(setup)

    it 'renders span when no field present', ->
      expect(inner.prop('tagName').toLowerCase()).toEqual('span')

    it 'contains formatted value', ->
      expect(inner.text().trim()).toEqual('formatted')

  expectToBeRegular = (setup, value) ->
    describe 'is regular', ->
      beforeEach ->
        value = if value? then value else 'formatted'
        setup()

      expectToBeDhField(setup)

      it 'renders div when field is present', ->
        expect(inner.prop('tagName').toLowerCase()).toEqual('div')

      it 'contains appropriate value', ->
        expect(inner.text().trim()).toEqual(value)

  describe 'with non editable field', ->
    describe 'with html', ->
      setup = ->
        mockField({editable: false, html: 'some html'})
        render()

      beforeEach -> setup()

      expectToBeRegular(setup)

      it 'binds html', ->
        boundHtmlContainers = inner.find('div[ng-bind-html]')
        expect(boundHtmlContainers.length).toBe(1)
        expect(boundHtmlContainers.eq(0).text().trim()).toEqual('formatted')

    describe 'with thumbnail', ->
      setup = ->
        mockField({thumbnail: 'thumbnail.png'}, 'thumbnail.png')
        render()

      beforeEach -> setup()

      expectToBeRegular(setup, '')

      it 'links to thumbnail image', ->
        expect(inner.find("a[ng-href='thumbnail.png']").length).toBe(1)
        expect(inner.find("img[ng-src='thumbnail.png']").length).toBe(1)

    describe 'with link', ->
      setup = ->
        mockField({link_to: 'some_link'})
        FieldFormatter.substitute.and.returnValue('some_link')
        render()

      beforeEach -> setup()

      expectToBeRegular(setup)

      it 'links to it', ->
        expect(inner.find("a[ng-href='some_link']").length).toBe(1)

    describe 'with relation', ->
      setup = ->
        mockField({type: 'relation'})
        render()

      beforeEach -> setup()

      expectToBeRegular(setup)

      it 'links click to the related value when present', ->
        scope.item = {related: 'not null'}
        render('<dh-field item="item" model="Campaign" name="\'related\'"></dh-field>')
        expect(inner.find("a[ng-click='show(item[name]._model, item[name].id)']").length).toBe(1)

      it 'does not link when related value does not exist', ->
        scope.item = {related: null}
        render('<dh-field item="item" model="Campaign" name="\'related\'"></dh-field>')
        expect(inner.find("a[ng-click='show(item[name]._model, item[name].id)']").length).toBe(0)

    describe 'with time', ->
      setup = ->
        mockField({type: 'time'})
        FieldFormatter.format.and.returnValue('some_time')
        render()

      beforeEach -> setup()

      expectToBeRegular(setup, 'a few seconds ago')

      it 'invokes dh-time directive', ->
        expect(inner.find("[time='some_time']").length).toBe(1)

  expectToBeEditable = (field, editType) ->
    describe "is editable", ->
      setup = ->
        mockField(field)
        render()

      beforeEach ->
        setup()
        editType = if editType? then editType else 'formatted'

      expectToBeDhField(setup)

      it 'wraps content in editable', ->
        expect(inner.hasClass('editable')).toBe(true)

      it 'makes field clickable', ->
        expect(inner.attr('ng-click')).toEqual("edit('" + editType + "')")

      it 'invokes dh-field-editor directive', ->
        expect(inner.find("[edit-type='" + editType + "']").length).toBe(1)

  expectToDisplayAsEditable = (field) ->
    describe "displays as editable", ->
      setup = ->
        mockField(field)
        render()

      beforeEach ->
        setup()

      it 'contains editable icon', ->
        expect(inner.find('.glyphicon-pencil').length).toEqual(1)

      it 'contains hidable element with value', ->
        expect(inner.find("[ng-hide='editing']").length).toEqual(1)
        expect(inner.find("[ng-hide='editing']").eq(0).text().trim()).toEqual('formatted')

  describe 'with editable field', ->
    describe 'with text', ->
      expectToBeEditable({editable: true}, 'text')
      expectToDisplayAsEditable({editable: true})

    describe 'with ckeditor', ->
      expectToBeEditable({editable: {with: 'ckeditor'}}, 'ckeditor')
      expectToDisplayAsEditable({editable: {with: 'ckeditor'}})

    describe 'with nested', ->
      expectToBeEditable({editable: {nested: true}}, 'nested')
      expectToDisplayAsEditable({editable: {nested: true}})

    describe 'with file', ->
      expectToBeEditable({editable: true, type: 'file'}, 'upload')
      expectToDisplayAsEditable({editable: true, type: 'file'})

    describe 'as boolean', ->
      beforeEach ->
        mockField({editable: true, type: 'boolean'})
        render()

      expectToBeEditable({editable: true, type: 'boolean'}, 'checkbox')

      it 'does not contain editable icon', ->
        expect(inner.find('.glyphicon-pencil').length).toEqual(0)

      it 'does not contain hidable element with value', ->
        expect(inner.find("[ng-hide='editing']").length).toEqual(0)

    describe 'with choices', ->
      beforeEach ->
        mockField({name: 'type', editable: true, choices: true})
        render()

      expectToBeEditable({editable: true, choices: true}, 'select')
      expectToDisplayAsEditable({editable: true, choices: true})

      it 'invokes dh-field-editor directive with choices', ->
        expect(inner.find("[edit-choices='o.key as o.value for o in item.type_choices']").length).toBe(1)
