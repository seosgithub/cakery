![cakery: Say goodbye to file path issues](https://raw.githubusercontent.com/sotownsend/cakery/master/logo.png)

[![Gem Version](https://badge.fury.io/rb/iarrogant.svg)](http://badge.fury.io/rb/cakery)
[![Build Status](https://travis-ci.org/sotownsend/cakery.svg)](https://travis-ci.org/sotownsend/cakery)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/sotownsend/cakery/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/sotownsend/cakery/blob/master/LICENSE)

##What is this?

Combine many files into one intelligently.  Think about it as a more generic version of [Sprockets](https://github.com/sstephenson/sprockets).

## Quick Start

###Combine many js files in the `./spec` directory into one file
In your ruby code:
```ruby
#Create a new recipe
recipe = Cakery.new('test.js.erb') do |r|
  #The << operator means to glob the directory into a string in @spec
  r.spec << "./spec/*_spec.js"
  
  #The < operator means assignment
  r.debug < true
  r.foo < "bar"
end

#Build using the current directory
cake = recipe.bake

#Get the concatenated result of the build
puts cake.src
```

Create a test.js.erb with:
```erb
<%= @spec %>

<!-- Announce whether we are in debug or release -->
<% if @debug %>
  console.log("Debug!");
<% end %>
  console.log("Release :(");
<% end %>
```

------

###Macros
Macros receive a block of text and then do something with that text.  A *macro* is a subclass of **Cakery::Macro** that implements **def process(str)** and returns a **String**. You can also stack macros.

In your ruby code:
```ruby
#Create a new recipe
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

recipe = Cakery.new('test.js.erb') do |r|
  #The << operator means to glob the directory into a string in @spec
  r.spec << MyMacro << "./spec/*_spec.js"
  r.spec << MyMacro < "hello"
  
  #Additionally, you can stack macros. Macros always use the << operator intra macros
  #The last operator may either be < or <<
  r.spec << MyMacro << MyOtherMacro < "Hello"
  r.spec << MyMacro << MyOtherMacro << "./spec/*_spec.js"
  
  #The < operator means assignment
  r.debug < true
  r.foo < "bar"
end

#Build using the current directory
cake = recipe.bake

#Get the concatenated result of the build
puts cake.src
```

Create a test.js.erb with:
```erb
<%= @spec %>

<!-- Announce whether we are in debug or release -->
<% if @debug %>
  console.log("Debug!");
<% end %>
  console.log("Release :(");
<% end %>
```

## Requirements

- Modern **nix** (FreeBSD, Mac, or Linux)
- Ruby 2.1 or Higher

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

RVM users:
Run `gem install cakery`

System ruby installation:
Run `sudo gem install cakery`

---

## FAQ

### When should I use cakery?

Todo

### What's Fittr?

Fittr is a SaaS company that focuses on providing personalized workouts and health information to individuals and corporations through phenomenal interfaces and algorithmic data-collection and processing.

* * *

### Creator

- [Seo Townsend](http://github.com/sotownsend) ([@seotownsend](https://twitter.com/seotownsend))

## License

cakery is released under the MIT license. See LICENSE for details.
