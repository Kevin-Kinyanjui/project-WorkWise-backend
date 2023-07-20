class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.references :job, null: false, foreign_key: true
      t.references :job_seeker, null: false, foreign_key: { to_table: :users }
      t.text :cover_letter
      t.string :resume
      t.timestamps
    end
  end
end
