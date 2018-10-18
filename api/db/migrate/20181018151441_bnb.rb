class Bnb < ActiveRecord::Migration[5.2]
  def change
    create_table :bnbs do |t|
      t.column :name, :string, null: false

      t.timestamps
    end
  end
end
