require 'rails_helper'

RSpec.describe Question, type: :model do
  context 'validations check' do
    it { should validate_presence_of :text }

    it { should validate_presence_of :level }

    it { should validate_inclusion_of(:level).in_range(0..14) }

    it { should allow_value(14).for(:level) }

    it { should_not allow_value(15).for(:level) }
  end

  context 'question uniqness check' do
    it 'questions unique' do
      used_text = []

      1000.times do
        question = FactoryBot.create(:question)
        expect(used_text.include?(question.text))
        used_text << question.text
      end
    end
  end
end
