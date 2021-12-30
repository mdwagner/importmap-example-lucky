class Shared::LayoutHead < BaseComponent
  needs page_title : String

  def importmap
    ImportMap.draw do |t|
      t.pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.0.0/lib/assets/compiled/rails-ujs.js"
      t.pin "turbolinks", to: "https://ga.jspm.io/npm:turbolinks@5.2.0/dist/turbolinks.js"
      t.pin "alpinejs", to: "https://ga.jspm.io/npm:alpinejs@3.7.1/dist/module.esm.js"
      t.pin "react", to: "https://ga.jspm.io/npm:react@18.0.0-rc.0-next-f2a59df48-20211208/index.js"

      t.scope "https://ga.jspm.io/", {
        "object-assign" => "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
      }
    end
  end

  def render
    head do
      utf8_charset
      title "My App - #{@page_title}"

      js_link "https://cdn.tailwindcss.com"
      tag "script" do
        raw <<-JS
        tailwind.config = {
          theme: {
            extend: {
              colors: {
                clifford: '#da373d'
              }
            }
          }
        }
        JS
      end

      js_link "https://ga.jspm.io/npm:es-module-shims@0.12.8/dist/es-module-shims.min.js", crossorigin: "anonymous", attrs: [:async]
      raw importmap.to_importmap_html_tags
      js_link asset("js/app.js"), defer: "true", type: "module", data_turbolinks_track: "reload"

      meta name: "turbolinks-cache-control", content: "no-cache"
      csrf_meta_tags
      responsive_meta_tag
    end
  end
end
