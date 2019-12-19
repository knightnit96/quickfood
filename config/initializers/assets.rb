# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += %w(video_header.js theia-sticky-sidebar/dist/ResizeSensor.min.js theia-sticky-sidebar/dist/theia-sticky-sidebar.min.js)
Rails.application.config.assets.precompile += %w(custom_sidebar.js custom_datetime.js session.js place.js custom_profile.js custom_place.js custom_shipper.js live_chat.js map_order.js ajax_rating.js admin/custom_admin.js)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
