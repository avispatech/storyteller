# frozen_string_literal: true

class NonEmptyStepStory < Storyteller::Story
  step -> {}
end

class SpiableClass
  def call
  end
end

RSpec.describe Storyteller do
  it "has a version number" do
    expect(Storyteller::VERSION).not_to be_nil
  end

  describe "#valid?" do
    context "when no steps are given" do
      it do
        class NoStepClass < Storyteller::Story
        end

        expect(NoStepClass.new).not_to be_valid
      end
    end

    context "when no validation is added" do
      it do
        class NoValidationClass < NonEmptyStepStory
        end
        expect(NoValidationClass.new).to be_valid
      end
    end

    context "when single validation is added" do
      it "validates using lambdas" do
        class SingleValidationUsingBlockClass < NonEmptyStepStory
          initialize_with :a
          requisite -> { error(:obj_a, :invalid) unless a.valid? }
        end
        obj_d = object_double("User", valid?: true)
        expect(SingleValidationUsingBlockClass.new(a: obj_d)).to be_valid
        expect(obj_d).to(have_received(:valid?).at_least(1))
      end

      it "validates using symbols" do
        class SingleValidationUsingSymbolClass < NonEmptyStepStory
          initialize_with :a
          requisite :check_a

          def check_a
            error(:obj_a, :invalid) unless a.valid?
          end
        end
        obj_d = instance_double("User", valid?: true)
        expect(SingleValidationUsingSymbolClass.new(a: obj_d)).to be_valid
        expect(obj_d).to(have_received(:valid?).at_least(1))
      end
    end

    context "when multiple validation are added" do
      it "validates using lambdas" do
        class MultipleValidationUsingBlockClass < NonEmptyStepStory
          initialize_with :a, :b
          requisite -> { error(:obj_a, :invalid) unless a.valid? }
          requisite -> { error(:obj_b, :invalid) unless b.valid? }
        end

        a = object_double("User", valid?: true)
        b = object_double("User", valid?: true)
        expect(MultipleValidationUsingBlockClass.new(a:, b:)).to be_valid
        expect(a).to have_received(:valid?).at_least(1)
        expect(b).to have_received(:valid?).at_least(1)
      end

      it "validates using symbols" do
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

        a = object_double("User", valid?: true)
        b = object_double("User", valid?: true)
        expect(MultipleValidationUsingSymbolClass.new(a:, b:)).to be_valid
        expect(a).to have_received(:valid?).at_least(1)
        expect(b).to have_received(:valid?).at_least(1)
      end
    end

    context "when validation criteria is invalid" do
      context "when there is one criteria" do
        it do
          class SingleInvalidCriteriaClass < NonEmptyStepStory
            initialize_with :a
            requisite :check_a

            def check_a
              error(:obj_a, :invalid) unless a.valid?
            end
          end
          obj_d = object_double("User", valid?: false)
          expect(SingleInvalidCriteriaClass.new(a: obj_d)).not_to be_valid
        end
      end

      context "when some criteria is invalid" do
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
          obj_a = object_double("User", valid?: false)
          obj_b = object_double("User", valid?: true)
          expect(PartiallyInvalidCriteriaClass.new(a: obj_a, b: obj_b)).not_to be_valid
        end
      end

      context "when all criteria is invalid" do
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
          obj_a = object_double("User", valid?: false)
          obj_b = object_double("User", valid?: false)
          expect(AllInvalidCriteriaClass.new(a: obj_a, b: obj_b)).not_to be_valid
        end
      end
    end
  end

  describe "#execute" do
    context "when it has one step" do
      it do
        class OneStepStory < Storyteller::Story
          initialize_with :spy
          step :single_step

          def single_step
            spy.call
          end
        end
        spy = spy("Thing") # standard:disable RSpec/VerifiedDoubles
        OneStepStory.execute(spy:)
        expect(spy).to have_received(:call)
      end
    end

    context "when it has multiple steps" do
      it do
        class MultipleStepStory < Storyteller::Story
          initialize_with :spy1, :spy2
          step :first_step
          step :second_step

          def first_step = spy1.call

          def second_step = spy2.call
        end
        spy1 = spy("Thing") # standard:disable RSpec/VerifiedDoubles
        spy2 = spy("Thing") # standard:disable RSpec/VerifiedDoubles
        MultipleStepStory.execute(spy1:, spy2:)
        expect(spy1).to have_received(:call)
        expect(spy2).to have_received(:call)
      end
    end

    context "when it has repeated steps" do
      it do
        class RepeatedStepsStory < Storyteller::Story
          initialize_with :spy
          step :first_step
          step :first_step

          def first_step = spy.call
        end
        spy = spy("Thing") # standard:disable RSpec/VerifiedDoubles
        RepeatedStepsStory.execute(spy:)
        expect(spy).to have_received(:call).at_most(1)
      end
    end
  end

  describe "#success?" do
    context "when there is no error on any steps" do
      it do
        expect(NonEmptyStepStory.execute).to be_success
      end

      context "when there is done criteria" do
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

        context "when criteria is valid" do
          it do
            spy = object_double("Spy", valid?: true)
            expect(klass.execute(spy:)).to be_success
          end
        end

        context "when criteria is invalid" do
          it do
            spy = object_double("Spy", valid?: false)
            expect(klass.execute(spy:)).not_to be_success
          end
        end
      end
    end

    context "when there is an error on any step" do
      it do
        class FailedStepStory < Storyteller::Story
          step -> { error(:step, :failure) }
        end

        expect(FailedStepStory.execute).not_to be_success
      end

      context "when there is done criteria" do
        it "doesnt call the done criterias" do
          class FailedStepWithDoneCriteriaStory < Storyteller::Story
            initialize_with :spy
            step -> { error(:step, :failure) }

            verify :check

            def check = spy.call
          end

          spy = spy("Thing") # rubocop:disable RSpec/VerifiedDoubles
          expect(FailedStepWithDoneCriteriaStory.execute(spy:)).not_to be_success
          expect(spy).not_to have_received(:call)
        end
      end
    end
  end

  describe "#after_run" do
    context "when there silent_story is active" do
      it do
        class SilentStory < Storyteller::Story
          initialize_with :spy, captcha: false, returns: :blank

          step -> { @a ||= 1 }
          step -> { @a += 1 }
          after_run :call_spy

          def call_spy
            spy.call
          end
        end

        spy = spy("Thing") # rubocop:disable RSpec/VerifiedDoubles
        expect(SilentStory.execute(spy:, silent_story: true)).to be_success
        expect(spy).not_to have_received(:call)
        ss = SilentStory.new(spy:, silent_story: true)
        ss.execute
        expect(spy).not_to have_received(:call)
        expect(SilentStory.execute(spy:)).to be_success
        expect(spy).to have_received(:call)
      end
    end
  end

  describe "aliases and callbacks" do
    it "supports validates_with as an alias of requisite" do
      class ValidatesWithAliasStory < NonEmptyStepStory
        initialize_with :spy
        validates_with :check_spy

        def check_spy
          error(:spy, :invalid) unless spy.valid?
        end
      end

      spy = object_double("Spy", valid?: true)
      expect(ValidatesWithAliasStory.new(spy:)).to be_valid
    end

    it "supports prepares_with as an alias of prepare" do
      class PreparesWithAliasStory < NonEmptyStepStory
        initialize_with :spy
        prepares_with :load_spy
        requisite :spy_loaded?

        def load_spy
          @loaded = true
        end

        def spy_loaded?
          error(:spy, :missing) unless @loaded
        end
      end

      spy = object_double("Spy")
      expect(PreparesWithAliasStory.execute(spy:)).to be_success
    end

    it "supports done_criteria as an alias of verify" do
      class DoneCriteriaAliasStory < Storyteller::Story
        initialize_with :spy
        step -> {}
        done_criteria :check_spy

        def check_spy
          error(:spy, :invalid) unless spy.valid?
        end
      end

      spy = object_double("Spy", valid?: true)
      expect(DoneCriteriaAliasStory.execute(spy:)).to be_success
    end

    it "runs after_init callbacks once during execution" do
      class AfterInitStory < Storyteller::Story
        initialize_with :spy
        step -> {}
        after_init :mark_init

        def mark_init
          spy.call
        end
      end

      spy = spy("Thing") # rubocop:disable RSpec/VerifiedDoubles
      AfterInitStory.execute(spy:)
      expect(spy).to have_received(:call).at_most(1)
    end

    it "supports check with multiple callbacks" do
      class CheckCallbacksStory < Storyteller::Story
        initialize_with :spy1, :spy2
        check [:first_check, :second_check]

        def first_check = spy1.call
        def second_check = spy2.call
      end

      spy1 = spy("Thing") # rubocop:disable RSpec/VerifiedDoubles
      spy2 = spy("Thing") # rubocop:disable RSpec/VerifiedDoubles
      CheckCallbacksStory.execute(spy1:, spy2:)
      expect(spy1).to have_received(:call)
      expect(spy2).to have_received(:call)
    end
  end
end
