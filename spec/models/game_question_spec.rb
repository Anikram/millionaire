require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  context 'game status' do
    it 'correct .variants' do
      expect(game_question.variants).to eq(
                                          {
                                            'a' => game_question.question.answer2,
                                            'b' => game_question.question.answer1,
                                            'c' => game_question.question.answer4,
                                            'd' => game_question.question.answer3
                                          })
    end

    it 'correct .answer_correct?' do
      expect(game_question.answer_correct?('b')).to be_truthy
    end

    it 'method .text returns a unique String' do
      game_w_questions = FactoryBot.create(:game_with_questions)
      texts_box = []
      game_w_questions.game_questions.each do |game_question|
        expect(game_question.text).to be_a(String)
        expect(texts_box.include?(game_question.text)).to be_falsey
        texts_box << game_question.text
      end
    end

    it 'method .level returns a unique Integer' do
      game_w_questions = FactoryBot.create(:game_with_questions)
      levels_box = []
      game_w_questions.game_questions.each do |game_question|
        expect(game_question.level).to be_a(Integer)
        expect(levels_box.include?(game_question.level)).to be_falsey
        levels_box << game_question.level
      end
    end
  end

  context 'game_question.correct_answer_key' do
    it 'should return value - eq to iterator' do
       100.times do
          keys = %w(a b c d).shuffle!
          values = %w(1 2 3 4).shuffle!
          hash = Hash[keys.zip values]
          q = FactoryBot.create(:game_question, a: hash['a'], b: hash['b'], c: hash['c'],d: hash['d'], )
          #puts hash
          hash_key = hash.select { |key, value| value == '1' ? key : nil }

          expect(q.correct_answer_key == hash_key.keys[0]).to be_truthy
       end
    end
  end
end
