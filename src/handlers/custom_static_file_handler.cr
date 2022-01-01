# Changing ETAG to be checksum of file contents
class CustomStaticFileHandler < HTTP::StaticFileHandler
  @_file_path : String? = nil

  private def modification_time(file_path)
    @_file_path = file_path.to_s
    super(file_path)
  end

  private def etag(modification_time)
    if file_path = @_file_path
      contents = File.read(file_path)
      Digest::MD5.hexdigest(contents)
    else
      super(modification_time)
    end
  end
end
