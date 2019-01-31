# LITERS TRACKER
A custom reporting app for 20 Liters

* 'Add plan' && 'Add report' buttons on technologies#show?by_sector don't do anything, but should
- POLICED by current_user.can_create('Report') && current_user.can_create('Plan')

* technologies#show?by_mou could have 'Add Target' button if it's missing, but these should be buit with each new MOU

* technologies#index should also have buttons? [Add Plan, Add Report, Add Target]

* Submitting a report needs to be intuitive for the user
-- Each technology independently
--- Tech.scale == "Family", show villages, Tech.scale == "Community", show facilities
--- Add facilities on the fly
--- SAM3 should have # of people served (for greater accuracy), default to 5 on Report.people_served

# More reports:
* By Geography:
- villages#index is too complex to bother with?
- villages#show
--> by facilities per village, using Plan
--> by technologies, using Target

- facilities#index - make searchable?
- facilities#show is pointless?

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.people_served | Target.people_goal ]
-- By sector: [ Report.people_served | Target.people_goal ]

# Creating Targets

# Creating Plans

# Creating Reports

# Forms
-- redirect_back on model#create and #update isn't UX
- Tech form
- Contract form
- Target form
- Plan form
- Dist form
- Sector form
- Cell form
- Village form
- Facility form
  -- facility.impact sums population and households, the form should note to not duplicate these values

# Managing User Permissions
- Or handle all within custom user routes and kill the permissions_controller
-- NO NO NO! Just use some booleans on User and KILL Permisisons, controller, policy, specs, views, etc.
-- Still need to scrape current_user.can_* out of views, replace with .can_manage_*

# Bugs?
- JS call to /favicons?
- Devise mail doesn't send? Mailgun shows nothing going out.
- No reports on cell#index or village#index because of length, must get to them by sector

# Improvements
- Districts#index doesn't have [Add Plan, Add Report, Add Target] functionality
- Technologies#index doesn't have [Add Plan, Add Report, Add Target] functionality

# SPEED
- check which is faster: `@reports.related_to_village(village)` or `village.related_reports`
  -- Affects all reporting partials


# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
