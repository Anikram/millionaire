require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'Anonimous users' do
    it 'kick from #show' do
      get :show, id: game_w_questions.id

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

  context 'User' do

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
  end
end
