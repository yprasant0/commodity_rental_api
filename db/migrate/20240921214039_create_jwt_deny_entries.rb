class CreateJwtDenyEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :jwt_deny_entries do |t|
      t.string :jti
      t.datetime :exp

      t.timestamps
    end
    add_index :jwt_deny_entries, :jti
  end
end
