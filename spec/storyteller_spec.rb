# frozen_string_literal: true

class NonEmptyStepStory < Storyteller::Story
  step -> {}
end

RSpec.describe Storyteller do
  it 'has a version number' do
    expect(Storyteller::VERSION).not_to be_nil
  end

  describe '#valid?' do
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
          requisite -> { error(:obj_a, :invalid) unless a.valid? }
        end
        obj_d = object_double('User', valid?: true)
        expect(SingleValidationUsingBlockClass.new(a: obj_d)).to be_valid
        expect(obj_d).to(have_received(:valid?).at_least(1))
      end

      it 'validates using symbols' do
        class SingleValidationUsingSymbolClass < NonEmptyStepStory
          initialize_with :a
          requisite :check_a

          def check_a
            error(:obj_a, :invalid) unless a.valid?
          end
        end
        obj_d = object_double('User', valid?: true)
        expect(SingleValidationUsingSymbolClass.new(a: obj_d)).to be_valid
        expect(obj_d).to(have_received(:valid?).at_least(1))
      end
    end

    context 'when multiple validation are added' do
      it 'validates using lambdas' do
        class MultipleValidationUsingBlockClass < NonEmptyStepStory
          initialize_with :a, :b
          requisite -> { error(:obj_a, :invalid) unless a.valid? }
          requisite -> { error(:obj_b, :invalid) unless b.valid? }
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
          requisite :check_a
          def check_a
            error(:obj_a, :invalid) unless a.valid?
          end
          requisite :check_b
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

    context 'when validation criteria is invalid' do
      context 'when there is one criteria' do
        it do
          class SingleInvalidCriteriaClass < NonEmptyStepStory
            initialize_with :a
            requisite :check_a

            def check_a
              error(:obj_a, :invalid) unless a.valid?
            end
          end
          obj_d = object_double('User', valid?: false)
          expect(SingleInvalidCriteriaClass.new(a: obj_d)).not_to be_valid
        end
      end

      context 'when some criteria is invalid' do
        it do
          class PartiallyInvalidCriteriaClass < NonEmptyStepStory
            initialize_with :a, :b
            requisite :check_a
            requisite :check_b

            def check_a
              error(:obj_a, :invalid) unless a.valid?
            end

            def check_b
              error(:obj_b, :invalid) unless b.valid?
            end
          end
          obj_a = object_double('User', valid?: false)
          obj_b = object_double('User', valid?: true)
          expect(SingleInvalidCriteriaClass.new(a: obj_a, b: obj_b)).not_to be_valid
        end
      end

      context 'when all criteria is invalid' do
        it do
          class AllInvalidCriteriaClass < NonEmptyStepStory
            initialize_with :a, :b
            requisite :check_a
            requisite :check_b

            def check_a
              error(:obj_a, :invalid) unless a.valid?
            end

            def check_b
              error(:obj_b, :invalid) unless b.valid?
            end
          end
          obj_a = object_double('User', valid?: false)
          obj_b = object_double('User', valid?: false)
          expect(SingleInvalidCriteriaClass.new(a: obj_a, b: obj_b)).not_to be_valid
        end
      end
    end
  end

  describe '#execute' do
    context 'when it has one step' do
      it do
        class OneStepStory < Storyteller::Story
          initialize_with :spy
          step :single_step

          def single_step
            spy.call
          end
        end
        spy = spy('thing')
        OneStepStory.execute(spy:)
        expect(spy).to have_received(:call)
      end
    end

    context 'when it has multiple steps' do
      it do
        class MultipleStepStory < Storyteller::Story
          initialize_with :spy1, :spy2
          step :first_step
          step :second_step

          def first_step = spy1.call

          def second_step = spy2.call
        end
        spy1 = spy('thing')
        spy2 = spy('thing')
        MultipleStepStory.execute(spy1:, spy2:)
        expect(spy1).to have_received(:call)
        expect(spy2).to have_received(:call)
      end
    end

    context 'when it has repeated steps' do
      it do
        class RepeatedStepsStory < Storyteller::Story
          initialize_with :spy
          step :first_step
          step :first_step

          def first_step = spy.call
        end
        spy = spy('thing')
        RepeatedStepsStory.execute(spy:)
        expect(spy).to have_received(:call).at_most(1)
      end
    end
  end

  describe '#success?' do
    context 'when there is no error on any steps' do
      it do
        expect(NonEmptyStepStory.execute).to be_success
      end

      context 'when there is done criteria' do
        let(:klass) do
          class NonEmptyStepWithCriteriaStory < Storyteller::Story
            initialize_with :spy
            step -> {}

            verify :check_spy

            def check_spy
              error(:spy, :invalid) unless spy.valid?
            end
          end
          NonEmptyStepWithCriteriaStory
        end

        context 'when criteria is valid' do
          it do
            spy = object_double('Spy', valid?: true)
            expect(klass.execute(spy:)).to be_success
          end
        end

        context 'when criteria is invalid' do
          it do
            spy = object_double('Spy', valid?: false)
            expect(klass.execute(spy:)).not_to be_success
          end
        end
      end
    end

    context 'when there is an error on any step' do
      it do
        class FailedStepStory < Storyteller::Story
          step -> { error(:step, :failure) }
        end

        expect(FailedStepStory.execute).not_to be_success
      end

      context 'when there is done criteria' do
        it 'doesnt call the done criterias' do
          class FailedStepWithDoneCriteriaStory < Storyteller::Story
            initialize_with :spy
            step -> { error(:step, :failure) }

            verify :check

            def check = spy.call
          end

          spy = spy('Thing')
          expect(FailedStepWithDoneCriteriaStory.execute(spy:)).not_to be_success
          expect(spy).not_to have_received(:call)
        end
      end
    end
  end
end
