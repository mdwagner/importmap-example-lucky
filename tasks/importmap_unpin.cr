require "file_utils"
require "uri"

class ImportmapUnpin < LuckyTask::Task
  summary "Manage importmap unpinning"
  name "importmap.unpin"

  def help_message
    <<-TEXT
    #{summary}

    Unpin package(s) from importmap.json and remove (any) vendored files
    $ lucky #{name} react react-dom
    TEXT
  end

  def call
    importmap_json = Importmap::Json.from_json File.read(importmap_path)

    packages.each do |package|
      next unless importmap_json.imports[package]?

      asset_path = importmap_json.imports[package]

      next if URI.parse(asset_path).scheme

      realpath = Path.new(Dir.current, "public", asset_path)

      puts %(Unpinning and removing "#{package}")

      importmap_json.imports.delete package

      FileUtils.rm realpath
    end

    File.write(importmap_path, importmap_json.to_pretty_json)
  end

  private def packages
    ARGV
  end

  private def importmap_path
    Path.new(Dir.current, "public/importmap.json")
  end
end
