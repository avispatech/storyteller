# frozen_string_literal: true
class NonEmptyStepStory < Storyteller::Story
  step -> () { }
end

RSpec.describe Storyteller do
  it 'has a version number' do
    expect(Storyteller::VERSION).not_to be nil
  end


  context 'when no steps are given' do
    it do
      class NoStepClass < Storyteller::Story
      end

      expect(NoStepClass.new).not_to be_valid
    end
  end

  context 'when no validation is added' do
    it do
      class NoValidationClass < NonEmptyStepStory
      end
      expect(NoValidationClass.new).to be_valid
    end
  end

  context 'when single validation is added' do

    it 'validates using lambdas' do
      class SingleValidationUsingBlockClass < NonEmptyStepStory
        initialize_with :a
        validates_with -> () { error(:obj_a, :invalid) unless a.valid? } 
      end
      obj_d = object_double('User', valid?: true)
      expect(SingleValidationUsingBlockClass.new(a: obj_d)).to be_valid
      expect(obj_d).to(have_received(:valid?).at_least(1))
    end

    it 'validates using symbols' do
      class SingleValidationUsingSymbolClass < NonEmptyStepStory
        initialize_with :a
        validates_with :check_a

        def check_a
          error(:obj_a, :invalid) unless a.valid?
        end
      end
      obj_d = object_double('User', valid?: true)
      expect(SingleValidationUsingSymbolClass.new(a: obj_d)).to be_valid
      expect(obj_d).to(have_received(:valid?).at_least(1))
    end
  end

  context 'when multiple validation is added' do
    it 'validates using lambdas' do
      class MultipleValidationUsingBlockClass < NonEmptyStepStory
        initialize_with :a, :b
        validates_with -> () { error(:obj_a, :invalid) unless a.valid? }
        validates_with -> () { error(:obj_b, :invalid) unless b.valid? }
      end

      a = object_double('User', valid?: true)
      b = object_double('User', valid?: true)
      expect(MultipleValidationUsingBlockClass.new(a:, b:)).to be_valid
      expect(a).to have_received(:valid?).at_least(1)
      expect(b).to have_received(:valid?).at_least(1)
    end

    it 'validates using symbols' do
      class MultipleValidationUsingSymbolClass < NonEmptyStepStory
        initialize_with :a, :b
        validates_with :check_a
        def check_a
          error(:obj_a, :invalid) unless a.valid?
        end
        validates_with :check_b
        def check_b
          error(:obj_b, :invalid) unless b.valid?
        end
      end

      a = object_double('User', valid?: true)
      b = object_double('User', valid?: true)
      expect(MultipleValidationUsingSymbolClass.new(a:, b:)).to be_valid
      expect(a).to have_received(:valid?).at_least(1)
      expect(b).to have_received(:valid?).at_least(1)
    end
  end

  
  
end
