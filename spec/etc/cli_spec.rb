Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/etc'
require './lib/flok'

require 'tempfile'
require 'securerandom'

#Specifications for the ./bin/flok utility

#Execute flok binary
def flok args
  #Get path to the flok binary relative to this file
  bin_path = File.join(File.dirname(__FILE__), "../../bin/flok")
  lib_path = File.join(File.dirname(__FILE__), "../../lib")

  #Now execute the command with a set of arguments
  system("ruby -I#{lib_path} #{bin_path} #{args}")
end

#Create a new flok project named test and go into that directory
def flok_new 
  temp_dir = new_temp_dir
  Dir.chdir temp_dir do
    flok "new test"
    Dir.chdir "test" do
      yield
    end
  end
end

RSpec.describe "CLI" do
 it "Can create a new project with correct directories" do
    flok_new do
      #Should include all entities in the project template with the exception
      #of erb extenseded entities (which will still be included, but they each
      #will not have the erb ending
      template_nodes = nil
      Dir.chdir File.join(File.dirname(__FILE__), "../../lib/flok/project_template") do
        template_nodes = Dir["**/*"].map{|e| e.gsub(/\.erb$/i, "")}
      end
      new_proj_nodes = Dir["**/*"]
      $stderr.puts "Flok version = #{Flok::VERSION}"
      expect(new_proj_nodes).to eq(template_nodes)

      expect(files).to include("Gemfile")
    end
  end

  it "Can build a project with every type of platform" do
    Flok.platforms.each do |platform|
      flok_new do
        #Build a new project
        flok "build #{platform}"

        #Check it's products directory
        expect(dirs).to include "products"
        Dir.chdir "products" do
          #Has a platform folder
          expect(dirs).to include platform
          Dir.chdir platform do
            #Has an application_user.js file
            expect(files).to include "application_user.js"

            #The application_user.js contains both the glob/application.js and the glob/user_compiler.js
            glob_application_js = File.read('glob/application.js')
            glob_user_compiler_js = File.read('glob/user_compiler.js')
            application_user_js = File.read('application_user.js')
            expect(application_user_js).to include(glob_application_js)
            expect(application_user_js).to include(glob_user_compiler_js)

            #Contains the same files as the kernel in the drivers directory
            expect(dirs).to include "drivers"
          end
        end
      end
    end
  end

  it "Can build a project with a controller file for each platform" do
    #Compile and then return the length of the application_user.js file
    def compile_with_file path=nil
      #Custom controller to test source with
      controller_src = File.read(path) if path
      flok_new do
        File.write "./app/controllers/controller0.rb", controller_src if path

        #Build a new project
        flok "build #{@platform}"

        #Check it's products directory
        Dir.chdir "products" do
          #Has a platform folder
          Dir.chdir @platform do
            glob_application_js = File.read('glob/application.js')
            glob_user_compiler_js = File.read('glob/user_compiler.js')
            application_user_js = File.read('application_user.js')

            return application_user_js.split("\n").count
          end
        end
      end
    end

    Flok.platforms.each do |platform|
      @platform = platform
      controller_rb = File.read('./spec/etc/user_compiler/controller0.rb')

      

      #The file with content should be longer when compiled into the flat application_user.js
      len_with_content = compile_with_file "./spec/etc/user_compiler/controller0.rb"
      len_no_content = compile_with_file

      expect(len_no_content).to be < len_with_content
    end
  end
end
