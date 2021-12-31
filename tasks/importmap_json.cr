class ImportmapJson < LuckyTask::Task
  summary "Display local importmap"
  name "importmap.json"

  def help_message
    <<-TEXT
    #{summary}

    $ lucky #{name}
    TEXT
  end

  def call
    importmap = Importmap::Json.from_json File.read(importmap_path)
    puts importmap.to_pretty_json
  end

  private def importmap_path
    Path.new(Dir.current, "public/importmap.json")
  end
end
