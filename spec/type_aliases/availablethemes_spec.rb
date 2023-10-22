require 'spec_helper'

describe 'Horizon::AvailableThemes' do
  describe 'valid types' do
    context 'with valid types' do
      [
        [
          {'name' => 'default'}
        ],
        [
          {'name' => 'default'},
          {'name' => 'custom'}
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
        ['name'],
        [{'name' => 1}],
        [{1 => 'default'}],
        [{'name' => ''}],
        [{'' => 'default'}],
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
