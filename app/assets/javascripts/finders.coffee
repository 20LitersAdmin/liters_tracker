# $(document).on 'turbolinks:load', ->
#   return unless controllerMatches(['facilities', 'sectors', 'reports', 'plans']) &&
#     actionMatches(['new', 'edit', 'create', 'update', 'report'])

### Global linked-select fields for geography lookups
## Setup: Ensure that:
# 1. The parent form is ID'd in the following format: '#{action}_{model}'. e.g.:
#   '#new_plan', '#edit_facility'
#
# 2. Select fields are ID'd in the following format: '#{model}_{geography}'. e.g.:
#   '#plan_village', '#village_sector'
#
# 3. For polymorphic models: form has hidden fields for the polymorphic attributes: [name, id], e.g.:
#   = f.input :planable_id, as: :hidden
#   = f.input :planable_type, as: :hidden
#
## Usage:
# Place these calls in the apropriate files. e.g.:
#   plans.coffee:
#   $('#plan_district').on 'change', ->
#     # to update linked select fields
#     LinkedSelect.updateChildSelectors($(this))
#     # to update polymorphic hidden fields
#     LinkedSelect.assessPolymorphics($(this))
#
#   facilities.coffee:
#   $('#facility_cell').on 'change', ->
#     # to update linked select fields
#     LinkedSelect.updateChildSelectors($(this))
###

class LinkedSelect
  # main functions
  @updateChildSelectors = (trigger)->
    resetChildrenOptions(trigger)
    if trigger.val() > 0
      target = findTarget(trigger)
      ajaxGeography(trigger, target)

  @assessPolymorphics = (trigger)->
    # Only the Report and Plan models have polymorphic fields
    return unless ['report', 'plan'].includes(modelName(trigger.attr('id')))

    if ['', '0'].includes(trigger.val())
      findLowestSelectedOption(trigger)
    else
      setPolymorphics(trigger)

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
    target.append('<option value="' + record.id + '">' + record.name + '</option>')

  findLowestSelectedOption = (trigger)->
    targetModel = modelName(trigger.attr('id'))
    setPolymorphics(findTargetIndirect(targetModel, targetGeo)) for targetGeo in refChildren['all']

  findTarget = (trigger)->
    targetId = '#' + modelName(trigger.attr('id')) + '_' + refChild[geographyName(trigger.attr('id'))].toLowerCase()
    target = $(targetId)

  findTargetIndirect = (modelName, geoName)->
    target = $('#' + modelName + '_' + geoName)

  geographyName = (id) ->
    # from '#plan_facility', returns 'facility'
    # from '#facility_village', returns 'village'
    id.substring(id.indexOf('_')+1, id.length)

  modelName = (id)->
    # from '#plan_facility', returns 'plan'
    # from '#facility_village', returns 'facility'
    id.substring(0, id.indexOf('_'))

  prepareOptions = (target, records)->
    # records is an array: [{id: 'id', name: 'name'},{id: 'id', name: 'name'}]
    target.html('')
    target.append('<option></option>')
    appendOptionLoop(record, target) for record in records

  resetChildrenOptions = (trigger)->
    geoName = geographyName(trigger.attr('id'))
    targetModel = modelName(trigger.attr('id'))
    resetOptions(findTargetIndirect(targetModel, targetGeo)) for targetGeo in refChildren[geoName]

  resetOptions = (target)->
    # skip if the target is not found or if the target is already in "default state",
    # meaning it has an option with value '0', which is what the last line of this function adds
    return if target.length == 0 || target.find('option[value=0]').length > 0

    targetGeo = geographyName(target.attr('id'))
    target.html('')
    target.append('<option></option>')
    $(target).append('<option disabled="disabled" value="0">Please select a ' + refParent[targetGeo] + '</option>')

  setPolymorphics = (source)->
    # Dont' set the polymorphic fields if the source field is being set to nil
    # or if the source field is a District (the higest geography)
    return if ['', '0'].includes(source.val()) && !source.attr('id').includes('district')

    typeLowercase = geographyName(source.attr('id'))
    type = typeLowercase[0].toUpperCase() + typeLowercase.substring(1)
    id = source.val()
    polyName = '#' + modelName(source.attr('id')) + '_' + modelName(source.attr('id'))
    $(polyName + 'able_type').val(type)
    $(polyName + 'able_id').val(id)

root              = exports ? this
root.LinkedSelect = LinkedSelect


# Other places to be reformatted:

  # # called from facilities#new && sectors#report:facilities/_modal_form
  # $('#facility_cell').on 'change', ->
  #   cellId = $(this).val()
  #   target = $('#facility_village')
  #   resetOptions(target)
  #   if cellId > 0
  #     ajaxGeography('cells', cellId, target)

  # # called from sectors#report:_village_form && _facility_form
  # $('#report_cell').on 'change', ->
  #   cellId = $(this).val()
  #   villageTarget = $('#report_village')
  #   facilityTarget = $('#report_reportable_id')
  #   resetOptions(facilityTarget)
  #   if cellId > 0
  #     ajaxGeography('cells', cellId, villageTarget)
  #   else
  #     resetOptions(villageTarget)

  # # called from sectors#report:_facility_form
  # $('#report_village').on 'change', ->
  #   villageId = $(this).val()
  #   target = $('#report_reportable_id')
  #   resetOptions(target)
  #   if villageId > 0
  #     ajaxGeography('villages', villageId, target)
