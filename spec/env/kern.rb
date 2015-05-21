require 'therubyracer'
require './spec/lib/temp_dir'

shared_context "kern" do
  before(:each) do
    res=system('rake build:world')
    raise "Could not run build:world" unless res
    @ctx = V8::Context.new
    @ctx.load "./products/#{ENV['PLATFORM']}/application.js"

    if ENV['RUBY_PLATFORM'] =~ /darwin/
      `killall phantomjs`
      `killall rspec`
    end
  end

  #Execute flok binary with a command
  def flok args
    #Get path to the flok binary relative to this file
    bin_path = File.join(File.dirname(__FILE__), "../../bin/flok")

    #Now execute the command with a set of arguments
    system("#{bin_path} #{args}")
  end

  #Create a new flok project, add the given user_file (an .rb file containing controllers, etc.)
  #and then retrieve a V8 instance from this project's application_user.js
  def flok_new_user user_controllers_src
    temp_dir = new_temp_dir
    Dir.chdir temp_dir do
      flok "new test"
      Dir.chdir "test" do
        #Put controllers in
        File.write './app/controllers/user_controller.rb', user_controllers_src

        #Build
        flok "build chrome" #Will generate drivers/ but we will ignore that

        #Execute
        @driver = FakeDriverContext.new
        v8 = V8::Context.new(:with => @driver)
        @driver.ctx = v8
        v8.eval %{
          //We must convert this to JSON because the fake driver will receive
          //a raw v8 object otherwise
          function if_dispatch(q) {
            if_dispatch_json(JSON.stringify(q));
          }
        }
        v8.eval File.read('./products/chrome/application_user.js')
        return v8
      end
    end
  end

  #This supports if_dispatch interface and allows for sending information back via 
  #int_dispatch to the kernel. It is embededd into the v8 context environment
  class FakeDriverContext
    include RSpec::Matchers 

    attr_accessor :ctx
    def initialize
      @q = []  #Full queue, 2 dimensional all priority 
      @cq = nil #Contains only the current working priority
      @cp = nil #Contains the current priority
    end

    def if_dispatch_json q
      @q += JSON.parse(q)
    end

    #Expect a certain message, with some arguments, and a certain priority
    #expect("if_init_view", ["test_view", {}]) === [[0, 4, "if_init_view", "test_view", {}]]
    def mexpect(msg_name, msg_args, priority=0)
      #Dequeue from multi-priority queue if possible
      if @cq.nil? or @cq.count == 0
        @cq = @q.shift
        @cp = @cq.shift #save priority
      end

      #Make sure we got something from the priority queue
      raise "Expected #{msg_name.inspect} but there was no messages available" unless @cq

      #Now read the queue with the correct num of args
      arg_len = @cq.shift
      name = @cq.shift
      args = @cq.shift(arg_len)

      expect(name).to eq(msg_name)
      expect(args).to eq(msg_args)
      expect(priority).to eq(@cp)
    end

    #Retrieve a message, we at least expect a name and priority
    def get msg_name, priority=0
      #Dequeue from multi-priority queue if possible
      if @cq.nil? or @cq.count == 0
        @cq = @q.shift
        @cp = @cq.shift #save priority
      end

      #Make sure we got something from the priority queue
      raise "Expected #{msg_name.inspect} but there was no messages available" unless @cq

      #Now read the queue with the correct num of args
      arg_len = @cq.shift
      name = @cq.shift
      args = @cq.shift(arg_len)

      expect(name).to eq(msg_name)
      expect(priority).to eq(@cp)

      return args
    end

    #Send a message back to flok, will drain queue as well (run flok code)
    def int msg_name, args=nil
      if args
        msg = [args.length, msg_name, *args].to_json
      else
        msg = [0, msg_name].to_json
      end
        @ctx.eval %{
          int_dispatch(#{msg});
        }
    end
  end
end
