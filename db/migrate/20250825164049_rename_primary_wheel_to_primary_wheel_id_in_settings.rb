class RenamePrimaryWheelToPrimaryWheelIdInSettings < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing foreign key constraint before renaming
    remove_foreign_key :settings, :pies, column: :primary_wheel

    # Remove the existing index before renaming
    remove_index :settings, :primary_wheel

    # Rename the column from primary_wheel to primary_wheel_id
    rename_column :settings, :primary_wheel, :primary_wheel_id

    # Re-add the foreign key constraint with the new column name
    add_foreign_key :settings, :pies, column: :primary_wheel_id

    # Re-add the index with the new column name
    add_index :settings, :primary_wheel_id
  end
end
