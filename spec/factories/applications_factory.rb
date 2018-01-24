FactoryGirl.define do
  factory :empty_application, class: Arkaan::OAuth::Application do
    factory :application do
      name 'Other app'
      key 'test_key'
      premium false
    end
  end
end