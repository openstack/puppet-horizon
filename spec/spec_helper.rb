require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'

require 'puppet-openstack_spec_helper/defaults'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
  # TODO(aschultz): remove this after all tests converted to use OSDefaults
  # instead of referencing @default_facts
  c.before :each do
    @default_facts = OSDefaults.get_facts
  end
end

def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  expect(content.split("\n") & expected_lines).to eq(expected_lines)
end

at_exit { RSpec::Puppet::Coverage.report! }
