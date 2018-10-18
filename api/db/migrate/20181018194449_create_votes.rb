class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.belongs_to :bnb
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :number_of_votes, null: false

      t.timestamps
    end
  end
end
