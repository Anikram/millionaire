require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) {FactoryBot.create(:user)}
  let(:user2) {FactoryBot.create(:user)}
  let(:admin) {FactoryBot.create(:user, is_admin: true)}
  let(:game_w_questions) {FactoryBot.create(:game_with_questions, user: user)}
  let(:game_w_questions2) {FactoryBot.create(:game_with_questions, user: user2)}

  describe 'Anonimous users' do
    context 'when try to #show the game' do

      before(:each) {get :show, id: game_w_questions.id}

      it '200ok will not be returned' do
        expect(response.status).not_to eq 200
      end
      it 'will redirected to login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'will show flashing alert' do
        expect(flash[:alert]).to eq "Вам необходимо войти в систему или зарегистрироваться."
      end
    end

    context 'when try #answer the game question' do

      before(:each) {put :answer, id: game_w_questions.id}

      it '200ok will not be returned' do
        expect(response.status).not_to eq 200
      end
      it 'will redirected to login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'will show flashing alert' do
        expect(flash[:alert]).to eq "Вам необходимо войти в систему или зарегистрироваться."
      end
    end

    context 'when trying access to game#take_money' do

      before(:each) {put :take_money, id: game_w_questions.id}

      it '200ok will not be returned' do
        expect(response.status).not_to eq 200
      end
      it 'will redirected to login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'will show flashing alert' do
        expect(flash[:alert]).to eq "Вам необходимо войти в систему или зарегистрироваться."
      end
    end

    context 'when trying to  #create the game' do

      before(:each) {post :create}
      it '200ok will not be returned' do
        expect(response.status).not_to eq 200
      end
      it 'will redirected to login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'will show flashing alert' do
        expect(flash[:alert]).to eq "Вам необходимо войти в систему или зарегистрироваться."
      end
    end

    context 'when trying to use #help ' do
      before(:each) {post :create}
      it '200ok will not be returned' do
        expect(response.status).not_to eq 200
      end
      it 'will redirected to login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
      it 'will show flashing alert' do
        expect(flash[:alert]).to eq "Вам необходимо войти в систему или зарегистрироваться."
      end
    end
  end

  describe 'User' do

    before(:each) {sign_in user}

    context 'when creates game' do
      before(:each) do
        post :create
      end

      it 'redirects to a game_path url' do
        game = assigns(:game)
        expect(response).to redirect_to game_path(game)
      end

      it 'flashes a notice' do
        expect(flash[:notice]).to eq "Игра началась в #{Time.now}, время пошло"
      end
    end

    context 'when trying to watch(game#show) game' do
      before(:each) {get :show, id: game_w_questions.id}

      it 'returns HTTP 200 ok' do
        expect(response.status).to eq(200)
      end
      it 'renders template show' do
        expect(response).to render_template('show')
      end
    end

    context 'answered correctly' do
      before(:each) do
        put :answer, id: game_w_questions.id, letter: 'd'
      end

      it 'redirects to game_path' do
        game = assigns(:game)
        expect(response).to redirect_to(game_path(game))
      end
      it 'flashes no messages' do
        expect(flash.empty?).to be_truthy
      end
    end

    context 'when User #show other User\'s game' do
      before(:each) {get :show, id: game_w_questions2.id}

      it 'NOT return HTTP 200 ok' do
        expect(response.status).not_to eq 200
      end
      it 'redirects to root_path' do
        expect(response).to redirect_to(root_path)
      end
      it 'flashes an alert message' do
        expect(flash[:alert]).to eq "Это не ваша игра!"
      end
    end

    context 'when User takes money right away' do
      before(:each) {put :take_money, id: game_w_questions.id}

      it 'redirect to user profile' do
        expect(response).to redirect_to user_path(user)
      end
      it 'flashes the warning' do
        expect(flash[:warning]).to eq "Игра окончена, ваш выигрыш 0 ₽. Заходите еще!"
      end
    end

    context 'when User start another game, while prev in_progress' do
      before(:each) do
        expect(game_w_questions.finished?).to eq false #invoke game_w_questions1
        post :create
      end
      it 'doesnt start another game' do
        expect {post :create}.to change(Game, :count).by(0)
      end

      it ' redirects to game_path' do
        expect(response).to redirect_to(game_path(game_w_questions))
      end

      it 'flashes the alert' do
        expect(flash[:alert]).to eq "Вы еще не завершили игру"
      end
    end

    context 'when User answers incorrectly' do
      before(:each) {put :answer, id: game_w_questions.id, letter: 'a'}

      it 'flashes alert' do
        expect(flash[:alert]).to include "Правильный ответ:"
        expect(flash[:alert]).to include "Игра закончена, ваш приз 0 ₽"
      end
      it 'redirects to user profile' do
        expect(response).to redirect_to(user_path(game_w_questions.user))
      end
    end

    context 'when game is in_progress' do
      it 'uses audience help' do
        put :help, id: game_w_questions.id, help_type: :audience_help
        game = assigns(:game)
        expect(response.status).to eq 302
        expect(response).to redirect_to(game_path(game))
      end

      it 'uses fifty_fifty help' do
        put :help, id: game_w_questions.id, help_type: :fifty_fifty
        game = assigns(:game)
        expect(game.current_game_question.help_hash[:fifty_fifty]).to be
        expect(response).to redirect_to(game_path(game))
      end
    end
  end
end
