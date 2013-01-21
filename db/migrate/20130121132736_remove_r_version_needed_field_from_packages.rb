class RemoveRVersionNeededFieldFromPackages < ActiveRecord::Migration
  def up
    remove_column :packages, :r_version_needed
  end

  def down
    add_column :packages, :r_version_needed, :string
  end
end
