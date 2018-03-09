FactoryGirl.define do
  factory :empty_right, class: Arkaan::Permissions::Right do
    factory :right do
      _id 'right_id'
      slug 'test_right'
    end
  end
end