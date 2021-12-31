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
  end
end
