FactoryBot.define do
  factory :game do
    association :user

    finished_at nil
    current_level 0
    is_failed false
    prize 0
    created_at 0

    factory :game_with_questions do
      after(:build) { |game|
        15.times do |i|
          q = create(:question, level: i, text: ('a'..'z').to_a.shuffle[0,8].join ) # https://stackoverflow.com/questions/88311/how-to-generate-a-random-string-in-ruby
          create(:game_question, game: game, question: q)
        end
      }
    end
  end
end