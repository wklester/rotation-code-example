FactoryGirl.define do
  factory :user do
    first_name            "A."
    last_name             "User"
    sequence(:user_name)  { |n| "user#{n}" }
    sequence(:email)      { |n| "user#{n}@example.com" }
    password              "foobar"
    #incase we pass in custom password
    password_confirmation { |u| u.password }
  end

  factory :volunteer do
    sequence(:first_name)  { |n| "fname#{n}" }
    sequence(:last_name)   { |n| "lname#{n}" }
    sequence(:email)       { |n| "volunteer#{n}@example.com" }

  end

  factory :group do
    sequence(:name)   { |n| "Group #{n}" } 
    sequence(:email)  { |n| "group#{n}@example.com" }

    factory :group_with_scheduled_volunteer_sunday do
      after(:create) do |group|
        vol = FactoryGirl.create(:volunteer)
        group.volunteers << vol 
        (year, month, day) = DateHelp.get_next_sunday
        Schedule.for_service_by_id(vol.id, group.id, year, month, day)
      end
    end
    factory :group_with_scheduled_volunteer_next_sunday do
      after(:create) do |group|
        vol = FactoryGirl.create(:volunteer)
        group.volunteers << vol 
        year, month, day = DateHelp.next_week(*DateHelp.get_next_sunday)
        Schedule.for_service_by_id(vol.id, group.id, year, month, day)
      end
    end

    factory :group_with_scheduled_for do 
      ignore do
        year '2000'
        month '01' 
        day   '02'
      end
      after(:create) do |group, evaluator|
        vol = FactoryGirl.create(:volunteer)
        group.volunteers << vol 
        Schedule.for_service_by_id(vol.id, group.id, evaluator.year, evaluator.month, evaluator.day)
      end
    end

  end

end
