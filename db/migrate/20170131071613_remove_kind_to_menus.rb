class RemoveKindToMenus < ActiveRecord::Migration[5.0]
  def change
    remove_column :menus, :kind, :string
  end
end
