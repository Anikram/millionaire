require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) {FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3)}


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
        q = FactoryBot.create(:game_question, a: hash['a'], b: hash['b'], c: hash['c'], d: hash['d'],)
        #puts hash
        hash_key = hash.select {|key, value| value == '1' ? key : nil}

        expect(q.correct_answer_key == hash_key.keys[0]).to be_truthy
      end
    end
  end

  describe 'user helpers' do
    it 'should be correct audience_help' do
      expect(game_question.help_hash).not_to include(:audience_help)

      game_question.add_audience_help

      expect(game_question.help_hash).to include(:audience_help)
      expect(game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
    end
  end

  describe '.help_hash' do
    context 'when game is started' do
      it 'game_question should have empty hash' do
        expect(game_question.help_hash).to eq({})
      end

      it 'should write data in #help_hash' do
        game_question.help_hash[:key1] = 'value1'
        game_question.help_hash[:key2] = 'value2'

        expect(game_question.save).to be_truthy
      end

      it 'should store data in #help_hash' do
        game_question.help_hash[:key1] = 'value1'
        game_question.help_hash[:key2] = 'value2'

        game_question.save

        game_quest = GameQuestion.find(game_question.id)
        expect(game_quest.help_hash).to eq({key1: 'value1', key2: 'value2'})
      end
    end
  end

  describe '#use_help' do
    let(:user) {FactoryBot.create :user}
    let(:game_w_questions) {FactoryBot.create :game_with_questions, user: user}
    context 'when fifty_fifty help is used' do
      it 'game should be in progress' do
        game_w_questions.use_help(:fifty_fifty)
        expect(game_w_questions.status).to be :in_progress
        expect(game_w_questions.current_game_question.help_hash).to include(:fifty_fifty)
      end
      it 'game.fifty_fifty_used eq true' do
        game_w_questions.use_help(:fifty_fifty)
        expect(game_w_questions.fifty_fifty_user).to be_truthy
      end
    end


    context 'when audience help is used' do
      it 'game should be in progress' do
        game_w_questions.use_help(:audience_help)
        expect(game_w_questions.status).to be :in_progress
        expect(game_w_questions.current_game_question.help_hash).to include(:audience_help)
      end
      it 'game.audience_help_used eq true' do
        game_w_questions.use_help(:audience_help)
        expect(game_w_questions.audience_help_used).to be_truthy
      end
    end

    context 'when friend_call help is used' do
      it 'game should be in progress' do
        game_w_questions.use_help(:friend_call)
        expect(game_w_questions.status).to be :in_progress
        expect(game_w_questions.current_game_question.help_hash).to include(:friend_call)
      end
      it 'game.friend_call_used show expected answer' do
        allow(GameHelpGenerator).to receive(:friend_call) {"Патрон сказа что ответ - Herbie Hankok - Cantalupo Island"}
        game_w_questions.use_help(:friend_call)
        expect(game_w_questions.current_game_question.help_hash[:friend_call]).to eq("Патрон сказа что ответ - Herbie Hankok - Cantalupo Island")
      end
    end

    context 'when all helps are used & answer wrong' do
      it 'game should be fail' do
        expect(game_w_questions.current_level).to be 0
        game_w_questions.use_help(:audience_help)
        expect(game_w_questions.audience_help_used).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:audience_help)
        game_w_questions.use_help(:fifty_fifty)
        expect(game_w_questions.fifty_fifty_user).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:fifty_fifty)
        game_w_questions.use_help(:friend_call)
        expect(game_w_questions.friend_call_used).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:friend_call)

        game_w_questions.answer_current_question!('a')

        expect(game_w_questions.status).to be :fail
      end
    end
    context 'when all helps are used & answer right' do
      it 'game should be in_progress' do
        expect(game_w_questions.current_level).to be 0
        game_w_questions.use_help(:audience_help)
        expect(game_w_questions.audience_help_used).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:audience_help)
        game_w_questions.use_help(:fifty_fifty)
        expect(game_w_questions.fifty_fifty_user).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:fifty_fifty)
        game_w_questions.use_help(:friend_call)
        expect(game_w_questions.friend_call_used).to be_truthy
        expect(game_w_questions.current_game_question.help_hash).to include(:friend_call)

        game_w_questions.answer_current_question!('d')

        expect(game_w_questions.status).to be :in_progress
      end
    end
  end
end

