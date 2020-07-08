# $(document).on 'turbolinks:load', ->
#   return unless controllerMatches(['facilities', 'sectors', 'reports', 'plans']) &&
#     actionMatches(['new', 'edit', 'create', 'update', 'report'])

### Global linked-select fields for geography lookups
## Setup: Ensure that:
# HTML Body tag has data-action and data-controller values. e.g.:
#   <body data-action="show" data-controller="contracts">
#
# Select fields are ID'd in the following format: '#{controller}_{geography}'. e.g.:
#   '#contract_sector', '#plan_village'
#
# All geography controllers (except the last child) have a `/children` collection method
#   that returns the immediate children's name and id in a JSON colleciton. e.g.:
#   class DistrictsController
#     def children
#       render json: @district.sectors.select(:id, :name).order(:name)
#     end
#   end
#
# For polymorphic models: form has hidden fields for the polymorphic attributes: [name, id], e.g.:
#   = f.input :planable_id, as: :hidden
#   = f.input :planable_type, as: :hidden
#
## Usage:
# Place these calls in the apropriate files. e.g.:
# plans.coffee:
# $('#plan_district').on 'change', ->
#   # to update linked select fields
#   LinkedSelect.updateChildSelectors($(this))
#   # to update polymorphic hidden fields
#   LinkedSelect.assessPolymorphics($(this))
###

class LinkedSelect
  # main functions
  @updateChildSelectors = (trigger)->
    target = findTarget(trigger)
    resetChildrenOptions(trigger)
    if trigger.val() > 0
      ajaxGeography(trigger, target)
    else

  @assessPolymorphics = (trigger)->
    if ['', '0'].includes(trigger.val())
      findLowestSelectedOption()
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

  refPlurals = {
    districts: 'district'
    sectors: 'sector'
    cells: 'cell'
    villages: 'village'
    facilities: 'facility'
    plans: 'plan'
    reports: 'report'
  }

  ajaxGeography = (trigger, target)->
    parentType = parseId(trigger.attr('id')) + 's'
    parentId = trigger.val()
    uri = '/' + parentType + '/' + parentId + '/children'
    $.ajax(
      url: uri
    ).done (response) ->
      prepareOptions(target, response)

  appendOptionLoop = (record, target)->
    target.append('<option value="' + record.id + '">' + record.name + '</option>')

  controllerName = ()->
    plural = $('body').attr('data-controller')
    refPlurals[plural]

  findLowestSelectedOption = ()->
    setPolymorphics(findTargetFromName(targetName)) for targetName in refChildren['all']

  findTarget = (trigger)->
    triggerId = parseId(trigger.attr('id'))
    targetId = '#' + controllerName() + '_' + refChild[triggerId].toLowerCase()
    target = $(targetId)

  findTargetFromName = (name)->
    $('#' + controllerName() + '_' + name)

  parseId = (id) ->
    controller = controllerName() + '_'
    id.replace(controller, '')

  prepareOptions = (target, records)->
    target.html('')
    target.append('<option></option>')
    appendOptionLoop(record, target) for record in records

  resetChildrenOptions = (trigger)->
    triggerId = parseId(trigger.attr('id'))
    resetOptions(findTargetFromName(targetName)) for targetName in refChildren[triggerId]

  resetOptions = (target)->
    return if target.length == 0 || ['', '0'].includes(target.val())

    targetName = parseId(target.attr('id'))
    target.html('')
    target.append('<option></option>')
    $(target).append('<option disabled="disabled" value="0">Please select a ' + refParent[targetName] + '</option>')

  setPolymorphics = (source)->
    return if ['', '0'].includes(source.val()) && !source.attr('id').includes('district')

    typeLowercase = parseId(source.attr('id'))
    type = typeLowercase[0].toUpperCase() + typeLowercase.substring(1)
    id = source.val()
    polyName = '#' + controllerName() + '_' + controllerName()
    $(polyName + 'able_type').val(type)
    $(polyName + 'able_id').val(id)

root              = exports ? this
root.LinkedSelect = LinkedSelect

  ## OLD VERSION

  # resetOptions = (target)->
  #   refParent = {
  #     cell: 'sector',
  #     village: 'cell',
  #     reportable_id: 'village'
  #   }
  #   targetName = target.attr('id').substr(target.attr('id').indexOf('_')+1)
  #   target.html('')
  #   target.append('<option></option>')
  #   $(target).append('<option disabled="disabled" value="0">Please select a ' + refParent[targetName] + '</option>')

  # ajaxGeography = (parentType, parentId, target)->
  #   # parentType = [sectors, cells, villages]
  #   # parentId = int
  #   # "/sectors/#{id}/children" returns cells
  #   # "/cells/#{id}/children" returns villages
  #   # "/villages/#{id}/children" returns facilities

  #   uri = '/' + parentType + '/' + parentId + '/children'
  #   $.ajax(
  #     url: uri
  #   ).done (response) ->
  #     prepareOptions(target, response)

  # appendOptionLoop = (record, target)->
  #   target.append('<option value="' + record.id + '">' + record.name + '</option>')

  # prepareOptions = (target, records)->
  #   target.html('')
  #   target.append('<option></option>')
  #   appendOptionLoop(record, target) for record in records



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
