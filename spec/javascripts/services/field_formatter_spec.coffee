require '../spec_helper'

describe 'FieldFormatter', ->
  subject = undefined
  rootScope = undefined
  ModelConfig = null

  beforeEach ->
    angular.mock.module 'Deckhand'

    inject (FieldFormatter, $rootScope, _ModelConfig_) ->
      subject = FieldFormatter
      rootScope = $rootScope
      ModelConfig = _ModelConfig_

    spyOn(ModelConfig, 'type').and.returnValue(null)

  it 'exists', ->
    expect(subject).not.toBe undefined

  describe '#format', ->
    it 'returns item column value', ->
      item = {column: 'value'}
      expect(subject.format(item, 'column')).toEqual('value')

    it 'supports multiline modifier', ->
      item = {column: 'value\nsecond_row\rthird_row\r\nfourth_row'}
      expect(subject.format(item, 'column', 'multiline')).toEqual('value<br/>second_row<br/>third_row<br/>fourth_row')

    describe 'with relation', ->
      beforeEach -> ModelConfig.type.and.returnValue('relation')

      it 'returns relation label when related object exists', ->
        item = {column: {_label: 'related'}}
        expect(subject.format(item, 'column')).toEqual('related')

      it 'defaults to none when related object does not exist', ->
        item = {column: null}
        expect(subject.format(item, 'column')).toEqual('none')

    describe 'with choices', ->
      it 'uses value from choices when matched', ->
        item = {column: 'key', column_choices: [{key: 'key', value: 'value'}, {key: 'key2', value: 'value2'}]}
        expect(subject.format(item, 'column')).toEqual('value')

      it 'uses original value when choices do not match', ->
        item = {column: 'key', column_choices: [{key: 'key1', value: 'value1'}, {key: 'key2', value: 'value2'}]}
        expect(subject.format(item, 'column')).toEqual('key')

  describe '#substitute', ->
    it 'replaces placeholders in string with formatted value', ->
      item = {column: 'calculated_value'}
      input = 'placeholder: :value, and once more: :value'
      expect(subject.substitute(item, 'column', input)).toEqual('placeholder: calculated_value, and once more: calculated_value')
