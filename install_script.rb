name = ask("What is the name of your app?")
description = ask("What is the description of your app?")

inject_into_file 'config/routes.rb', before: /end$/ do
  <<-RUBY
    get "webmanifest"    => "pwa#manifest"
    get "service-worker" => "pwa#service_worker"
  RUBY
end

  
create_file 'app/controllers/pwa_controller.rb' do
  <<-RUBY
    class PwaController < ApplicationController
      skip_before_action :authenticate_user!
      skip_forgery_protection

      def service_worker
      end

      def manifest
      end
    end
  RUBY
end

FileUtils.mkdir_p('app/views/pwa')

create_file 'app/views/pwa/manifest.json.erb' do
  <<-ERB
    {
      "name": "#{name}",
      "icons": [
        {
          "src": "<%= image_url("app-icon-192.png") %>",
          "type": "image/png",
          "sizes": "192x192"
        },
        {
          "src": "<%= image_url("app-icon-512.png") %>",
          "type": "image/png",
          "sizes": "512x512"
        },
        {
          "src": "<%= image_url("app-icon-512.png") %>",
          "type": "image/png",
          "sizes": "512x512",
          "purpose": "maskable"
        }
      ],
      "start_url": "/",
      "display": "standalone",
      "scope": "/",
      "description": "#{description}",
      "theme_color": "#ffffff",
      "background_color": "#ffffff"
    }
  ERB
end

create_file 'app/views/pwa/service_worker.js' do
  "console.log('Hello from the service worker!')"
end

run "curl -L https://raw.githubusercontent.com/trazip/pwa_setup/master/images/app-icon-192.png -o app/assets/images/app-icon-192.png"
run "curl -L https://raw.githubusercontent.com/trazip/pwa_setup/master/images/app-icon-512.png -o app/assets/images/app-icon-512.png"


inject_into_file 'app/views/layouts/application.html.erb', before: '<%= csrf_meta_tags %>' do
  <<-HTML
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no, user-scalable=no">
    <meta name="mobile-web-app-capable" content="yes">
    <%= tag.link rel: "manifest", href: webmanifest_path(format: :json) %>
    <%= tag.link rel: "icon", href: image_url("app-icon-512.png"), type: "image/png" %>
    <%= tag.link rel: "apple-touch-icon", href: image_url("app-icon-512.png") %>

  HTML
end


say "PWA setup completed successfully!", :green
