Sequel.migration do
  change do
    create_table(:nytimes) do
      primary_key :id
      foreign_key :flight_id, :flights, null: false, on_delete: :cascade
      String      :title
      String      :published_date
      String      :url
    end
  end
end
