require "http/client"
require "file_utils"

class ImportmapPin < LuckyTask::Task
  summary "Pin <package> from CDN to importmap.json"
  name "importmap.pin"

  switch :download, "Downloads packages to IMPORTMAP_VENDOR"
  arg :env, "Environment of packages (ex: dev/prod)", shortcut: "-e", optional: true
  arg :from, "CDN to download from", shortcut: "-f", optional: true

  def help_message
    <<-TEXT
    ENV variables:
    - LUCKY_IMPORTMAP_PATH => location of importmap.json (defaults to <root>/public/importmap.json)

    # Pin "package" CDN to importmap.json
    $ lucky importmap.pin react

    # Pin "package" from CDN to vendor folder and importmap.json
    $ lucky importmap.pin react --download
    TEXT
  end

  def call
    Log.setup(:info)

    response = post_json({
      "install"      => _packages,
      "flattenScope" => true,
      "env"          => ["browser", "module", _env],
      "provider"     => _from,
    })

    json = JSON.parse(response.body)

    raise json.to_pretty_json unless response.success?

    if imports = json.dig?("map", "imports")
      fetched_importmap = Importmap::Json.from_json json["map"].to_json

      importmap_json = (
        if File.exists?(importmap_path)
          Importmap::Json.from_json File.read(importmap_path)
        else
          Importmap::Json.with_defaults
        end
      )

      if download?
        fetched_importmap.imports.each do |package, url|
          download_package(package, url)
          fetched_importmap.imports[package] = asset_package_path(package)
        end
        fetched_importmap.scopes = nil
      end

      fetched_importmap.imports.each do |package, path|
        importmap_json.imports[package] = path
      end

      if !download? && fetched_importmap.scopes?
        if importmap_json.scopes?
          # TODO: not sure if merge! is right approach...
          importmap_json.scopes.merge!(fetched_importmap.scopes)
        else
          importmap_json.scopes = fetched_importmap.scopes
        end
      end

      File.write(importmap_path, importmap_json.to_pretty_json)
    else
      puts "Couldn't find any packages in #{_packages.inspect} on #{_from}"
    end
  end

  private def _packages : Array(String)
    ARGV
  end

  private def _env
    env || "production"
  end

  private def _from
    from || "jspm"
  end

  private def post_json(body)
    url = "https://api.jspm.io/generate"
    headers = HTTP::Headers{"Content-Type" => "application/json"}
    HTTP::Client.post(url, headers: headers, body: body.to_json)
  end

  private def vendor_path
    Path.new(Dir.current, "public/assets/js")
  end

  private def importmap_path
    if path = ENV["LUCKY_IMPORTMAP_PATH"]?
      Path.new File.expand_path(path)
    else
      Path.new(Dir.current, "public/importmap.json")
    end
  end

  private def download_package(package, url)
    FileUtils.mkdir_p vendor_path

    response = HTTP::Client.get(url)
    raise "Failed to download #{package}" unless response.success?
    source = remove_sourcemap_comment_from(response.body)

    File.write(vendored_package_path(package), source)
  end

  private def update_importmap_json(importmap_json, package, path)
    importmap_json.imports[package] = path
  end

  private def vendored_package_path(package)
    vendor_path.join(package_filename(package))
  end

  private def package_filename(package)
    package.gsub("/", "--") + ".js"
  end

  private def remove_sourcemap_comment_from(source)
    source.gsub(/\/\/#\s+sourceMappingURL=.*/, "")
  end

  # TODO: need to figure out if this should be included anywere...
  private def package_version_from(url)
    url.match(/@\d+\.\d+\.\d+/).try &.to_a.try(&.first)
  end

  private def asset_package_path(package)
    asset_host = Lucky::Server.settings.asset_host
    unless asset_host.ends_with?("/")
      asset_host += "/"
    end
    asset_host + "assets/js/#{package_filename(package)}"
  end
end

# class ImportmapUnpin < LuckyTask::Task
# summary "Unpin <package> from importmap.json and remove local file(s) in vendor folder"
# name "importmap.unpin"

# def help_message
# <<-TEXT
# ENV variables:
# - IMPORTMAP_PATH => location of importmap.json (defaults to <root>/public/importmap.json)

# # Unpin "package" from importmap.json and remove local files in vendor forlder
# $ lucky importmap.unpin react
# TEXT
# end

# def call
# end
# end

# class ImportmapJson < LuckyTask::Task
# summary "Display importmap.json"
# name "importmap.json"

# def help_message
# <<-TEXT
# #{summary}
# ENV variables:
# - IMPORTMAP_PATH => location of importmap.json (defaults to <root>/public/importmap.json)

# # Show importmap.json pretty formatted to STDOUT
# $ lucky importmap.json
# TEXT
# end

# def call
# end
# end
