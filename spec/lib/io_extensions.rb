require 'timeout'

#Readline and timeout if nothing received
class IO
  def readline_timeout timeout=10
    Timeout::timeout(timeout) do
      return self.readline
    end

  rescue
    raise "readline did not return within the allocated time"
  end
end
