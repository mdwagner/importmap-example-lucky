# This file may be used for custom Application configurations.
# It will be loaded before other config files.
#
# Read more on configuration:
#   https://luckyframework.org/guides/getting-started/configuration#configuring-your-own-code
module Application
  Habitat.create do
    setting importmap : ImportMap
  end
end

Application.configure do |settings|
  json = File.read(Path.new(Dir.current, "public/importmap.json"))
  settings.importmap = ImportMap.from_json(json) do |map|
    map.preload "alpinejs"
  end
end
