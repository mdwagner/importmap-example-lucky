require "http/client"
require "file_utils"
require "uri"

class ImportmapPin < LuckyTask::Task
  summary "Manage importmap pinning"
  name "importmap.pin"

  switch :download, "Downloads packages to public/assets/js"
  arg :env, "Environment of packages (default: production)",
      shortcut: "-e",
      optional: true
  arg :from, "CDN to download from (default: jspm)",
      shortcut: "-f",
      optional: true

  def help_message
    <<-TEXT
    #{summary}

    Pin package(s) from CDN to importmap.json
    $ lucky importmap.pin react react-dom

    Pin (development) package(s) from CDN to importmap.json
    $ lucky importmap.pin react react-dom -e development

    Vendor package(s) from CDN to importmap.json
    $ lucky importmap.pin react react-dom --download
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

    if json.dig?("map", "imports")
      importmap_query = Importmap::Json.from_json json["map"].to_json

      importmap_json = (
        if File.exists?(importmap_path)
          Importmap::Json.from_json File.read(importmap_path)
        else
          Importmap::Json.with_defaults
        end
      )

      if download?
        importmap_query.imports.each do |package, url|
          download_package(package, url)
          importmap_query.imports[package] = asset_package_path(package)
        end
        importmap_query.scopes = nil
      end

      importmap_query.imports.each do |package, path|
        puts %(Pinning "#{package}" to #{path}) if URI.parse(path).scheme
        importmap_json.imports[package] = path
      end

      if !download? && importmap_query.scopes?
        if importmap_json.scopes?
          importmap_json.scopes.merge!(importmap_query.scopes)
        else
          importmap_json.scopes = importmap_query.scopes
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

  private def development?
    _env == "development"
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
    Path.new(Dir.current, "public/importmap.json")
  end

  private def download_package(package, url)
    FileUtils.mkdir_p vendor_path

    response = HTTP::Client.get(url)
    raise "Failed to download #{package}" unless response.success?

    version = package_version_from(url)
    source = modify_content(response.body, version)
    path = vendored_package_path(package)

    puts %(Pinning "#{package}" to #{path} via download from #{url})

    File.write(path, source)
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

  private def modify_content(source, version = nil)
    # remove sourcemap comment
    source = source.gsub(/\/\/#\s+sourceMappingURL=.*/, "") unless development?

    # prepend package version
    source = "/* #{version} */\n" + source if version

    source
  end

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
