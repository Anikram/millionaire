require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }
  let(:game_w_questions2) { FactoryBot.create(:game_with_questions, user: user2) }

  context 'Anonimous users' do
    it 'should kick out from #show' do
      get :show, id: game_w_questions.id

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'should kick out from #answer' do
      put :answer, id: game_w_questions.id
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'should kick out from #take_money' do
      put :take_money, id: game_w_questions.id
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'should kick out from #create' do
      post :create
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  describe 'User' do

    before(:each) do
      sign_in user
    end

    it 'creates game' do
      generate_questions(60)

      post :create

      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response).to redirect_to game_path(game)
      expect(flash[:notice]).to be
    end

    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)
      expect(response.status).to eq 200

      expect(response).to render_template('show')
    end

    it 'answered correctly' do
      put :answer, id: game_w_questions.id, letter: 'd'

      game = assigns(:game)

      expect(game.finished?)
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy
    end

    context 'when User #show other User\'s game' do
      it 'should grant access to #show' do
        get :show, id: game_w_questions.id
        expect(response.status).to eq 200
        expect(flash[:alert]).not_to be
      end
      it 'should kick out from #show' do
        get :show, id: game_w_questions2.id
        expect(response.status).not_to eq 200
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end

    context 'when User takes money right away' do
      it 'should end the game and redirect to user profile' do
        put :take_money, id: game_w_questions.id

        expect(response).to redirect_to user_path(user)
        expect(flash[:warning]).to be
      end
    end

    context 'when User start another game, while prev in_progress' do
      it 'should redirect to game in_progress' do
        expect(game_w_questions.finished?).to eq false

        expect { post :create }.to change(Game, :count).by(0)

        game = assigns(:game)

        expect(game).to be_nil

        expect(response).to redirect_to(game_path(game_w_questions))
        expect(flash[:alert]).to be
      end
    end

    context 'when User answers incorrectly' do
      it 'should end the game, flash and redirect to profile' do
        game_w_questions.answer_current_question!('a')

        put :answer, id: game_w_questions.id

        expect(flash[:alert]).to be
        expect(game_w_questions.status).to eq :fail
        expect(response).to redirect_to(user_path(game_w_questions.user))
      end
    end

    context 'when game is in_progress' do
      it 'uses audience help' do
        expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
        expect(game_w_questions.audience_help_used).to be_falsey

        put :help, id: game_w_questions.id, help_type: :audience_help
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.audience_help_used).to be_truthy
        expect(game.current_game_question.help_hash[:audience_help]).to be
        expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
        expect(response).to redirect_to(game_path(game))
      end

      it 'uses fifty_fifty help' do
        expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
        expect(game_w_questions.fifty_fifty_user).to be_falsey

        put :help, id: game_w_questions.id, help_type: :fifty_fifty
        game = assigns(:game)

        expect(game.status).to eq :in_progress
        expect(game.fifty_fifty_user).to be_truthy

        expect(game.current_game_question.help_hash[:fifty_fifty]).to be

        expect(response).to redirect_to(game_path(game))
      end
    end
  end
end
