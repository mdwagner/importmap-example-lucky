class Shared::LayoutHead < BaseComponent
  needs page_title : String

  def render
    head do
      utf8_charset
      title "My App - #{@page_title}"

      js_link "https://cdn.tailwindcss.com"

      es_module_shims
      importmap_html_tags

      js_link asset("js/app.js"),
              type: "module",
              defer: "true",
              data_turbolinks_track: "reload"

      meta name: "turbolinks-cache-control", content: "no-cache"
      csrf_meta_tags
      responsive_meta_tag
    end
  end

  private def es_module_shims
    src = Application.settings.importmap.json.imports["es-module-shims"]
    js_link src, crossorigin: "anonymous", attrs: [:async]
  end

  private def importmap_html_tags
    importmap = Application.settings.importmap
    raw importmap.to_importmap_html_tags(true)
  end
end
