Sequel.migration do
  change do
    create_table(:flights_nytimes) do
      primary_key [:flight_id, :nytime_id]
      foreign_key :flight_id, :flights
      foreign_key :nytime_id, :nytimes

      index [:flight_id, :nytime_id]
    end
  end
end
