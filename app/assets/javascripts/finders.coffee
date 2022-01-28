### Global linked select fields for geography lookups
## Setup: Ensure that:
1. The parent form is ID'd in the following format: '#{action}_{model}'. e.g.:
  '#new_plan', '#edit_facility'

2. Select fields are ID'd in the following format: '#{model}_{geography}'. e.g.:
  '#plan_village', '#village_sector'

3. Polymorphic models:
  A. form has hidden fields for the polymorphic attributes: [name, id], e.g.:
    = f.input :planable_id, as: :hidden
    = f.input :planable_type, as: :hidden (_type can be skipped and set in the controller if needed)
  B. If a specific geography is required, it is tagged as 'required' on the form field, e.g.:
    Reports related to a 'Community' technology have to be tied to a Facility

## Usage:
Place these calls in the apropriate files.

LinkedSelect.updateChildSelectors($(this)):
- Finds the next child geography select field and populates it

LinkedSelect.assessPolymorphics($(this)):
- Decides what to put in the polymorphic fields

LinkedSelect.clearPolymorphics($(this), scope):
- Force-clears one or both of the polymorphic fields
- scope is one of these: ['id', 'type', 'both']

LinkedSelect.forcePolymorphics($(this), scope):
- Force-sets one or both of the polymorphic fields
- scope is one of these: ['id', 'type', 'both']

e.g.:
  plans.coffee:
  $('#plan_district').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))
    LinkedSelect.assessPolymorphics($(this))
