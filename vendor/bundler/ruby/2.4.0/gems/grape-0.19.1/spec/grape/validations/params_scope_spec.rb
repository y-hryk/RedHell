require 'spec_helper'

describe Grape::Validations::ParamsScope do
  subject do
    Class.new(Grape::API)
  end

  def app
    subject
  end

  context 'setting a default' do
    let(:documentation) { subject.routes.first.params }

    context 'when the default value is truthy' do
      before do
        subject.params do
          optional :int, type: Integer, default: 42
        end
        subject.get
      end

      it 'adds documentation about the default value' do
        expect(documentation).to have_key('int')
        expect(documentation['int']).to have_key(:default)
        expect(documentation['int'][:default]).to eq(42)
      end
    end

    context 'when the default value is false' do
      before do
        subject.params do
          optional :bool, type: Virtus::Attribute::Boolean, default: false
        end
        subject.get
      end

      it 'adds documentation about the default value' do
        expect(documentation).to have_key('bool')
        expect(documentation['bool']).to have_key(:default)
        expect(documentation['bool'][:default]).to eq(false)
      end
    end

    context 'when the default value is nil' do
      before do
        subject.params do
          optional :object, type: Object, default: nil
        end
        subject.get
      end

      it 'adds documentation about the default value' do
        expect(documentation).to have_key('object')
        expect(documentation['object']).to have_key(:default)
        expect(documentation['object'][:default]).to eq(nil)
      end
    end
  end

  context 'without a default' do
    before do
      subject.params do
        optional :object, type: Object
      end
      subject.get
    end

    it 'does not add documentation for the default value' do
      documentation = subject.routes.first.params
      expect(documentation).to have_key('object')
      expect(documentation['object']).not_to have_key(:default)
    end
  end

  context 'setting description' do
    [:desc, :description].each do |description_type|
      it "allows setting #{description_type}" do
        subject.params do
          requires :int, type: Integer, description_type => 'My very nice integer'
        end
        subject.get '/single' do
          'int works'
        end
        get '/single', int: 420
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('int works')
      end
    end
  end

  context 'when using custom types' do
    module ParamsScopeSpec
      class CustomType
        attr_reader :value

        def self.parse(value)
          raise if value == 'invalid'
          new(value)
        end

        def initialize(value)
          @value = value
        end
      end
    end

    it 'coerces the parameter via the type\'s parse method' do
      subject.params do
        requires :foo, type: ParamsScopeSpec::CustomType
      end
      subject.get('/types') { params[:foo].value }

      get '/types', foo: 'valid'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('valid')

      get '/types', foo: 'invalid'
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/foo is invalid/)
    end
  end

  context 'array without coerce type explicitly given' do
    it 'sets the type based on first element' do
      subject.params do
        requires :periods, type: Array, values: -> { %w(day month) }
      end
      subject.get('/required') { 'required works' }

      get '/required', periods: %w(day month)
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('required works')
    end

    it 'fails to call API without Array type' do
      subject.params do
        requires :periods, type: Array, values: -> { %w(day month) }
      end
      subject.get('/required') { 'required works' }

      get '/required', periods: 'day'
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('periods is invalid')
    end

    it 'raises exception when values are of different type' do
      expect do
        subject.params { requires :numbers, type: Array, values: [1, 'definitely not a number', 3] }
      end.to raise_error Grape::Exceptions::IncompatibleOptionValues
    end

    it 'raises exception when range values have different endpoint types' do
      expect do
        subject.params { requires :numbers, type: Array, values: 0.0..10 }
      end.to raise_error Grape::Exceptions::IncompatibleOptionValues
    end
  end

  context 'coercing values validation with proc' do
    it 'allows the proc to pass validation without checking' do
      subject.params { requires :numbers, type: Integer, values: -> { [0, 1, 2] } }

      subject.post('/required') { 'coercion with proc works' }
      post '/required', numbers: '1'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('coercion with proc works')
    end

    it 'allows the proc to pass validation without checking in value' do
      subject.params { requires :numbers, type: Integer, values: { value: -> { [0, 1, 2] } } }

      subject.post('/required') { 'coercion with proc works' }
      post '/required', numbers: '1'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('coercion with proc works')
    end

    it 'allows the proc to pass validation without checking in except' do
      subject.params { requires :numbers, type: Integer, values: { except: -> { [0, 1, 2] } } }

      subject.post('/required') { 'coercion with proc works' }
      post '/required', numbers: '10'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('coercion with proc works')
    end
  end

  context 'with range values' do
    context "when left range endpoint isn't #kind_of? the type" do
      it 'raises exception' do
        expect do
          subject.params { requires :latitude, type: Integer, values: -90.0..90 }
        end.to raise_error Grape::Exceptions::IncompatibleOptionValues
      end
    end

    context "when right range endpoint isn't #kind_of? the type" do
      it 'raises exception' do
        expect do
          subject.params { requires :latitude, type: Integer, values: -90..90.0 }
        end.to raise_error Grape::Exceptions::IncompatibleOptionValues
      end
    end

    context 'when the default is an array' do
      context 'and is the entire range of allowed values' do
        it 'does not raise an exception' do
          expect do
            subject.params { optional :numbers, type: Array[Integer], values: 0..2, default: 0..2 }
          end.to_not raise_error
        end
      end

      context 'and is a subset of allowed values' do
        it 'does not raise an exception' do
          expect do
            subject.params { optional :numbers, type: Array[Integer], values: [0, 1, 2], default: [1, 0] }
          end.to_not raise_error
        end
      end
    end

    context 'when both range endpoints are #kind_of? the type' do
      it 'accepts values in the range' do
        subject.params do
          requires :letter, type: String, values: 'a'..'z'
        end
        subject.get('/letter') { params[:letter] }

        get '/letter', letter: 'j'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq('j')
      end

      it 'rejects values outside the range' do
        subject.params do
          requires :letter, type: String, values: 'a'..'z'
        end
        subject.get('/letter') { params[:letter] }

        get '/letter', letter: 'J'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('letter does not have a valid value')
      end
    end
  end

  context 'parameters in group' do
    it 'errors when no type is provided' do
      expect do
        subject.params do
          group :a do
            requires :b
          end
        end
      end.to raise_error Grape::Exceptions::MissingGroupTypeError

      expect do
        subject.params do
          optional :a do
            requires :b
          end
        end
      end.to raise_error Grape::Exceptions::MissingGroupTypeError
    end

    it 'allows Hash as type' do
      subject.params do
        group :a, type: Hash do
          requires :b
        end
      end
      subject.get('/group') { 'group works' }
      get '/group', a: { b: true }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('group works')

      subject.params do
        optional :a, type: Hash do
          requires :b
        end
      end
      get '/optional_type_hash'
    end

    it 'allows Array as type' do
      subject.params do
        group :a, type: Array do
          requires :b
        end
      end
      subject.get('/group') { 'group works' }
      get '/group', a: [{ b: true }]
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('group works')

      subject.params do
        optional :a, type: Array do
          requires :b
        end
      end
      get '/optional_type_array'
    end

    it 'errors with an unsupported type' do
      expect do
        subject.params do
          group :a, type: Set do
            requires :b
          end
        end
      end.to raise_error Grape::Exceptions::UnsupportedGroupTypeError

      expect do
        subject.params do
          optional :a, type: Set do
            requires :b
          end
        end
      end.to raise_error Grape::Exceptions::UnsupportedGroupTypeError
    end
  end

  context 'when validations are dependent on a parameter' do
    before do
      subject.params do
        optional :a
        given :a do
          requires :b
        end
      end
      subject.get('/test') { declared(params).to_json }
    end

    it 'applies the validations only if the parameter is present' do
      get '/test'
      expect(last_response.status).to eq(200)

      get '/test', a: true
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('b is missing')

      get '/test', a: true, b: true
      expect(last_response.status).to eq(200)
    end

    it 'applies the validations of multiple parameters' do
      subject.params do
        optional :a, :b
        given :a, :b do
          requires :c
        end
      end
      subject.get('/multiple') { declared(params).to_json }

      get '/multiple'
      expect(last_response.status).to eq(200)

      get '/multiple', a: true
      expect(last_response.status).to eq(200)

      get '/multiple', b: true
      expect(last_response.status).to eq(200)

      get '/multiple', a: true, b: true
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('c is missing')

      get '/multiple', a: true, b: true, c: true
      expect(last_response.status).to eq(200)
    end

    it 'applies only the appropriate validation' do
      subject.params do
        optional :a
        optional :b
        mutually_exclusive :a, :b
        given :a do
          requires :c, type: String
        end
        given :b do
          requires :c, type: Integer
        end
      end
      subject.get('/multiple') { declared(params).to_json }

      get '/multiple'
      expect(last_response.status).to eq(200)

      get '/multiple', a: true, c: 'test'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).symbolize_keys).to eq a: 'true', b: nil, c: 'test'

      get '/multiple', b: true, c: '3'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body).symbolize_keys).to eq a: nil, b: 'true', c: 3

      get '/multiple', a: true
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('c is missing')

      get '/multiple', b: true
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('c is missing')

      get '/multiple', a: true, b: true, c: 'test'
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('a, b are mutually exclusive, c is invalid')
    end

    it 'raises an error if the dependent parameter was never specified' do
      expect do
        subject.params do
          given :c do
          end
        end
      end.to raise_error(Grape::Exceptions::UnknownParameter)
    end

    it 'includes the parameter within #declared(params)' do
      get '/test', a: true, b: true

      expect(JSON.parse(last_response.body)).to eq('a' => 'true', 'b' => 'true')
    end

    it 'returns a sensible error message within a nested context' do
      subject.params do
        requires :bar, type: Hash do
          optional :a
          given :a do
            requires :b
          end
        end
      end
      subject.get('/nested') { 'worked' }

      get '/nested', bar: { a: true }
      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq('bar[b] is missing')
    end

    it 'includes the nested parameter within #declared(params)' do
      subject.params do
        requires :bar, type: Hash do
          optional :a
          given :a do
            requires :b
          end
        end
      end
      subject.get('/nested') { declared(params).to_json }

      get '/nested', bar: { a: true, b: 'yes' }
      expect(JSON.parse(last_response.body)).to eq('bar' => { 'a' => 'true', 'b' => 'yes' })
    end

    it 'includes level 2 nested parameters outside the given within #declared(params)' do
      subject.params do
        requires :bar, type: Hash do
          optional :a
          given :a do
            requires :c, type: Hash do
              requires :b
            end
          end
        end
      end
      subject.get('/nested') { declared(params).to_json }

      get '/nested', bar: { a: true, c: { b: 'yes' } }
      expect(JSON.parse(last_response.body)).to eq('bar' => { 'a' => 'true', 'c' => { 'b' => 'yes' } })
    end
  end

  context 'when validations are dependent on a parameter with specific value' do
    # build test cases from all combinations of declarations and options
    a_decls = %i(optional requires)
    a_options = [{}, { values: %w(x y z) }]
    b_options = [{}, { type: String }, { allow_blank: false }, { type: String, allow_blank: false }]
    combinations = a_decls.product(a_options, b_options)
    combinations.each_with_index do |combination, i|
      a_decl, a_opts, b_opts = combination

      context "(case #{i})" do
        before do
          # puts "a_decl: #{a_decl}, a_opts: #{a_opts}, b_opts: #{b_opts}"
          subject.params do
            send a_decl, :a, **a_opts
            given(a: ->(val) { val == 'x' }) { requires :b, **b_opts }
            given(a: ->(val) { val == 'y' }) { requires :c, **b_opts }
          end
          subject.get('/test') { declared(params).to_json }
        end

        if a_decl == :optional
          it 'skips validation when base param is missing' do
            get '/test'
            expect(last_response.status).to eq(200)
          end
        end

        it 'skips validation when base param does not have a specified value' do
          get '/test', a: 'z'
          expect(last_response.status).to eq(200)

          get '/test', a: 'z', b: ''
          expect(last_response.status).to eq(200)
        end

        it 'applies the validation when base param has the specific value' do
          get '/test', a: 'x'
          expect(last_response.status).to eq(400)
          expect(last_response.body).to include('b is missing')

          get '/test', a: 'x', b: true
          expect(last_response.status).to eq(200)

          get '/test', a: 'x', b: true, c: ''
          expect(last_response.status).to eq(200)
        end

        it 'includes the parameter within #declared(params)' do
          get '/test', a: 'x', b: true
          expect(JSON.parse(last_response.body)).to eq('a' => 'x', 'b' => 'true', 'c' => nil)
        end
      end
    end
  end

  it 'raises an error if the dependent parameter was never specified' do
    expect do
      subject.params do
        given :c do
        end
      end
    end.to raise_error(Grape::Exceptions::UnknownParameter)
  end

  it 'returns a sensible error message within a nested context' do
    subject.params do
      requires :bar, type: Hash do
        optional :a
        given a: ->(val) { val == 'x' } do
          requires :b
        end
      end
    end
    subject.get('/nested') { 'worked' }

    get '/nested', bar: { a: 'x' }
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq('bar[b] is missing')
  end

  it 'includes the nested parameter within #declared(params)' do
    subject.params do
      requires :bar, type: Hash do
        optional :a
        given a: ->(val) { val == 'x' } do
          requires :b
        end
      end
    end
    subject.get('/nested') { declared(params).to_json }

    get '/nested', bar: { a: 'x', b: 'yes' }
    expect(JSON.parse(last_response.body)).to eq('bar' => { 'a' => 'x', 'b' => 'yes' })
  end

  it 'includes level 2 nested parameters outside the given within #declared(params)' do
    subject.params do
      requires :bar, type: Hash do
        optional :a
        given a: ->(val) { val == 'x' } do
          requires :c, type: Hash do
            requires :b
          end
        end
      end
    end
    subject.get('/nested') { declared(params).to_json }

    get '/nested', bar: { a: 'x', c: { b: 'yes' } }
    expect(JSON.parse(last_response.body)).to eq('bar' => { 'a' => 'x', 'c' => { 'b' => 'yes' } })
  end

  it 'includes deeply nested parameters within #declared(params)' do
    subject.params do
      requires :arr1, type: Array do
        requires :hash1, type: Hash do
          requires :arr2, type: Array do
            requires :hash2, type: Hash do
              requires :something, type: String
            end
          end
        end
      end
    end
    subject.get('/nested_deep') { declared(params).to_json }

    get '/nested_deep', arr1: [{ hash1: { arr2: [{ hash2: { something: 'value' } }] } }]
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq('arr1' => [{ 'hash1' => { 'arr2' => [{ 'hash2' => { 'something' => 'value' } }] } }])
  end

  context 'failing fast' do
    context 'when fail_fast is not defined' do
      it 'does not stop validation' do
        subject.params do
          requires :one
          requires :two
          requires :three
        end
        subject.get('/fail-fast') { declared(params).to_json }

        get '/fail-fast'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('one is missing, two is missing, three is missing')
      end
    end
    context 'when fail_fast is defined it stops the validation' do
      it 'of other params' do
        subject.params do
          requires :one, fail_fast: true
          requires :two
        end
        subject.get('/fail-fast') { declared(params).to_json }

        get '/fail-fast'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('one is missing')
      end
      it 'for a single param' do
        subject.params do
          requires :one, allow_blank: false, regexp: /[0-9]+/, fail_fast: true
        end
        subject.get('/fail-fast') { declared(params).to_json }

        get '/fail-fast', one: ''
        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq('one is empty')
      end
    end
  end

  context 'when params have group attributes' do
    context 'with validations' do
      before do
        subject.params do
          with(allow_blank: false) do
            requires :id
            optional :name
            optional :address, allow_blank: true
          end
        end
        subject.get('test')
      end

      context 'when data is invalid' do
        before do
          get 'test', id: '', name: ''
        end

        it 'returns a validation error' do
          expect(last_response.status).to eq(400)
        end

        it 'applies group validations for every parameter' do
          expect(last_response.body).to eq('id is empty, name is empty')
        end
      end

      context 'when parameter has the same validator as a group' do
        before do
          get 'test', id: 'id', address: ''
        end

        it 'returns a successful response' do
          expect(last_response.status).to eq(200)
        end

        it 'prioritizes parameter validation over group validation' do
          expect(last_response.body).to_not include('address is empty')
        end
      end
    end

    context 'with types' do
      before do
        subject.params do
          with(type: Date) do
            requires :created_at
          end
        end
        subject.get('test') { params[:created_at] }
      end

      context 'when invalid date provided' do
        before do
          get 'test', created_at: 'not_a_date'
        end

        it 'responds with HTTP error' do
          expect(last_response.status).to eq(400)
        end

        it 'returns a validation error' do
          expect(last_response.body).to eq('created_at is invalid')
        end
      end

      context 'when created_at receives a valid date' do
        before do
          get 'test', created_at: '2016-01-01'
        end

        it 'returns a successful response' do
          expect(last_response.status).to eq(200)
        end

        it 'returns a date' do
          expect(last_response.body).to eq('2016-01-01')
        end
      end
    end

    context 'with several group attributes' do
      before do
        subject.params do
          with(values: [1]) do
            requires :id, type: Integer
          end

          with(allow_blank: false) do
            optional :address, type: String
          end

          requires :name
        end
        subject.get('test')
      end

      context 'when data is invalid' do
        before do
          get 'test', id: 2, address: ''
        end

        it 'responds with HTTP error' do
          expect(last_response.status).to eq(400)
        end

        it 'returns a validation error' do
          expect(last_response.body).to eq('id does not have a valid value, address is empty, name is missing')
        end
      end

      context 'when correct data is provided' do
        before do
          get 'test', id: 1, address: 'Some street', name: 'John'
        end

        it 'returns a successful response' do
          expect(last_response.status).to eq(200)
        end
      end
    end

    context 'with nested groups' do
      before do
        subject.params do
          with(type: Integer) do
            requires :id

            with(type: Date) do
              requires :created_at
              optional :updated_at
            end
          end
        end
        subject.get('test')
      end

      context 'when data is invalid' do
        before do
          get 'test', id: 'wrong', created_at: 'not_a_date', updated_at: '2016-01-01'
        end

        it 'responds with HTTP error' do
          expect(last_response.status).to eq(400)
        end

        it 'returns a validation error' do
          expect(last_response.body).to eq('id is invalid, created_at is invalid')
        end
      end

      context 'when correct data is provided' do
        before do
          get 'test', id: 1, created_at: '2016-01-01'
        end

        it 'returns a successful response' do
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
