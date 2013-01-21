class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.string :dependencies
      t.string :r_version_needed
      t.string :suggestions
      t.string :license     
      t.timestamps
    end
  end
end
