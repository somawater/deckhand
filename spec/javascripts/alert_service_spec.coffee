describe "AlertService", ->
  alertService = undefined

  beforeEach ->
    module "Deckhand"
    inject [
      "AlertService"
      (alertService) ->
        @alertService = alertService
    ]

  it "adds alerts", ->
    expect(alertService).not.toBe `undefined`