$(document).on 'turbolinks:load', ->
  return unless controllerMatches(['facilities', 'sectors', 'contracts']) &&
    actionMatches(['new', 'edit', 'create', 'update', 'report', 'plan', 'reassign'])

  $('#facility_district').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_sector').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#facility_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))

  $('#sector_cell').on 'change', ->
    LinkedSelect.updateChildSelectors($(this))


  # Facilities#reassign
  $('table#dttb_reassign_facilities').DataTable
    columnDefs: [ {
      "searchable": false,
      "orderable": false,
      "targets": [-1]
    } ]
    pagingType: 'full_numbers'
    language: {
      paginate: {
        first: "&#8676",
        previous: "&#8592",
        next: "&#8594",
        last: "&#8677"
      }
    }
