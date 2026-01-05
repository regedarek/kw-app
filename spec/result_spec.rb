require 'rails_helper'

RSpec.describe Result do
  describe 'keyword argument handling' do
    it 'passes keyword arguments correctly to blocks' do
      result = Failure.new(:invalid, form: 'test_form')
      
      captured_form = nil
      result.invalid { |form:| captured_form = form }
      
      expect(captured_form).to eq('test_form')
    end

    it 'handles multiple keyword arguments' do
      result = Failure.new(:error, foo: 'bar', baz: 'qux')
      
      captured_foo = nil
      captured_baz = nil
      result.error { |foo:, baz:| 
        captured_foo = foo
        captured_baz = baz
      }
      
      expect(captured_foo).to eq('bar')
      expect(captured_baz).to eq('qux')
    end

    it 'works with Success objects' do
      result = Success.new(payment: 'payment_object')
      
      captured_payment = nil
      result.success { |payment:| captured_payment = payment }
      
      expect(captured_payment).to eq('payment_object')
    end
  end

  describe 'positional argument handling' do
    it 'still supports positional arguments when needed' do
      result = Failure.new(:error, 'arg1', 'arg2')
      
      captured_args = []
      result.error { |*args| captured_args = args }
      
      expect(captured_args).to eq(['arg1', 'arg2'])
    end
  end
end