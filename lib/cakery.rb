require 'cakery/macro'
require 'erb'

module Cakery
  class Cakery
    attr_accessor :src

    #Create a new cakery (recipe) with an erb file
    def initialize erb_path, &block
      raise "You gave cakery the file: #{erb_path.inspect} but this wasn't a file" unless File.file?(erb_path)

      #Create a new erb compiler
      @erb_src = File.read(erb_path)
      @erbc = ERB.new(@erb_src)

      @block = block
    end

    def bake
      ctx = CakeryERBContext.new
      @block.call(ctx)
      @src = @erbc.result(ctx.get_binding)
    end
  end

  class CakeryERBContext
    def initialize
    end

    def method_missing name, *args, &block
      if name =~ /=/
        name = ('@'+name.to_s.gsub(/=/, "")).to_sym
        self.instance_variable_set(name, args.first)
      else
        return CakeERBContextTwoClauseHelper.new(self, name)
      end
    end

    def get_binding
      return binding
    end
  end

  #Allow things like r.my_secret << './secret, this handles the '<<' part and
  #is given 'my_secret' as a name
  class CakeERBContextTwoClauseHelper
    def initialize erb_context, name
      @erb_context = erb_context
      @name = name
      @macros = []
    end

    def <<(e)
      vname = ('@'+@name.to_s.gsub(/=/, "")).to_sym
      out = ""

      #Append all files or it's a macro class
      if e.class == String
        fpaths = Dir[e].select{|e| File.file?(e)}
        fpaths.each do |fpath|
          out << File.read(fpath)
        end

        #Run through each macro and run it in the reverse
        #order that we put it in so that
        #r.var << MyMacroA << MyMacroB << "./directory" will execute first MyMacroB and then MyMacroA
        while macro = @macros.pop
          out = macro.new.process(out)
        end

        @erb_context.instance_variable_set(vname, "") unless @erb_context.instance_variable_defined?(vname)
        v = @erb_context.instance_variable_get(vname)
        v += out
        @erb_context.instance_variable_set(vname, v)

      else
        #Assume it's a macro, save it onto the stack
        @macros << e

        #Return self, recurse because there should be a string (or another macro)
        #to the right of this one
        return self
      end
    end
  end

  def self.new *params, &block
    return Cakery.new(*params, &block)
  end
end
