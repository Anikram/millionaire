require 'rails_helper'

RSpec.feature 'USER creates game', type: :feature do
  let(:user) {FactoryBot.create :user}

  let!(:questions) do
    (0..14).to_a.map do |i|
      FactoryBot.create(:question, level: i,
                        text: "Не #{i} ли раз ты падал?",
                        answer1: 'да', answer2: 'нет', answer3: 'не знаю', answer4: 'ну и что?'
      )
    end
  end

  before(:each) do
    login_as user
  end

  scenario 'success' do
    visit '/'

    click_link 'Новая игра'

    expect(page).to have_content('Не 0 ли раз ты падал?')

    expect(page).to have_content('да')
    expect(page).to have_content('нет')
    expect(page).to have_content('не знаю')
    expect(page).to have_content('ну и что?')

    save_and_open_page
  end
end