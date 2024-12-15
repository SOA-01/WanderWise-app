# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../config/environment' # Ensure the environment is loaded

describe 'Unit test of WanderWise API gateway' do
  before do
    WanderWise::App.environment = :test # Set the environment explicitly
    @config = WanderWise::App.config
    @gateway = WanderWise::Gateway::Api.new(@config)
  end

  it 'must report alive status' do
    alive = @gateway.alive?
    _(alive).must_equal true
  end

  it 'must fetch a list of flights' do
    params = { origin: 'TPE', destination: 'LAX', date: (Date.today + 7).to_s }
    response = @gateway.fetch_flights(params)

    _(response.success?).must_equal true
    data = response.payload
    _(data).must_be_instance_of Array
    _(data.first.keys).must_include 'origin_location_code'
  end

  it 'must fetch articles for a country' do
    country = 'USA'
    response = @gateway.fetch_articles(country)

    _(response.success?).must_equal true
    data = response.payload
    _(data).must_be_instance_of Array
    _(data.first.keys).must_include 'title'
  end
end