#
  facilities.coffee:
  $('#facility_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'both')
    else
      LinkedSelect.forcePolymorphics($(this), 'id')
###

class LinkedSelect
  # main functions
  @updateChildSelectors = (trigger)->
    # console.log 'LinkedSelect.updateChildSelectors'
    resetChildrenOptions(trigger)
    if trigger.val() > 0
      target = findTarget(trigger)
      ajaxGeography(trigger, target)

  @assessPolymorphics = (trigger)->
    # console.log 'LinkedSelect.assessPolymorphics'
    # Only the Report and Plan models have polymorphic fields
    return unless ['report', 'plan'].includes(modelName(trigger.attr('id')))

    if ['', '0'].includes(trigger.val())
      findLowestSelectedOption(trigger)
    else
      setPolymorphics(trigger)

  @clearPolymorphics = (source, scope)->
    # console.log 'LinkedSelect.clearPolymorphics'
    # scope can be 'id', 'type', or 'both'
    # skip for missing sources
    return unless source.length > 0

    model = modelName(source.attr('id'))
    # Only the Report and Plan models have polymorphic fields
    return unless ['report', 'plan'].includes(model)

    polyName = '#' + model + '_' + model

    if ['id', 'both'].includes(scope)
      $(polyName + 'able_id').val('')

    if ['type', 'both'].includes(scope)
      $(polyName + 'able_type').val('')

  @forcePolymorphics = (source, scope)->
    # console.log 'LinkedSelect.forcePolymorphics'
    # scope can be 'id', 'type', or 'both'
    # skip for missing sources
    return unless source.length > 0

    model = modelName(source.attr('id'))
    # Only the Report and Plan models have polymorphic fields
    return unless ['report', 'plan'].includes(model)

    typeLowercase = geographyName(source.attr('id'))
    type = typeLowercase[0].toUpperCase() + typeLowercase.substring(1)
    id = source.val()
    polyName = '#' + modelName(source.attr('id')) + '_' + modelName(source.attr('id'))

    if ['id', 'both'].includes(scope)
      $(polyName + 'able_id').val(id)

    if ['type', 'both'].includes(scope)
      $(polyName + 'able_type').val(type)

    # console.log 'breakpoint'

  # support functions
  refParent = {
    sector: 'District',
    cell: 'Sector',
    village: 'Cell',
    facility: 'Village'
  }

  refChild = {
    district: 'Sector',
    sector: 'Cell',
    cell: 'Village',
    village: 'Facility'
  }

  refChildren = {
    all: ['district', 'sector', 'cell', 'village', 'facility' ],
    district: ['facility', 'village', 'cell', 'sector'],
    sector: ['facility', 'village', 'cell'],
    cell: ['facility', 'village'],
    village: ['facility']
  }

  ajaxGeography = (trigger, target)->
    # console.log 'LinkedSelect#ajaxGeograph'
    # response is an array: [{id: 'id', name: 'name'},{id: 'id', name: 'name'}]
    # We can use `+ 's'` because all geographies with children pluralize by adding an 's'
    parentType = geographyName(trigger.attr('id')) + 's'
    parentId = trigger.val()
    # all geographies except `facilities` have a route for `/children` that returns a JSON collection
    uri = '/' + parentType + '/' + parentId + '/children'
    $.ajax(
      url: uri
    ).done (response) ->
      prepareOptions(target, response)

  appendOptionLoop = (record, target)->
    # console.log 'LinkedSelect#appendOptionLoop'
    target.append('<option value="' + record.id + '">' + record.name + '</option>')

  findLowestSelectedOption = (trigger)->
    # console.log 'LinkedSelect#findLowestSelectedOption'
    targetModel = modelName(trigger.attr('id'))
    setPolymorphics(findTargetIndirect(targetModel, targetGeo)) for targetGeo in refChildren['all']

  findTarget = (trigger)->
    # console.log 'LinkedSelect#findTarget'
    targetId = '#' + modelName(trigger.attr('id')) + '_' + refChild[geographyName(trigger.attr('id'))].toLowerCase()
    target = $(targetId)

  findTargetIndirect = (modelName, geoName)->
    # console.log 'LinkedSelect#findTargetIndirect'
    target = $('#' + modelName + '_' + geoName)

  geographyName = (id) ->
    # console.log 'LinkedSelect#geographyName'
    # from '#plan_facility', returns 'facility'
    # from '#facility_village', returns 'village'
    id.substring(id.indexOf('_')+1, id.length)

  modelName = (id)->
    # console.log 'LinkedSelect#modelName'
    # from '#plan_facility', returns 'plan'
    # from '#facility_village', returns 'facility'
    id.substring(0, id.indexOf('_'))

  prepareOptions = (target, records)->
    # console.log 'LinkedSelect#prepareOptions'
    # records is an array: [{id: 'id', name: 'name'},{id: 'id', name: 'name'}]
    target.html('')
    target.append('<option></option>')
    appendOptionLoop(record, target) for record in records

  resetChildrenOptions = (trigger)->
    # console.log 'LinkedSelect#resetChildrenOptions'
    geoName = geographyName(trigger.attr('id'))
    targetModel = modelName(trigger.attr('id'))
    resetOptions(findTargetIndirect(targetModel, targetGeo)) for targetGeo in refChildren[geoName]

  resetOptions = (target)->
    # console.log 'LinkedSelect#resetOptions'
    # skip if the target is not found or if the target is already in "default state",
    # meaning it has an option with value '0', which is what the last line of this function adds
    return if target.length == 0 || target.find('option[value=0]').length > 0

    targetGeo = geographyName(target.attr('id'))
    target.html('')
    target.append('<option></option>')
    $(target).append('<option disabled="disabled" value="0">Please select a ' + refParent[targetGeo] + '</option>')

  setPolymorphics = (source)->
    # console.log 'LinkedSelect#setPolymorphics'
    # skip for missing sources
    return unless source.length > 0

    # Dont' set the polymorphic fields if the source field is being set to nil
    # and the source field is not a District (the highest geography)
    return if ['', '0'].includes(source.val()) && !source.attr('id').includes('district')

    typeLowercase = geographyName(source.attr('id'))
    type = typeLowercase[0].toUpperCase() + typeLowercase.substring(1)
    id = source.val()
    polyName = '#' + modelName(source.attr('id')) + '_' + modelName(source.attr('id'))
    $(polyName + 'able_type').val(type)
    $(polyName + 'able_id').val(id)

root              = exports ? this
root.LinkedSelect = LinkedSelect

