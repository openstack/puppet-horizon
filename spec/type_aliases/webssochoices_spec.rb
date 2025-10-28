require 'spec_helper'

describe 'Horizon::WebSsoChoices' do
  describe 'valid types' do
    context 'with valid types' do
      [
        [
          ['oidc', 'OpenID Connect'],
        ],
        [
          ['oidc', 'OpenID Connect'],
          ['acme_oidc', 'ACME - OpenID Connect'],
        ],
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        [],
        ['oidc', 'OpenID Connect'],
        [
          ['oidc'],
        ],
        [
          ['oidc', 'OpenID Connect', 'foo'],
        ],
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
