class CreateInjections < ActiveRecord::Migration[5.2]
  def change
    create_table :injections do |t|
      t.float :units
      t.text :notes
      t.integer :injection_type

      t.timestamps
    end
  end
end
