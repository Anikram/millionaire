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

  describe 'game mechanics' do
    it 'game should continue if answer correct' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.previous_game_question).to eq q
      expect(game_w_questions.current_game_question).not_to eq q

      expect(game_w_questions.status).to eq :in_progress
      expect(game_w_questions.finished?).to be_falsey
    end

    describe '#take_money!' do
      it ' ::PRIZES should include the game.prize result at any round' do
        n = 1
        while n < 16 do
          game_w_questions = FactoryBot.create(:game_with_questions, user: user)

          n.times do
            game_w_questions.answer_current_question!('d')
          end

          game_w_questions.take_money!
          expect(game_w_questions.status).not_to eq :finished
          expect(game_w_questions.prize).to eq(Game::PRIZES[game_w_questions.previous_level])
          n += 1
        end
      end

      it ' should return true while game#status == :in_progress' do
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.take_money!).to be_truthy
      end

      it ' should increase user#balance after every game' do
        n = 1
        while n < 16 do
          user = FactoryBot.create(:user)
          expect(user.balance).to eq(0)
          stored_balance = user.balance
          game_w_questions = FactoryBot.create(:game_with_questions, user: user)

          n.times do
            game_w_questions.answer_current_question!('d')
          end

          game_w_questions.take_money!
          expect(game_w_questions.status).not_to eq :finished
          expect(game_w_questions.prize).to eq(Game::PRIZES[game_w_questions.previous_level])
          expect(user.balance - stored_balance).to eq(user.balance)
          n += 1
        end
      end
    end

    describe '#status' do
      it 'should return :in_progress' do
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.finished?).to be false
      end

      it 'should return :won' do
        15.times do
          game_w_questions.answer_current_question!('d')
        end

        expect(game_w_questions.current_level).to eq(15)
        expect(game_w_questions.status).to eq(:won)
        expect(game_w_questions.finished?).to be true
      end

      context 'when #take_money!' do
        it 'should return :money' do
          game_w_questions.take_money!
          expect(game_w_questions.status).to eq(:money)
        end

        it 'should return amount of money' do
          game = FactoryBot.create :game_with_questions, current_level: 3

          game.take_money!

          expect(game.current_level).to eq 3
          expect(game.prize).to eq 300
          expect(game_w_questions.finished?).to be false
        end
      end
    end

    describe '#current_game_question' do
      context 'when game is created' do
        it 'should return GameQuestion instance' do
          expect(game_w_questions.current_game_question).to be_a(GameQuestion)
          game_w_questions.answer_current_question!('d')
          expect(game_w_questions.current_level).to eq(1)
          expect(game_w_questions.finished?).to be false
        end
      end
    end

    describe '#previous_level' do
      it 'should be previous_level less then current_level by 1' do
        game = FactoryBot.create(:game_with_questions, user: user)
        15.times do
          prev_level = game.current_level
          game.answer_current_question!('d')
          expect(game.current_level - prev_level).to eq(1)
          expect(game_w_questions.finished?).to be false
        end
      end
    end


    describe '#answer_current_question!' do #d - is always correct answer for GameQuestion (game_questions factory)
      context 'when game is finished' do
        it 'should return false' do
          15.times do
            game_w_questions.answer_current_question!('d')
          end
          expect(game_w_questions.answer_current_question!('d')).to be_falsey
          expect(game_w_questions.status).to eq :won
          expect(game_w_questions.finished?).to be true
        end
      end

      context 'when time is expired' do
        it 'should finish the game' do
          game = FactoryBot.create :game_with_questions, created_at: Time.now - 36.minutes, finished_at: Time.now
          expect(game.finished?).to eq true
          expect(game.answer_current_question!('d')).to be_falsey
          expect(game.status).to eq :timeout
        end
      end

      context 'when answer is correct' do
        it 'should return true' do
          expect(game_w_questions.answer_current_question!('d')).to be_truthy
          expect(game_w_questions.status).not_to eq :finished
          expect(game_w_questions.finished?).to be false
        end
      end

      context 'when answer is incorrect' do
        it 'should return false and game#status = :fail' do
          expect(game_w_questions.answer_current_question!('a')).to be_falsey
          expect(game_w_questions.status).to eq(:fail)
          expect(game_w_questions.finished?).to be true
        end
      end
    end
  end
end
