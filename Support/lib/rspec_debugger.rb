require File.dirname(__FILE__) + "/ruby_amp.rb"

def check_bundle_path!(bundle_path)
  bundle_name = bundle_path.to_s.gsub('_bundle_path','').gsub('_','-')
  if RubyAMP::Config[bundle_path].nil?
    puts "Can't find #{bundle_name}.tmbundle.  Use 'Edit RubyAMP Global Config' to set the path to where it's installed"
  end
end

def start_debugger_with_wrapper(wrapper_code)
  Dir.chdir(ENV['TM_PROJECT_DIRECTORY'])
  wrapper_file = RubyAMP::RemoteDebugger.prepare_debug_wrapper wrapper_code
  RubyAMP::Launcher.open_controller_terminal

  ARGV << "-s"
  ARGV << wrapper_file

  require 'rubygems'
  require 'ruby-debug'
  load 'rdebug'
end

def debug_rspec_story
  check_bundle_path! :rspec_story_bundle_path
  start_debugger_with_wrapper(<<-RUBY)
    ENV['TM_BUNDLE_SUPPORT'] = RubyAMP::Config[:rspec_story_bundle_path] + "/Support"
    
    require "#{RubyAMP::Config[:rspec_story_bundle_path]}/Support/lib/spec/mate/story/story_helper"
    
    Debugger.wait_for_connection
    Spec::Mate::Story::StoryHelper.new(ENV['TM_FILEPATH']).run_story
    Runner.story_runner.run_stories
  RUBY
end

def debug_rspec(focussed_or_file = :file)
  raise ArgumentError unless %w[focussed file].include?(focussed_or_file.to_s)
  check_bundle_path! :rspec_bundle_path
  start_debugger_with_wrapper(<<-RUBY)
    ENV['TM_BUNDLE_SUPPORT'] = RubyAMP::Config[:rspec_bundle_path] + "/Support"
    require '#{RubyAMP::Config[:rspec_bundle_path]}/Support/lib/spec/mate'
    Debugger.wait_for_connection
    Spec::Mate::Runner.new.run_#{focussed_or_file} STDOUT
  RUBY
end
