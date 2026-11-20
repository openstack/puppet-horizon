require 'spec_helper'

describe 'Horizon::WebSsoIdpMapping' do
  describe 'valid types' do
    context 'with valid types' do
      [
        {},
        {
          "acme_oidc"  => ["acme", "oidc"],
          "acme_saml2" => ["acme", "saml2"],
        },
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
        {
          ""  => ["acme", "oidc"],
        },
        {
          "acme_oidc"  => ["", "oidc"],
        },
        {
          "acme_oidc"  => ["acme", ""],
        },
        {
          "acme_oidc"  => ["acme"],
        },
        {
          "acme_oidc"  => ["acme", "oidc", "foo"],
        },
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
