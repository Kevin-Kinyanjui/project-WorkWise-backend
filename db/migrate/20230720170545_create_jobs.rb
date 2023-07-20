class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.references :employer, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.text :requirements
      t.string :location
      t.timestamps
    end
  end
end
