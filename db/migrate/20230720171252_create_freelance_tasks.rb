class CreateFreelanceTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :freelance_tasks do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end
  end
end
