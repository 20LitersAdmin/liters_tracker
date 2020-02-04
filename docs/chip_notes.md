# CURRENT:
0. Next deploy: `rails db:migrate` to make `Report#contract_id` optional

3. Tweak reporting workflow
- sectors#select is fine
- don't show every village and facility on sectors#report
- show existing reports
  - provide 1 new report row at a time
  - dynamic drop-downs && type-to-select for geography
- Stories are added from Monthly#index --> Monthly#show

- TODO: why is this?? sectors_controller#new_facility && sector_policy#new_facility? && routes#sectors#new_facility

5. Deleting a Facility that has associated Reports:
- Need to re-assign associated reports before deleting facility

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


Technology.first.tap do |t|
  t.description = "SAM3 (Sand And Membrane) filters are placed in households for a family and their neighbors. They meet WHO's standards and requires no electricity to function, making it ideal for rural communities. Each family receives extensive training and ongoing volnteer support to maintain the filter for it's 10-year-plus lifespan."
  t.image_name = "SAM3.png"
  t.save
end

Technology.find(3).tap do |t|
  t.description = "SAM2 (Sand And Membrane) filters are large capacity solutions with a 10-year-plus lifespan. A SAM2 requires no electricity or fuel and has no moving parts, making it the ideal solution for rural areas. Schools and Health Clinics are trained how to use and maintain the filter, empowering them to be self-sufficient and address their own needs."
  t.image_name = "SAM2.jpg"
  t.save
end

Technology.find(5).tap do |t|
  t.description = "We place these rainwater collection tanks at centrally-located churches, which shortens the walk for water and improves water quality. Churches sell the water at an affordable rate and use the income to maintain the system. Remaining funds are given to the poorest members of the community for school fees, health insurance, and other basic needs."
  t.image_name = "RWHS.png"
  t.save
end

Technology.find(6).tap do |t|
  t.description = "Our 150-liter bio-sand filter generates enough clean water that two or three families can easily share them. We use these filters in places where the water is so muddy and foul that no other filter could handle it. Each family receives extensive training and ongoing volnteer support to maintain the filter, which can last indefinately."
  t.image_name = "SSF.png"
  t.save
end
