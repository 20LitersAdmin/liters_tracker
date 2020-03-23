$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities', 'sectors', 'reports']) &&
    actionMatches(['new', 'edit', 'create', 'update', 'report'])

  # AJAX look up child objects from a parent
  # e.g. /sectors/2/children
  # returns a select_field ready array of [:id, :name]

  resetOptions = (target)->
    refParent = {
      cell: 'sector',
      village: 'cell',
      reportable_id: 'village'
    }
    targetName = target.attr('id').substr(target.attr('id').indexOf('_')+1)
    target.html('')
    target.append('<option></option>')
    $(target).append('<option disabled="disabled" value="0">Please select a ' + refParent[targetName] + '</option>')

  ajaxGeography = (parentType, parentId, target)->
    # parentType = [sectors, cells, villages]
    # parentId = int
    # "/sectors/#{id}/children" returns cells
    # "/cells/#{id}/children" returns villages
    # "/villages/#{id}/children" returns facilities

    uri = '/' + parentType + '/' + parentId + '/children'
    $.ajax(
      url: uri
    ).done (response) ->
      prepareOptions(target, response)

  appendOptionLoop = (record, target)->
    target.append('<option value="' + record.id + '">' + record.name + '</option>')

  prepareOptions = (target, records)->
    target.html('')
    target.append('<option></option>')
    appendOptionLoop(record, target) for record in records


  # called from facilities#new
  $('#facility_sector').on 'change', ->
    sectorId = $(this).val()
    villageTarget = $('#facility_village')
    resetOptions(villageTarget)
    cellTarget = $('#facility_cell')
    if sectorId > 0
      ajaxGeography('sectors', sectorId, cellTarget)
    else
      resetOptions(cellTarget)

  # called from facilities#new && sectors#report:facilities/_modal_form
  $('#facility_cell').on 'change', ->
    cellId = $(this).val()
    target = $('#facility_village')
    resetOptions(target)
    if cellId > 0
      ajaxGeography('cells', cellId, target)

  # called from sectors#report:_village_form && _facility_form
  $('#report_cell').on 'change', ->
    cellId = $(this).val()
    villageTarget = $('#report_village')
    facilityTarget = $('#report_reportable_id')
    resetOptions(facilityTarget)
    if cellId > 0
      ajaxGeography('cells', cellId, villageTarget)
    else
      resetOptions(villageTarget)

  # called from sectors#report:_facility_form
  $('#report_village').on 'change', ->
    villageId = $(this).val()
    target = $('#report_reportable_id')
    resetOptions(target)
    if villageId > 0
      ajaxGeography('villages', villageId, target)
