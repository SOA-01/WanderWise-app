Sequel.migration do
  change do
    create_table(:flights_articles) do
      primary_key [:flight_id, :article_id]
      foreign_key :flight_id, :flights
      foreign_key :article_id, :articles

      index [:flight_id, :article_id]
    end
  end
end
