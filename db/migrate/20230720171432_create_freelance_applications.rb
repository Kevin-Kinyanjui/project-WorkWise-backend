class CreateFreelanceApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :freelance_applications do |t|
      t.references :freelance_task, null: false, foreign_key: true
      t.references :freelancer, null: false, foreign_key: { to_table: :users }
      t.text :proposal
      t.timestamps
    end
  end
end
