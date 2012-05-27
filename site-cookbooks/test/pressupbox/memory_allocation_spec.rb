require File.join(File.dirname(__FILE__), %w{.. support spec_helper})
require 'chef/node'
require 'chef/platform'

require File.join(File.dirname(__FILE__), %w{.. .. pressupbox libraries memory_allocation})
include MemoryAllocation

describe 'pressupbox::Libraries::MemoryAllocation' do

  before do
    @node = Chef::Node.new
    @node.consume_external_attrs(Mash.new(ohai_data), { :platform => "unknown", :platform_version => '0.1' })
    @node.from_file(File.join(File.dirname(__FILE__), %w{.. .. pressupbox attributes default.rb}))
  end

  describe "default attributes" do
    let(:ohai_data) do
      { :memory => { :total => "2051540kB"} }
    end

    it "can calculate total memory in MBs" do
      get_available_memory(@node).must_equal 2003.45703125
    end
  end 
end