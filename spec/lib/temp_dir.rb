def new_temp_dir
  #Get a new temporary directory
  temp = Tempfile.new SecureRandom.hex
  path = temp.path
  temp.close!

  FileUtils.mkdir_p path
  return path
end

class Tempdir
  attr_accessor :path

  def initialize
    #Create a new directory
    @path = new_temp_dir
  end

  def [](rel)
    return TempDirFile.new(@path, rel)
  end

  def cd
    Dir.chdir @path do
      yield
    end
  end
end

class TempDirFile
  def initialize path, rel
    @path = path
    @rel = rel
  end

  def puts str

    Dir.chdir @path do
      #Create all folders
      FileUtils.mkdir_p File.dirname(@rel)

      FileUtils.touch(@rel)

      open(@rel, "a") do |f|
        f.write str
      end
    end
  end
end

def dirs
  Dir["**/*"].select{|e| File.directory?(e)}
end

def files
  Dir["{*,.*}"].select{|e| File.file?(e)} #Match dotfiles and normal files
end
