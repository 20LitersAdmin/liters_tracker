# CURRENT:
0. Create Facility within Monthly#report doesn't close or update DOM

1. Story#show:
- needs edit button when `current_user.can_manage_reports? || current_user.admin?`
- Remove lines #9 && 10 (location)

2. Re-use basic_stat_block on Users#data

3. Re-write primary reporting flow
- replace Sectors#select and onward
- just use Reports#new
- auto-adding rows for new reports
- dynamic drop-downs && type-to-select for geography
- Stories are added from Monthly#index --> Monthly#show

4. Monthly#show should have previous && next buttons


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
