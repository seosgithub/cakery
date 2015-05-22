require 'securerandom'
require 'cakery'

RSpec.describe "Baking" do
  def cakery_path name
    return File.join(File.dirname(__FILE__), "assets/#{name}.cakery")
  end

  #go into ./spec/assets/proj/$project_name and use
  #it as a project folder
  def cd_proj name
    Dir.chdir File.join(File.dirname(__FILE__), "assets/proj/#{name}") do
      yield
    end
  end

  it "can run a no variable cakery file" do
    cp = cakery_path "test0"
    c = Cakery.new(cp) do |r|
    end

    c.bake
    expect(c.src).to eq("test\n")
  end

  it "can use a text variable in the cakery file" do
    cp = cakery_path "test1"
    secret = SecureRandom.hex

    c = Cakery.new(cp) do |r|
      r.secret = secret
    end

    c.bake
    expect(c.src).to eq("#{secret}\n")
  end


  it "can use a directory append" do
    cp = cakery_path "test2"

    c = Cakery.new(cp) do |r|
      r.secret << './secret/*'
    end

    cd_proj "test2" do
      c.bake
    end
    expect(c.src).to eq("hello world\n\n")
  end

  it "can use a directory append many" do
    cp = cakery_path "test3"

    c = Cakery.new(cp) do |r|
      r.secret << './secret/**/*'
    end

    cd_proj "test3" do
      c.bake
    end
    expect(c.src).to eq("hello world\n\n")
  end

  it "will not get depth if not requested" do
    cp = cakery_path "test3"

    c = Cakery.new(cp) do |r|
      r.secret << './secret/*'
    end

    cd_proj "test3" do
      c.bake
    end
    expect(c.src).to eq("\n")
  end

  it "supports macros" do
    cp = cakery_path "test4"

    class MyMacro < Cakery::Macro
      def process str
        out = ""
        str.split("\n").each do |line|
          if line =~ /hello/
            out += line.gsub(/hello/, "goodbye")
          else
            out += line
          end

          out += "\n"
        end
        out
      end
    end

    c = Cakery.new(cp) do |r|
      r.secret << MyMacro << './secret/*'
    end

    cd_proj "test4" do
      c.bake
    end

    #Started out with hello world 1, goodbye world 2 -> goodbye world 1, goodbye world 2
    expect(c.src).to eq("goodbye world 1\ngoodbye world 2\n\n")
  end

  it "supports stacked macros" do
    cp = cakery_path "test4"

    class MyMacro < Cakery::Macro
      def process str
        out = ""
        str.split("\n").each do |line|
          if line =~ /hello/
            out += line.gsub(/hello/, "goodbye")
          elsif line =~ /goodbye/
            out += line.gsub(/goodbye/, "fuck_you")
          else
            out += line
          end

          out += "\n"
        end
        out
      end
    end

    c = Cakery.new(cp) do |r|
      r.secret << MyMacro << MyMacro << './secret/*'
    end

    cd_proj "test4" do
      c.bake
    end

    #Started out with hello world 1, goodbye world 2 -> goodbye world 1, goodbye world 2
    expect(c.src).to eq("fuck_you world 1\nfuck_you world 2\n\n")
  end

  it "supports two dir sources to one variable" do
    cp = cakery_path "test5"

    c = Cakery.new(cp) do |r|
      r.secret << "./secret1/*"
      r.secret << "./secret2/*"
    end

    cd_proj "test5" do
      c.bake
    end
    expect(c.src).to eq("hello world\ngoodbye world\n\n")
  end
end
