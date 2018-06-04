require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    assign(:users, [
      FactoryBot.build_stubbed(:user, name: 'Саша', balance: 50_000),
      FactoryBot.build_stubbed(:user, name: 'Маша', balance: 30_000),
    ])

    render
  end

  it 'renders player names' do
    expect(rendered).to match 'Саша'
    expect(rendered).to match 'Маша'
  end

  it 'renders player balances' do
    expect(rendered).to match '50 000 ₽'
    expect(rendered).to match '30 000 ₽'
  end

  it 'renders player names in right order' do
    expect(rendered).to match /Саша.*Маша/m
  end
end