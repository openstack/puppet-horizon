require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'
require 'puppet-openstack_spec_helper/facts'

fixture_path = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'

  c.module_path = File.join(fixture_path, 'modules')
end

def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expected_lines.each do |expected_line|
    expect([expected_line] & content.split("\n")).to eq([expected_line])
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
