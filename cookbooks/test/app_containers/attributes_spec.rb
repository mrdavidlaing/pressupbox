# test/ntp/attributes_spec.rb
require File.join(File.dirname(__FILE__), %w{.. support spec_helper})
require 'chef/node'
require 'chef/platform'

describe 'app_containers::Attributes::Default' do
  let(:attr_ns) { 'app_containers' }

  before do
    @node = Chef::Node.new
    @node.consume_external_attrs(Mash.new(ohai_data), {})
    @node.from_file(File.join(File.dirname(__FILE__), %w{.. .. app_containers attributes default.rb}))
  end

  describe "default attributes" do
    let(:ohai_data) do
      { :platform => "unknown", :platform_version => '3.14' }
    end

    it "has a default attribute" do
      @node[attr_ns]['sample_attr'].must_equal "sample"
    end
  end 
end