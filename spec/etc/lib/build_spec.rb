Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/lib/temp_dir'
require './lib/flok'

RSpec.describe "lib/build" do
  it "Can src_glob_r where it includes init, config, lower directories, sub directories, and final" do
    dir = Tempdir.new

    #Init
    dir["init/init_test.js"].puts "init_test"
    dir["init/init/init/init_test.js"].puts "init_test"
    dir["init/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "init_test"
    dir["init/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "init_test"


#Config
    dir["config/config_test.js"].puts "config_test"
    dir["config/config/config/config_test.js"].puts "config_test"
    dir["config/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "config_test"
    dir["config/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "config_test"

    #Root
    dir["qunit.js"].puts "root_test"
    dir["root.hello.js"].puts "root_test"
    dir["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "root_test"

    #Nested
    dir["controllers/debug_spec.js"].puts "nested_test"
    dir["controllers/sel_scope_spec.js"].puts "nested_test"
    dir["controllers/vars_spec.js"].puts "nested_test"
    dir["ui/debug_spec.js"].puts "nested_test"
    dir["nested/nested_test.js"].puts "nested_test"
    dir["nested/nested/nested_test.js"].puts "nested_test"
    dir["nested/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"
    dir["nested/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"

    #Nested
    dir["nested/0nested_test.js"].puts "nested_test"
    dir["nested/0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"
    dir["nested/0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"

    #Final folder
    dir["final/final_test.js"].puts "final_test"
    dir["final/final/final/final_test.js"].puts "final_test"
    dir["final/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "final_test"
    dir["final/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "final_test"



    #Glob into the file out
    dir.cd do
      Flok.src_glob_r "js", ".", "out"
      out = File.read("out")
      outs = out.split("\n")

      expect(outs.shift).to eq("init_test")
      expect(outs.shift).to eq("init_test")
      expect(outs.shift).to eq("init_test")
      expect(outs.shift).to eq("init_test")

      expect(outs.shift).to eq("config_test")
      expect(outs.shift).to eq("config_test")
      expect(outs.shift).to eq("config_test")
      expect(outs.shift).to eq("config_test")


      expect(outs.shift).to eq("root_test")
      expect(outs.shift).to eq("root_test")
      expect(outs.shift).to eq("root_test")
      
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")

      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")
      expect(outs.shift).to eq("nested_test")

      expect(outs.shift).to eq("final_test")
      expect(outs.shift).to eq("final_test")
      expect(outs.shift).to eq("final_test")
      expect(outs.shift).to eq("final_test")
    end
  end

  it "src_glob_r supports relative pathing" do
    dir = Tempdir.new

    #Config
    dir["config/config_test.js"].puts "config_test"
    dir["config/config/config/config_test.js"].puts "config_test"
    dir["config/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "config_test"
    dir["config/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "config_test"
    #Init
    dir["init/init_test.js"].puts "init_test"
    dir["init/init/init/init_test.js"].puts "init_test"
    dir["init/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "init_test"
    dir["init/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.js"].puts "init_test"

    #Root
    dir["qunit.js"].puts "root_test"
    dir["root.hello.js"].puts "root_test"
    dir["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "root_test"

    #Nested
    dir["controllers/debug_spec.js"].puts "nested_test"
    dir["controllers/sel_scope_spec.js"].puts "nested_test"
    dir["controllers/vars_spec.js"].puts "nested_test"
    dir["ui/debug_spec.js"].puts "nested_test"
    dir["nested/nested_test.js"].puts "nested_test"
    dir["nested/nested/nested_test.js"].puts "nested_test"
    dir["nested/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"
    dir["nested/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"

    #Nested
    dir["nested/0nested_test.js"].puts "nested_test"
    dir["nested/0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"
    dir["nested/0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.hello.js"].puts "nested_test"

    #Glob into the file out
    dir.cd do
      pwd = Dir.pwd
      Dir.chdir "../" do
        Flok.src_glob_r "js", pwd, "out"
        out = File.read("out")
        outs = out.split("\n")
        
        expect(outs.shift).to eq("init_test")
        expect(outs.shift).to eq("init_test")
        expect(outs.shift).to eq("init_test")
        expect(outs.shift).to eq("init_test")

        expect(outs.shift).to eq("config_test")
        expect(outs.shift).to eq("config_test")
        expect(outs.shift).to eq("config_test")
        expect(outs.shift).to eq("config_test")


        expect(outs.shift).to eq("root_test")
        expect(outs.shift).to eq("root_test")
        expect(outs.shift).to eq("root_test")
        
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")

        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
        expect(outs.shift).to eq("nested_test")
      end
    end
  end

  it "does glob in alphabetical order" do
    dir = Tempdir.new

    #Init
    dir["0test.js"].puts "0"
    dir["1test.js"].puts "1"
    dir["atest.js"].puts "2"
    dir["ztest.js"].puts "3"
    dir["zzzz.js"].puts "4"
    dir["nested/aaa.js"].puts "5"
    dir["nested/zzzz.js"].puts "6"

    dir.cd do
      Flok.src_glob_r "js", ".", "out"
      r = File.read("out").split("\n")
      expect(r.shift).to eq("0")
      expect(r.shift).to eq("1")
      expect(r.shift).to eq("2")
      expect(r.shift).to eq("3")
      expect(r.shift).to eq("4")
      expect(r.shift).to eq("5")
      expect(r.shift).to eq("6")
    end
  end
end
