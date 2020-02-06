# CURRENT:
0. Next deploy:
- `rails db:migrate` to make `Report#contract_id` optional

3. Tweak reporting workflow
- Test http://localhost:3000/sectors/2/report?date=2014-02-01&tech=1
- Test http://localhost:3000/sectors/3/report?date=2014-04-01&tech=3
- Add New Facility no longer works:
-- Need to write `facility_created.js.erb` to match `report_created.js.erb`
- reports#create needs to check for an existing duplicate first

4. What about un-met plans?
- Help Rebero see work to be accomplished by Sector

- Stories are added from Monthly#index --> Monthly#show
-- include ability to add story from sectors#report?

- TODO: why is this?? sectors_controller#new_facility && sector_policy#new_facility? && routes#sectors#new_facility

5. Deleting a (duplicate) Facility that has associated Reports:
- Need to re-assign reports before deleting facility

# Creating/Updating Targets

# Creating/Updating Plans
* Copy the sector/select && sector/#id/report process

# Forms
- Tech form
- Contract form
- Target form
- Plan form

# Geography forms (also need a chooser view)
- Country form
- District form
- Sector form
- Cell form
- Village form

# Indexes need:
- Facilities: datatables (replace will_paginate)
- Reports: datatables (replace will_paginate)
- all geographies: datatables (replace will_paginate)

# Shows need:
- Facility: reports / plans

# Remind myself:
* `magic_frozen_string_literal . #get those frozen string benefits`
* production backup / development restore-from production (https://github.com/thoughtbot/parity)
  `User.first.update(password: 'password', password_confirmation: 'password')`
* byebug commands
    continue   -- Runs on
    delete     -- Deletes breakpoints
    finish     -- Runs the program until frame returns
    irb        -- Starts an IRB session
    kill       -- Sends a signal to the current process
    quit       -- Exits byebug
    restart    -- Restarts the debugged program
