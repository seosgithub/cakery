require 'timeout'
require 'rspec/expectations'
require 'active_support'
require 'active_support/core_ext/numeric'

#Useful RSpec helpers

#Make sure that a PROCESS at some PID is no longer active within N seconds
RSpec::Matchers.define :die_within do |seconds|
  match do |pid|
    begin
      Timeout::timeout(seconds) { Process.waitpid(pid) }
    rescue Timeout::Error
      return false
    rescue Errno::ECHILD
      #Process no longer exists (waitpid)
    end

    return true
  end

  description do
    "die within #{seconds.inspect}"
  end
end

#Attempt to readline from IO, it should throw an EOF within N seconds
RSpec::Matchers.define :raise_eof_from_readline_within do |seconds|
  match do |pipe|
    begin
      Timeout::timeout(seconds) do
        pipe.readline
      end
    rescue Timeout::Error
      return false
    rescue Errno::ECHILD
      #Process no longer exists (waitpid)
    rescue EOFError
      return true
    end

    return false
  end

  match_when_negated do |pipe|
    begin
      Timeout::timeout(seconds) do
        pipe.readline
      end
    rescue Timeout::Error
      return true
    rescue Errno::ECHILD
      #Process no longer exists (waitpid)
    rescue EOFError
      return false
    end

    return true
  end

  description do
    "raise EOF within #{seconds.inspect}"
  end
end

#Attempt to readline from IO, it should return an STR within SECONDS
RSpec::Matchers.define :readline_and_equal_x_within_y_seconds do |str, seconds|
  match do |pipe|
    begin
      Timeout::timeout(seconds) do
        @res = pipe.readline.strip
        return true if @res == str
      end
    rescue Timeout::Error #Time out
    rescue EOFError #Couldn't read pipe
    end

    return false
  end

  failure_message do |actual|
    if @res
      "expected that #{@res.inspect} to equal #{str.inspect}"
    else
      "expected to get back #{str.inspect}, but I didn't get anything!"
    end
  end

  description do
    "readline and equal #{str.inspect} within #{seconds.inspect}"
  end
end

#Attempt to readline from IO, it should return an JSON object within SECONDS
RSpec::Matchers.define :readline_and_equal_json_x_within_y_seconds do |json, seconds|
  match do |pipe|
    begin
      Timeout::timeout(seconds) do
        @res = JSON.parse(pipe.readline.strip)
        return true if @res == json
      end
    rescue Timeout::Error #Time out
    rescue EOFError #Couldn't read pipe
    end

    return false
  end

  failure_message do |actual|
    "expected that the decoded JSON of #{@res.inspect} to equal #{json.inspect}"
  end

  description do
    "readline and equal #{json.inspect} within #{seconds.inspect}"
  end
end

#Attempt to readline from IO, it should return something that a custom validate_proc returns true within SECONDS
RSpec::Matchers.define :readline_and_equal_proc_x_within_y_seconds do |validate_proc, seconds|
  match do |pipe|
    begin
      Timeout::timeout(seconds) do
        @res = pipe.readline.strip
        begin
          @sol = validate_proc.call(@res)
        rescue Exception => e
          @partial_exception = e
        end

        return @sol
      end
    rescue Timeout::Error #Time out
      @timeout = true
    rescue EOFError #Couldn't read pipe
      @eof = true
      $stderr.puts "eof"
    end

    return false
  end

  failure_message do |actual|
    if @timeout
      "expected a readline, but none was returned from the pipe within #{seconds.inspect}"
    elsif @eof
      "expected a readline, but an eof was thrown from the pipe"
    else
      "expected that the value of #{@res.inspect} to return true via your custom proc #{validate_proc}, got back #{@sol}, with an exception of #{@partial_exception}"
    end
  end

  description do
    "readline and match a custom_proc within #{seconds.inspect}"
  end
end

#Fuzzy check an array to make sure it matches some qualifiers
  #Each array element in the matcher has a particular meanning depending on the class
  #For example, the matcher expect(["hello", "world", "!"]).to look_like(["hello", /wor/, ->(e){ e.class == String }])
  #Lets break down that selector
    #"hello" - Everything that isn't covered under a case is matched via ===, "hello"==="hello", and "hello"===String
    #/wor/   - Regex match, must contain at least 'wor'
    #->(e){e.class == String} - Stabby lambda, must match your lambda
  #Tips
    #Put your procs in their own variables before the expect; we can get the source easier that way
      #a = ->(e){e.class == String}
      #expect(["hello"]).to look_like([a])
RSpec::Matchers.define :look_like do |qual|
  match do |arr|
    #Qualifier array must be the same length as input array
    if arr.length != qual.length
      @bad_arr_len = true
      return false
    end

    @reasons = {}
    qual.each_with_index do |e, i|
      case e
      when Regexp
        begin
          next if e =~ arr[i]
        rescue TypeError
        end

        @reasons[i] = "#{arr[i].inspect} does not match #{e.inspect}"
      when Proc
        next if e.call(arr[i]) == true

        #Try to dump proc source, source_location returns [path, line]
        proc_code = nil
        File.read(e.source_location[0]).split("\n").each_with_index do |l, i|
          next if i+1 != e.source_location[1] #Not our line
          proc_code = l
          break if i+1 == e.source_location[1]
        end

        @reasons[i] = "#{arr[i].inspect} did not pass proc '#{proc_code.strip}'"
      else
        next if e === arr[i]
        @reasons[i] = "should be equivalent to #{e.inspect}"
      end
    end

    #Only contains truth
    return @reasons.count == 0
  end

  failure_message do |arr|
    #Bad length of array
    next "The input array #{arr.inspect} should have #{qual.length} things" if @bad_arr_len

    ss = StringIO.new
    arr.each_with_index do |e, i|
      ss.puts "#{i}: #{e}" unless @reasons[i]
      ss.puts "#{i}: #{e} <---- [#{@reasons[i]}]" if @reasons[i]
    end
    next ss.string
  end
end
