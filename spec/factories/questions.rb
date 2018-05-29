FactoryBot.define do
  factory :question do
    answer1 {"#{rand(2018)}"}
    answer2 {"#{rand(2018)}"}
    answer3 {"#{rand(2018)}"}
    answer4 {"#{rand(2018)}"}

    sequence(:text) {|n| "В каком году была олимпиада #{n} года?" }

    sequence(:level) { |n| n % 15 }
  end
end