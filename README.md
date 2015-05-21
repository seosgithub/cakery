![cakery: Say goodbye to file path issues](https://raw.githubusercontent.com/sotownsend/cakery/master/logo.png)

[![Gem Version](https://badge.fury.io/rb/iarrogant.svg)](http://badge.fury.io/rb/cakery)
[![Build Status](https://travis-ci.org/sotownsend/cakery.svg)](https://travis-ci.org/sotownsend/cakery)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/sotownsend/cakery/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/sotownsend/cakery/blob/master/LICENSE)

# What is this?

cakery helps you with file path issues; never worry again about relative paths with cakery's helper methods.
Purpose built for our continuous integration & deployment infrastructure at Fittr®.

## File, pwd, and project relative
There are 3 relative ways of looking at a path in *cakery*.
  * File Relative - A path relative to the current code file
  * pwd Relative - A path relative to the current `pwd` pointer
  * project Relative - A path relative to a project root (think rails)

## Usage
cakery's path helpers work by re-opening the string class to include a set of helper methods. Various
other methods are put into the global object space.

## String Extension Methods
  * `fr` (File relative) - Returns an absolute path from the relative string given assuming the current file is the origin.
  * `pr(file)` (Project relative) - Returns an absolute path from the relative string given assuming the first ancestor folder containing `file` is the origin

## 

### Examples
```ruby
#Open a file in the same directory as the first anscestor containing a .git file

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
