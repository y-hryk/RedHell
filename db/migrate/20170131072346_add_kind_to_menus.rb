class AddKindToMenus < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :kind_id, :integer
  end
end
