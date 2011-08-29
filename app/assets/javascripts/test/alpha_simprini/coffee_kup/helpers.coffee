module "AS.CK.Helpers"
test "autoId", ->
  id = AS.CK.Helpers.autoId()
  ok id.string != "", "selector is not blank"
  ok id.string != undefined, "selector is defined"
  equal id.query().selector, "##{id.string}", "gives id as a string and a selector"

test "shy", ->
  shy = AS.CK.Helpers.shy("ThisShallShy")
  equal shy, "This&shy;Shall&shy;Shy", "adds shy markers to titlecase text"
