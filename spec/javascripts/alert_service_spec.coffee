require './spec_helper'

describe 'AlertService', ->
  subject = undefined
  rootScope = undefined

  beforeEach ->
    angular.mock.module 'Deckhand'

    inject [
      'AlertService', '$rootScope'
      (alertService, $rootScope) ->
        subject = alertService
        rootScope = $rootScope
    ]

  it 'exists', ->
    expect(subject).not.toBe undefined

  it 'initializes alerts', ->
    expect(rootScope.alerts).not.toBe undefined
    expect(rootScope.alerts.length).toBe 0

  it 'requires message when adding alert', ->
    subject.add('info', null)
    expect(rootScope.alerts.length).toBe 0

  it 'adds alert', ->
    subject.add('info', 'not important')
    expect(rootScope.alerts.length).toBe 1

  it 'returns added alert', ->
    expect(subject.add('info', 'not important')).not.toBe null

  it 'closes alert', ->
    subject.close(subject.add('info', 'not important'))
    expect(rootScope.alerts.length).toBe 0

  it 'clears alerts', ->
    subject.add('info', 'not important') for [1..10]
    subject.clear()
    expect(rootScope.alerts.length).toBe 0
