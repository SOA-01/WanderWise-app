# frozen_string_literal: true

require_relative '../../../app/application/services/add_flights'
require_relative '../../../app/infrastructure/database/repositories/flights'

RSpec.describe WanderWise::Service::AddFlights do
  let(:add_flights_service) { described_class.new }
  let(:flight_data) { [{ originLocationCode: 'TPE', destinationLocationCode: 'LAX' }] }
  let(:input) { { originLocationCode: 'TPE', destinationLocationCode: 'LAX', departureDate: '2024-11-25', adults: 1 } }

  describe '#find_flights' do
    context 'when flights are found' do
      before do
        allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flights).and_return(flight_data)
        allow_any_instance_of(WanderWise::Service::AddFlights).to receive(:Success).and_call_original
      end

      it 'returns Success with flight data' do
        result = add_flights_service.send(:find_flights, input)
        expect(result).to be_a(Dry::Monads::Result::Success)
        expect(result.value!).to eq(flight_data)
      end
    end

    # context 'when no flights are found' do
    #   before do
    #     allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flight).and_return([])
    #   end

    #   it 'returns Failure' do
    #     result = add_flights_service.send(:find_flights, input)
    #     expect(result).to be_a(Dry::Monads::Result::Failure)
    #     expect(result.failure).to eq('No flights found for the given criteria.')
    #   end
    # end

    # context 'when an error occurs' do
    #   before do
    #     allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flight).and_raise(StandardError, 'API error')
    #   end

    #   it 'returns Failure with error message' do
    #     result = add_flights_service.send(:find_flights, input)
    #     expect(result).to be_a(Dry::Monads::Result::Failure)
    #     expect(result.failure).to eq('API error')
    #   end
    # end
  end

  # describe '#store_flights' do
  #   context 'when storing flights is successful' do
  #     before do
  #       allow(WanderWise::Repository::For.klass(WanderWise::Entity::Flight))
  #         .to receive(:create_many).and_return(flight_data)
  #     end

  #     it 'returns Success' do
  #       result = add_flights_service.send(:store_flights, Dry::Monads::Success(flight_data))
  #       expect(result).to be_a(Dry::Monads::Result::Success)
  #       expect(result.value!).to eq(flight_data)
  #     end
  #   end

  #   context 'when storing flights fails' do
  #     before do
  #       allow(WanderWise::Repository::For.klass(WanderWise::Entity::Flight))
  #         .to receive(:create_many).and_raise(StandardError, 'Database error')
  #     end

  #     it 'returns Failure with an error message' do
  #       result = add_flights_service.send(:store_flights, Dry::Monads::Success(flight_data))
  #       expect(result).to be_a(Dry::Monads::Result::Failure)
  #       expect(result.failure).to eq('Could not save flight data')
  #     end
  #   end
  # end

  # describe '#call' do
  #   context 'when the transaction is successful' do
  #     before do
  #       allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flight).and_return(flight_data)
  #       allow(WanderWise::Repository::For.klass(WanderWise::Entity::Flight))
  #         .to receive(:create_many).and_return(flight_data)
  #     end

  #     it 'returns Success' do
  #       result = add_flights_service.call(input)
  #       expect(result).to be_a(Dry::Monads::Result::Success)
  #       expect(result.value!).to eq(flight_data)
  #     end
  #   end

  #   context 'when the transaction fails at find_flights' do
  #     before do
  #       allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flight).and_return([])
  #     end

  #     it 'returns Failure' do
  #       result = add_flights_service.call(input)
  #       expect(result).to be_a(Dry::Monads::Result::Failure)
  #       expect(result.failure).to eq('No flights found for the given criteria.')
  #     end
  #   end

  #   context 'when the transaction fails at store_flights' do
  #     before do
  #       allow_any_instance_of(WanderWise::AmadeusAPI).to receive(:find_flight).and_return(flight_data)
  #       allow(WanderWise::Repository::For.klass(WanderWise::Entity::Flight))
  #         .to receive(:create_many).and_raise(StandardError, 'Database error')
  #     end

  #     it 'returns Failure' do
  #       result = add_flights_service.call(input)
  #       expect(result).to be_a(Dry::Monads::Result::Failure)
  #       expect(result.failure).to eq('Could not save flight data')
  #     end
  #   end
  # end
end
