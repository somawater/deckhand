require '../spec_helper'

describe 'dhField', ->
  scope = undefined
  compile = undefined
  element = undefined
  FieldFormatter = undefined
  ModelConfig = undefined

  beforeEach angular.mock.module 'Deckhand'

  beforeEach inject ($rootScope, $compile, _FieldFormatter_, _ModelConfig_) ->
    scope = $rootScope
    compile = $compile
    FieldFormatter = _FieldFormatter_
    ModelConfig = _ModelConfig_

  beforeEach ->
    spyOn(ModelConfig, 'field').and.returnValue(null)
    spyOn(FieldFormatter, 'format').and.returnValue('formatted')

  mockField = (field, value) ->
    ModelConfig.field.and.returnValue(field)
    FieldFormatter.format.and.returnValue(if value? then value else 'formatted')
    field

  render = (html) ->
    html = '<dh-field item="item" model="Campaign" name="title"></dh-field>' unless html
    element = angular.element(html)
    compile(element)(scope)
    scope.$digest()

  describe 'with no field', ->
    beforeEach ->
      mockField(null)
      render()

    it 'renders span when no field present', ->
      expect(element.prop('tagName').toLowerCase()).toEqual('span')

    it 'contains formatted value', ->
      expect(element.text().trim()).toEqual('formatted')

  expectToBeRegular = (regularElement) ->
    describe '(regular)', ->
      it 'renders div when field is present', ->
        expect(regularElement.prop('tagName').toLowerCase()).toEqual('div')

      it 'contains formatted value', ->
        expect(regularElement.text().trim()).toEqual('formatted')

  describe 'with non editable field', ->
    describe 'with html', ->
      beforeEach ->
        mockField({editable: false, html: 'some html'})
        render()

      it 'behaves like regular', ->
        expectToBeRegular(element)

      it 'binds html', ->
        boundHtmlContainers = element.find('div[ng-bind-html]')
        expect(boundHtmlContainers.length).toBe(1)
        expect(boundHtmlContainers.eq(0).text().trim()).toEqual('formatted')

    describe 'with thumbnail', ->
      beforeEach ->
        mockField({thumbnail: 'thumbnail.png'}, 'thumbnail.png')
        render()

      it 'behaves like regular', ->
        expectToBeRegular(element)

      it 'links to thumbnail image', ->
        expect(element.find("a[ng-href='thumbnail.png']").length).toBe(1)
        expect(element.find("img[ng-src='thumbnail.png']").length).toBe(1)

    describe 'with link', ->
      beforeEach ->
        mockField({link_to: 'some_link'})
        spyOn(FieldFormatter, 'substitute').and.returnValue('some_link')
        render()

      it 'behaves like regular', ->
        expectToBeRegular(element)

      it 'links to it', ->
        expect(element.find("a[ng-href='some_link']").length).toBe(1)

    describe 'with relation', ->
      beforeEach ->
        mockField({type: 'relation'})
        render()

      it 'behaves like regular', ->
        expectToBeRegular(element)

      it 'links click to the related model', ->
        expect(element.find("a[ng-click='show(item[name]._model, item[name].id)']").length).toBe(1)

    describe 'with time', ->
      beforeEach ->
        mockField({type: 'time'})
        FieldFormatter.format.and.returnValue('some_time')
        render()

      it 'behaves like regular', ->
        expectToBeRegular(element)

      it 'invokes dh-time directive', ->
        expect(element.find("[time='some_time']").length).toBe(1)

  expectToBeEditable = (field, editType) ->
    describe "is editable", ->
      beforeEach ->
        mockField(field)
        render()
        editType = editType || 'text'

      it 'wraps content in editable', ->
        expect(element.hasClass('editable')).toBe(true)

      it 'makes field clickable', ->
        expect(element.attr('ng-click')).toEqual("edit('" + editType + "')")

      it 'invokes dh-field-editor directive', ->
        expect(element.find("[edit-type='" + editType + "']").length).toBe(1)

  expectToDisplayAsEditable = (field) ->
    describe "displays as editable", ->
      beforeEach ->
        mockField(field)
        render()

      it 'contains editable icon', ->
        expect(element.find('.glyphicon-pencil').length).toEqual(1)

      it 'contains hidable element with value', ->
        expect(element.find("[ng-hide='editing']").length).toEqual(1)
        expect(element.find("[ng-hide='editing']").eq(0).text().trim()).toEqual('formatted')

  describe 'with editable field', ->
    describe 'with text', ->
      expectToBeEditable({editable: true})
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
        expect(element.find('.glyphicon-pencil').length).toEqual(0)

      it 'does not contain hidable element with value', ->
        expect(element.find("[ng-hide='editing']").length).toEqual(0)
