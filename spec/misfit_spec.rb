require 'spec_helper'

module MisfitSpec
  #
  #   Error
  #   +- FooError (RuntimeError)
  #      +- FazError (ArgumentError)
  #         +- BarError
  module Error
    include Misfit
  end

  module FooError
    include Error
    exception_class RuntimeError
  end

  module FazError
    include FooError
    exception_class IOError
  end

  module BarError
    include FazError
  end

  describe Misfit do
    describe 'Error (includes Misfit)' do
      subject { exception_module }

      let(:exception_module) { Error }
      let(:message)          { 'message' }
      let(:data)             { 'exception data' }

      describe 'standard idioms' do
        it 'raise <exception_module> should raise error with no message' do
          expect { raise exception_module }.to raise_error(exception_module)
        end

        it 'exception_module.exception should return error with no message' do
          exception_module.exception.should be_a(exception_module)
        end

        describe 'raise <exception_module>, <message>' do
          subject { raise exception_module, message }

          it { expect{ subject }.to raise_error(StandardError, message) }
          it { expect{ subject }.to raise_error(exception_module, message) }
        end

        describe 'raise <exception_module>.new(<message>)' do
          subject { raise exception_module.new(message) }

          it { expect{ subject }.to raise_error(StandardError, message) }
          it { expect{ subject }.to raise_error(exception_module, message) }
        end

        describe 'raise <exception_module>.exception(<message>)' do
          subject { raise exception_module.exception(message) }

          it { expect{ subject }.to raise_error(StandardError, message) }
          it { expect{ subject }.to raise_error(exception_module, message) }
        end

        describe 'FooError (includes Error, exception_class RuntimeError)' do
          let(:exception_module) { FooError }

          describe 'raise <exception_module>, <message>' do
            subject { raise exception_module, message }

            it { expect{ subject }.to raise_error(Error, message) }
            it { expect{ subject }.to raise_error(FooError, message) }
            it { expect{ subject }.to raise_error(RuntimeError, message) }
          end
        end

        describe 'FazError (includes FooError, exception_class IOError)' do
          let(:exception_module) { FazError }

          describe 'raise <exception_module>, <message>' do
            subject { raise exception_module, message }

            it { expect{ subject }.to raise_error(Misfit, message) }
            it { expect{ subject }.to raise_error(Error, message) }
            it { expect{ subject }.to raise_error(FooError, message) }
            it { expect{ subject }.to raise_error(FazError, message) }
            it { expect{ subject }.to raise_error(IOError, message) }
          end
        end

        describe 'BarError (includes FazError)' do
          let(:exception_module) { BarError }

          describe 'raise <exception_module>, <message>' do
            subject { raise exception_module, message }

            it { expect{ subject }.to raise_error(Error, message) }
            it { expect{ subject }.to raise_error(FooError, message) }
            it { expect{ subject }.to raise_error(FazError, message) }
            it { expect{ subject }.to raise_error(BarError, message) }
            it { expect{ subject }.to raise_error(IOError, message) }
          end
        end

        describe "used in specs" do
          it "should work with stubs" do
            object = Object.new
            object.stub(:foo).and_raise(Error)
            expect { object.foo }.to raise_error(Error)
          end
        end
      end

      describe 'adding data' do
        describe 'raise <exception_module>.new <message>, <data>' do
          subject { raise exception_module.new(message, data) }

          it "should have data added to the exception" do
            begin
              subject
            rescue => e
              e.data.should == data
            end
          end
        end
      end

      describe '#wrap' do
        describe 'RuntimeError.new(<message>)' do
          subject { exception_module.wrap RuntimeError.new(message) }

          it { should be_a RuntimeError }
          it { should be_a exception_module }
          its(:message) { should == message }
        end

        describe 'RuntimeError.new(<message>), <exception data>' do
          subject { exception_module.wrap RuntimeError.new(message), data }

          it { should be_a RuntimeError }
          it { should be_a exception_module }
          its(:message) { should == message }
          its(:data) { should == data }
        end

        describe '{ some_error_ridden_code! }' do
          subject { exception_module.wrap do some_error_ridden_code! end }

          it { expect{ subject }.to raise_error(NoMethodError, /some_error_ridden_code!/) }
          it { expect{ subject }.to raise_error(exception_module, /some_error_ridden_code!/) }
        end
      end
    end

    describe "#inspect" do
      subject { error.inspect }

      context "for Error.new" do
        let(:error) { Error.new }
        it { should =~ /\(MisfitSpec::Error\)/ }
      end

      context "for FazError.new" do
        let(:error) { FazError.new }
        it { should =~ /\(MisfitSpec::FazError, MisfitSpec::FooError, MisfitSpec::Error\)/ }
      end

      context "when error has data `Error.new('message', some: 'data')`" do
        let(:error) { Error.new('message', some: "data") }
        it { should =~ /\(MisfitSpec::Error\)/ }
        it { should =~ /\{:some=>"data"\}/ }
      end
    end
  end
end

