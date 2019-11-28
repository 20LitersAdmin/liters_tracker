# POST C4G:
* Upgrade to Ruby 2.5.7
* Story:
  - Handle rotate_image()
  - live test the image processes: In the controller, call localize_image!(image_io), which calls resize_image. Then save the image to use the callbacks.
* Story _form:
  - Handle eager-loading stories
  - Handle rotating images (on edit, then on new)

# CURRENT:
- Story#form #image_preview error:
New strategy:
1. Create the story first (no image)
2. Redirect to `stories/:id/image` to upload the photo
3. After photo is uploaded (can try to hook: https://stackoverflow.com/a/53226455/1880203)
4. Reload the `stories/:id/image` page to edit the photo
5. "Finalize" button takes you to `stories/:id`

# from amanda
* Try to make it feel like we're on 20L/blog/updates to some extent.
* Dashboard stats: bigger #s, vertically center in box
* Dasboard collection: banding on bottom of photo instead of card text (brand style banding).
* Story#show: banner image universal (jerrycans), show image in body of page, next to story title and text. Then put "back" and "donate buttons over top of it".
* Spell check story input?
* Add technology to Story#show info section

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
* magic_frozen_string_literal . #get those frozen string benefits
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
