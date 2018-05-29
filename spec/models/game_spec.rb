require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) {FactoryBot.create(:user)}

  let(:game_w_questions) {FactoryBot.create(:game_with_questions, user: user)}


  context 'Game Factory' do
    it 'Game.create_game_for_user! new correct game' do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15)
      )

      expect(game.user).to eq user
      expect(game.status).to eq :in_progress
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
      expect(game.game_questions.size).to eq 15
    end
  end

  context 'game mechanics' do
    it 'answer correct continue' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.previous_game_question).to eq q
      expect(game_w_questions.current_game_question).not_to eq q

      expect(game_w_questions.status).to eq :in_progress
      expect(game_w_questions.finished?).to be_falsey
    end

    context 'method .take_money!' do
      it ' ::PRIZES should include the game.prize result at any round' do
        n = 1
        while n < 16 do
          game_w_questions = FactoryBot.create(:game_with_questions, user: user)

          n.times do
            game_w_questions.answer_current_question!(game_w_questions.current_game_question.correct_answer_key)
          end

          game_w_questions.take_money!
          expect(game_w_questions.prize).to eq(Game::PRIZES[game_w_questions.previous_level])
          n += 1
        end
      end

      it ' should return true while game.status == :in_progress' do
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.take_money!).to be_truthy
      end

      it ' should increase user.balance after every game' do
        n = 1
        while n < 16 do
          user = FactoryBot.create(:user)
          expect(user.balance).to eq(0)
          stored_balance = user.balance
          game_w_questions = FactoryBot.create(:game_with_questions, user: user)

          n.times do
            game_w_questions.answer_current_question!(game_w_questions.current_game_question.correct_answer_key)
          end

          game_w_questions.take_money!
          expect(game_w_questions.prize).to eq(Game::PRIZES[game_w_questions.previous_level])
          expect(user.balance - stored_balance).to eq(user.balance)
          n += 1
        end
      end
    end
  end

  context 'method .status' do
    it 'should return :in_progress' do
      expect(game_w_questions.status).to eq(:in_progress)
    end

    it 'should return :won' do
      if game_w_questions.current_level > Question::QUESTION_LEVELS.max
        expect(game_w_questions.status).to eq(:won)
      end
    end

    it 'should return :money' do
      game_w_questions.take_money!
      expect(game_w_questions.status).to eq(:money)
    end
  end
end
