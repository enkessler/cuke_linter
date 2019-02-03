require_relative '../../../environments/rspec_env'


RSpec.describe CukeLinter do

  it "has a version number" do
    expect(CukeLinter::VERSION).not_to be nil
  end

  it 'can lint' do
    expect(CukeLinter).to respond_to(:lint)
  end

  it 'lints the (optionally) given model tree using the (optionally) provided set of linters and formats the output with the (optionally) provided formatters' do
    expect(CukeLinter.method(:lint).arity).to eq(-1)
    expect(CukeLinter.method(:lint).parameters).to match_array([[:key, :model_tree],
                                                                [:key, :linters],
                                                                [:key, :formatters]])
  end

  it 'can register a linter' do
    expect(CukeLinter).to respond_to(:register_linter)
  end

  it 'can unregister a linter' do
    expect(CukeLinter).to respond_to(:unregister_linter)
  end

  it 'registers a linter by name' do
    expect(CukeLinter.method(:register_linter).arity).to eq(1)
    expect(CukeLinter.method(:register_linter).parameters).to match_array([[:keyreq, :linter],
                                                                           [:keyreq, :name]])
  end

  it 'unregisters a linter by name' do
    expect(CukeLinter.method(:unregister_linter).arity).to eq(1)
    expect(CukeLinter.method(:unregister_linter).parameters).to match_array([[:req, :name]])
  end

  it 'knows its currently registered linters' do
    expect(CukeLinter).to respond_to(:registered_linters)
  end

  it 'correctly registers, unregisters, and tracks linters' do
    CukeLinter.clear_registered_linters
    CukeLinter.register_linter(name: 'foo', linter: :linter_1)
    CukeLinter.register_linter(name: 'bar', linter: :linter_2)
    CukeLinter.register_linter(name: 'baz', linter: :linter_3)

    CukeLinter.unregister_linter('bar')

    expect(CukeLinter.registered_linters).to eq({ 'foo' => :linter_1,
                                                  'baz' => :linter_3, })
  end

  it 'can clear all of its currently registered linters' do
    expect(CukeLinter).to respond_to(:clear_registered_linters)

    CukeLinter.register_linter(name: 'some_linter', linter: :the_linter)
    CukeLinter.clear_registered_linters

    expect(CukeLinter.registered_linters).to eq({})
  end

end
