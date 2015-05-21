Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require 'securerandom'

RSpec.describe "iface:kern:ping_spec" do
  include_context "iface:kern"

 it "supports ping" do
    @pipe.puts [0, "ping"].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 0, "pong"]], 6.seconds)
  end

  it "supports ping1" do
    arg = SecureRandom.hex
    @pipe.puts [1, "ping1", arg].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 1, "pong1", arg]], 6.seconds)
  end

  it "supports ping2" do
    arg1 = SecureRandom.hex
    arg2 = SecureRandom.hex
    @pipe.puts [2, "ping2", arg1, arg2].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 1, "pong2", arg1, 2, "pong2", arg1, arg2]], 6.seconds)
  end

  it "supports multi-ping" do
    @pipe.puts [0, "ping", 0, "ping"].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 0, "pong", 0, "pong"]], 6.seconds)
  end

  it "supports multi-ping1" do
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [1, "ping1", secret1, 1, "ping1", secret2].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 1, "pong1", secret1, 1, "pong1", secret2]], 6.seconds)
  end

  it "supports multi-ping2" do
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [2, "ping2", secret1, secret2, 2, "ping2", secret2, secret1].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 1, "pong2", secret1, 2, "pong2", secret1, secret2, 1, "pong2", secret2, 2, "pong2", secret2, secret1]], 6.seconds)
  end

  it "supports multi-queue" do
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [2, "ping2", secret1, secret2, 2, "ping2", secret2, secret1].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[0, 1, "pong2", secret1, 2, "pong2", secret1, secret2, 1, "pong2", secret2, 2, "pong2", secret2, secret1]], 6.seconds)
 end

  it "supports ping3" do
    queue_name_to_index = {
      
    }
    
    queue_name_to_index.each do |name, index|
      @pipe.puts [1, "ping3", name].to_json
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, 0, "pong3"]], 6.seconds)
    end
  end

  queue_name_to_index = {
      "main" => 0,
      "net" => 1,
      "disk" => 2,
      "cpu" => 3,
      "gpu" => 4
  }

 queue_name_to_index.each do |name, index|
    it "supports ping3-multi" do
      #Don't redo last one because it's part of the first term (queue_name_b)
      unless index == queue_name_to_index.count-1
        queue_name_a = name
        queue_name_b = @last_queue_name || "gpu"
        index_a = index
        index_b = queue_name_to_index[queue_name_b]
        @pipe.puts [1, "ping3", queue_name_a, 1, "ping3", queue_name_a, 1, "ping3", queue_name_b].to_json
        expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index_a, 0, "pong3", 0, "pong3"], [index_b, 0, "pong3"]].sort_by{|e| e[0]}, 6.seconds)
        @last_queue_name = queue_name_a
      end
    end
  end

  #Double up, make sure multiple request are queued appropriately
  queue_name_to_index.each do |name, index|
    it "supports ping3-double" do
      queue_name = name
      @pipe.puts [1, "ping3", queue_name].to_json
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, 0, "pong3"]], 6.seconds)

      @pipe.puts [1, "ping3", queue_name].to_json
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, 0, "pong3"]], 6.seconds)
    end
  end

  #Now make sure the max_n queuing works correctly
  queue_name_to_index.each do |name, index|
    it "supports ping-over-commit" do
      #Main queue always queues all
      if name != "main" 
        @pipe.puts ([1, "ping4", name]*6).to_json
        expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, *[0, "pong4"]*5]], 6.seconds)
        @pipe.puts ([1, "ping4", name]).to_json

        #Semantics aren't exact, but it should be nothing happens after 2 seconds (no response)
        expect(@pipe).not_to readline_and_equal_json_x_within_y_seconds([], 1.seconds)

        @pipe.puts ([1, "ping4_int", name]).to_json
        expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, 0, "pong4"]], 6.seconds)
      else
        @pipe.puts ([1, "ping4", name]*6).to_json
        expect(@pipe).to readline_and_equal_json_x_within_y_seconds([[index, *[0, "pong4"]*6]], 6.seconds)
      end
    end
  end
end
