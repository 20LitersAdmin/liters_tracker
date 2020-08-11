# LinkedSelect is Global Linked Select field, comes from finders.coffee

$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['contracts']) &&
    actionMatches(['plan'])

  # handle datepicker on contract#plan:_facility_form
  dateStr = getParameterByName('date')
  date = moment(dateStr, 'YYYY-MM-DD')
  first = date.startOf('month').format('YYYY-MM-DD')
  last = date.endOf('month').format('YYYY-MM-DD')

  # init datetimepickers
  $('#plan_date.datetimepicker-input').datetimepicker({
    format: 'YYYY-MM-DD',
    useCurrent: false,
    minDate: first,
    maxDate: last,
    viewDate: date.startOf('month'),
    widgetPositioning: {
      horizontal: 'auto',
      vertical: 'bottom'
    }
  })

  # init dttb_community_plans on Contracts#plan
  $('table#dttb_contract_plans').dataTable
    order: [0, 'asc'],
    columnDefs: [ {
      "searchable": false,
      "orderable": false,
      "targets": [-1, -2]
    } ],
    pagingType: 'full_numbers'
    language: {
      paginate: {
        first: "&#8676",
        previous: "&#8592",
        next: "&#8594",
        last: "&#8677"
      }
    }


  # existing plans delete button:
  # remove the deleted row from the table views using DataTables API
  $(document).on 'ajax:success', '.contract-plan-delete', ->
    $('#dttb_contract_plans').DataTable()
      .row( $(this).parents('tr') )
      .remove()
      .draw()


  # _facility_form
  $('#plan_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')

  $('#plan_village.facility-form').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')

  $('#plan_village.village-form').on 'change', ->
    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')
    else
      LinkedSelect.forcePolymorphics($(this), 'id')

  $('#plan_facility').on 'change', ->
    if ['', '0'].includes($(this).val())
      LinkedSelect.clearPolymorphics($(this), 'id')
    else
      LinkedSelect.forcePolymorphics($(this), 'id')
